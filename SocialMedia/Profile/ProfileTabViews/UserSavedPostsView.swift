//
//  UserSavedPostsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserSavedPostsView: View {
    @StateObject var model: UserSavedPostsViewModel
    var router: any Router
    let contentUnavailableText: String
    @EnvironmentObject private var refreshedFilter: RefreshedFilterModel
    
    init(router: any Router, user: User, contentUnavailableText: String) {
        self.router = router
        self._model = StateObject(wrappedValue: UserSavedPostsViewModel(user: user))
        self.contentUnavailableText = contentUnavailableText
    }
    
    var body: some View {
        PostGrid(router: router,
                 postGridType: .posts(model.posts),
                 isLoading: $model.isLoading,
                 itemsPerPage: model.itemsPerPage,
                 contentUnavailableText: contentUnavailableText,
                 loadNewPage: model.loadMorePosts)
        .onFirstAppear {
            Task { try await model.loadMorePosts() }
        }
        .onReceive(refreshedFilter.$refreshedFilter) { refreshedFilter in
            if refreshedFilter == .saved {
                Task { try await model.refresh() }
            }
        }
    }
}
