//
//  UserPostsView.swift
//  SocialMedia
//

import SwiftUI
import Combine
import SocialMediaNetwork

@MainActor
struct UserPostsView: View {
    @State private var model: UserPostsViewModel
    private let router: Router
    private let contentUnavailableText: String
    @EnvironmentObject private var refreshedFilter: RefreshedFilterModel
    
    init(router: Router, user: User, contentUnavailableText: String) {
        self.router = router
        model = UserPostsViewModel(user: user)
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
            model.addListenerForPostUpdates()
        }
        .onReceive(refreshedFilter.$refreshedFilter) { refreshedFilter in
            if refreshedFilter == .posts, !model.posts.isEmpty {
                Task { await model.refresh() }
            }
        }
    }
}
