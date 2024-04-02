//
//  FeedView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct FeedView: View {
    @StateObject private var model = FeedViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FeedFilterView(currentFilter: $model.currentFilter)
                feedTabView
            }
            .background(Color.groupedBackground)
            .refreshable {
                Task {
                    try await model.refreshFeedForCurrentFilter()
                }
            }
            .navigationDestination(for: User.self, destination: { user in
                if user.isCurrentUser {
                    CurrentUserProfileCoordinator(didNavigate: true)
                } else {
                    ProfileView(user: user)
                }
            })
            .navigationDestination(for: PostType.self, destination: { postType in
                PostDetailsView(postType: postType)
            })
            .navigationDestination(for: PostCategory.self, destination: { category in
                PostCategoryDetailView(category: category)
            })
        }
    }
}

// MARK: - Subviews

private extension FeedView {
    
    var feedTabView: some View {
        TabView(selection: $model.currentFilter) {
            ScrollView {
                PostGrid(postGridType: .posts(model.forYouPosts),
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
                PostGrid(postGridType: .posts(model.followingPosts),
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
