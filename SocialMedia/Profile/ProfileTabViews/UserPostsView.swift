//
//  UserPostsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserPostsView: View {
    @StateObject var model: UserPostsViewModel
    var router: any Router
    let contentUnavailableText: String
    @EnvironmentObject private var refreshedFilter: RefreshedFilterModel
  
    init(router: any Router, user: User, contentUnavailableText: String) {
        self.router = router
        self._model = StateObject(wrappedValue: UserPostsViewModel(user: user))
        self.contentUnavailableText = contentUnavailableText
    }
    
    var body: some View {
        PostGrid(router: router,
                 postGridType: .posts(model.posts),
                 isLoading: $model.isLoading,
                 itemsPerPage: model.itemsPerPage,
                 contentUnavailableText: contentUnavailableText,
                 loadNewPage: model.loadMorePosts)
        .onAppear {
            Task {
                if model.posts.isEmpty {
                    try await model.loadMorePosts()
                }
                model.addListenerForPostUpdates()
            }
        }
        .onReceive(refreshedFilter.$refreshedFilter) { refreshedFilter in
            if refreshedFilter == .posts, !model.posts.isEmpty {
                Task { try await model.refresh() }
            }
        }
    }
}
