//
//  UserLikedPostsView.swift
//  SocialMedia
//

import SwiftUI
import Combine
import SocialMediaNetwork

@MainActor
struct UserLikedPostsView: View {
    @State private var model: UserLikedPostsViewModel
    private var router: Router
    private let contentUnavailableText: String
    @EnvironmentObject private var refreshedFilter: RefreshedFilterModel
    
    init(router: Router, user: User, contentUnavailableText: String) {
        self.router = router
        model = UserLikedPostsViewModel(user: user)
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
        .task {
            if model.posts.isEmpty {
                await model.loadMorePosts()
            }
            model.addListenersForPostUpdates()
        }
        .onReceive(refreshedFilter.$refreshedFilter) { refreshedFilter in
            if refreshedFilter == .liked {
                Task { await model.refresh() }
            }
        }
    }
}
