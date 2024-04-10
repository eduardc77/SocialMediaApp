//
//  ForYouFeedView.swift
//  SocialMedia
//

import SwiftUI

struct ForYouFeedView: View {
    @StateObject private var model = ForYouFeedViewModel()
    @EnvironmentObject private var router: FeedViewRouter
    
    var body: some View {
        ScrollView {
            PostGrid(router: router, postGridType: .posts(model.posts),
                     loading: $model.loading,
                     endReached: model.noMoreItemsToFetch,
                     itemsPerPage: model.itemsPerPage,
                     contentUnavailableText: model.contentUnavailableText,
                     loadNewPage: model.loadMorePosts)
        }
        .refreshable {
            Task {
                try await model.refresh()
            }
        }
        .onAppear {
            Task {
                if model.posts.isEmpty {
                    try await model.loadMorePosts()
                }
                model.addListenerForPostUpdates()
            }
        }
    }
}

#Preview {
    ForYouFeedView()
        .environmentObject(FeedViewRouter())
}
