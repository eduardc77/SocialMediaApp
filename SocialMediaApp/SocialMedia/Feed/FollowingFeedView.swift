//
//  FollowingFeedView.swift
//  SocialMedia
//

import SwiftUI

@MainActor
struct FollowingFeedView: View {
    @State private var model = FollowingFeedViewModel()
    @Environment(ViewRouter.self) private var router
    
    @State private var firstAppear: Bool = true
    
    var body: some View {
        ScrollView {
            PostGrid(router: router, postGridType: .posts(model.posts),
                     loading: $model.loading,
                     loadingIndicatorHidden: model.loadingHidden,
                     endReached: model.noMoreItemsToFetch,
                     itemsPerPage: model.itemsPerPage,
                     contentUnavailableText: model.contentUnavailableText,
                     loadNewPage: model.loadMorePosts)
        }
        .contentMargins(.top, 30, for: .scrollContent)
        .refreshable {
            model.loadingHidden = true
            await model.refresh()
            model.loadingHidden = false
        }
        .task {
            if model.posts.isEmpty {
                await model.loadMorePosts()
            }
            model.addListenerForPostUpdates()
        }
    }
}

#Preview {
    FollowingFeedView()
        .environment(ModalScreenRouter())
        .environment(ViewRouter())
    
}
