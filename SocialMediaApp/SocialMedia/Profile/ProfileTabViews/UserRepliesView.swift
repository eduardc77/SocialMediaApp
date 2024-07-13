//
//  UserRepliesView.swift
//  SocialMedia
//

import SwiftUI
import Combine
import SocialMediaNetwork

@MainActor
struct UserRepliesView: View {
    @State private var model: UserRepliesViewModel
    private let router: Router
    private let contentUnavailableText: String
    @EnvironmentObject private var refreshedFilter: RefreshedFilterModel
    
    init(router: Router, user: User, contentUnavailableText: String) {
        self.router = router
        model = UserRepliesViewModel(user: user)
        self.contentUnavailableText = contentUnavailableText
    }
    
    var body: some View {
        RepliesGrid(router: router,
                    replies: model.replies,
                    loading: $model.loading,
                    endReached: model.noMoreItemsToFetch,
                    itemsPerPage: model.itemsPerPage,
                    contentUnavailableText: contentUnavailableText,
                    loadNewPage: model.loadMoreReplies)
        .task {
            if model.replies.isEmpty {
                await model.loadMoreReplies()
            }
            // model.addListenerForPostUpdates()
        }
        .onReceive(refreshedFilter.$refreshedFilter) { refreshedFilter in
            if refreshedFilter == .replies, !model.replies.isEmpty {
                Task { await model.refresh() }
            }
        }
    }
}
