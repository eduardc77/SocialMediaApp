//
//  FeedView.swift
//  SocialMedia
//

import SwiftUI

struct FeedView: View {
    @StateObject private var model = FeedViewModel()
    @EnvironmentObject private var router: FeedViewRouter
    
    var body: some View {
        VStack(spacing: 0) {
            FeedFilterView(currentFilter: $model.currentFilter)
            feedTabView
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.groupedBackground)
        .refreshable {
            Task {
                try await model.refreshFeedForCurrentFilter()
            }
        }
    }
}

// MARK: - Subviews

private extension FeedView {
    
    var feedTabView: some View {
        TabView(selection: $model.currentFilter) {
            ScrollView {
                PostGrid(router: router, postGridType: .posts(model.forYouPosts),
                         isLoading: $model.isLoading,
                         itemsPerPage: model.itemsPerPage,
                         loadNewPage: model.fetchFeedForCurrentFilter)
            }
            .tag(FeedFilter.forYou)
            .onAppear {
                Task {
                    try await model.fetchFeedForCurrentFilter()
                }
            }
            
            ScrollView {
                PostGrid(router: router, postGridType: .posts(model.followingPosts),
                         isLoading: $model.isLoading, itemsPerPage: model.itemsPerPage,
                         noContentText: "You haven't followed any accounts yet.",
                         loadNewPage: model.fetchFeedForCurrentFilter)
                
            }
            .tag(FeedFilter.following)
            .onAppear {
                Task {
                    try await model.fetchFeedForCurrentFilter()
                }
            }
        }
#if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
#endif
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
