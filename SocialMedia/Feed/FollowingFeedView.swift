//
//  FollowingFeedView.swift
//  SocialMedia
//

import SwiftUI

struct FollowingFeedView: View {
    @StateObject private var model = FollowingFeedViewModel()
    @EnvironmentObject private var router: FeedViewRouter
    
    @State private var firstAppear: Bool = true
    
    var body: some View {
        ScrollView {
            PostGrid(router: router, postGridType: .posts(model.posts),
                     isLoading: $model.isLoading,
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
    FollowingFeedView()
        .environmentObject(FeedViewRouter())
}
