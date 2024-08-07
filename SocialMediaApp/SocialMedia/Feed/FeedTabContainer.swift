//
//  FeedTabContainer.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

struct FeedTabContainer: View {
    @State var currentFilter: FeedFilter = .forYou
    @Environment(ViewRouter.self) private var router
    
    var body: some View {
        feedTabView
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .safeAreaInset(edge: .top, content: {
                TopFilterBar(currentFilter: $currentFilter)
                    .background(.bar)
            })
            .background(Color.groupedBackground)
    }
}

// MARK: - Subviews

private extension FeedTabContainer {
    @MainActor
    var feedTabView: some View {
        TabView(selection: $currentFilter) {
            ForYouFeedView()
                .tag(FeedFilter.forYou)
            
            FollowingFeedView()
                .tag(FeedFilter.following)
        }
        .ignoresSafeArea(edges: .vertical)
#if !os(macOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
#endif
    }
}

#Preview {
    FeedTabContainer()
        .environment(ViewRouter())
        .environment(ModalScreenRouter())
}
