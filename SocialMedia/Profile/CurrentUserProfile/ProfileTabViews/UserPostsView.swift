//
//  UserPostsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserPostsView: View {
    @StateObject var model: UserPostsViewModel
    let noContentText: String
    @EnvironmentObject private var refreshedFilter: RefreshedFilterModel
    
    init(user: User, noContentText: String) {
        self._model = StateObject(wrappedValue: UserPostsViewModel(user: user))
        self.noContentText = noContentText
    }
    
    var body: some View {
        PostGrid(postGridType: .posts(model.posts),
                 isLoading: $model.isLoading,
                 itemsPerPage: model.itemsPerPage,
                 noContentText: noContentText,
                 loadNewPage: model.loadMorePosts)
        .onFirstAppear {
            Task { try await model.loadMorePosts() }
        }
        .onReceive(refreshedFilter.$refreshedFilter) { refreshedFilter in
            if refreshedFilter == .posts, !model.posts.isEmpty {
                Task { try await model.refresh() }
            }
        }
    }
}
