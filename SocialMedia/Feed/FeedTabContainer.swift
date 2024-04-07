//
//  FeedTabContainer.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct FeedTabContainer: View {
    @State var currentFilter: FeedFilter = .forYou
    @EnvironmentObject private var router: FeedViewRouter
    
    var body: some View {
        VStack(spacing: 0) {
            FeedFilterView(currentFilter: $currentFilter)
            feedTabView
        }
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .background(Color.groupedBackground)
    }
}

// MARK: - Subviews

private extension FeedTabContainer {
    
    var feedTabView: some View {
        TabView(selection: $currentFilter) {
            ForYouFeedView()
                .tag(FeedFilter.forYou)
            
            FollowingFeedView()
                .tag(FeedFilter.following)
        }
#if !os(macOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
#endif
    }
}

#Preview {
    FeedTabContainer()
        .environmentObject(FeedViewRouter())
}
