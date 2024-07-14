//
//  ForYouFeedView.swift
//  SocialMedia
//

import SwiftUI

@MainActor
struct ForYouFeedView: View {
    @State private var model = ForYouFeedViewModel()
    @Environment(ViewRouter.self) private var router
    
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
    ForYouFeedView()
        .environment(ModalScreenRouter())
        .environment(ViewRouter())
}
