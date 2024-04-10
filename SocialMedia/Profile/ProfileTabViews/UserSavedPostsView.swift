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
                 loading: $model.loading,
                 endReached: model.noMoreItemsToFetch,
                 itemsPerPage: model.itemsPerPage,
                 contentUnavailableText: contentUnavailableText,
                 loadNewPage: model.loadMorePosts)
        .onAppear {
            Task {
                if model.posts.isEmpty {
                    try await model.loadMorePosts()
                }
                model.addListenersForPostUpdates()
            }
        }
        .onReceive(refreshedFilter.$refreshedFilter) { refreshedFilter in
            if refreshedFilter == .saved {
                Task { try await model.refresh() }
            }
        }
    }
}
