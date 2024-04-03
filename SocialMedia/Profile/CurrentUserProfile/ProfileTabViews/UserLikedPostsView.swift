//
//  UserLikedPostsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserLikedPostsView: View {
    @StateObject var model: UserLikedPostsViewModel
    let noContentText: String
    @EnvironmentObject private var refreshedFilter: RefreshedFilterModel
    @EnvironmentObject private var router: ProfileViewRouter
    
    init(user: User, noContentText: String) {
        self._model = StateObject(wrappedValue: UserLikedPostsViewModel(user: user))
        self.noContentText = noContentText
    }
    
    var body: some View {
        PostGrid(router: router,
                 postGridType: .posts(model.posts),
                 isLoading: $model.isLoading,
                 itemsPerPage: model.itemsPerPage,
                 noContentText: noContentText,
                 loadNewPage: model.loadMorePosts)
        .onFirstAppear {
            Task { try await model.loadMorePosts() }
        }
        .onReceive(refreshedFilter.$refreshedFilter) { refreshedFilter in
            if refreshedFilter == .liked {
                Task { try await model.refresh() }
            }
        }
    }
}
