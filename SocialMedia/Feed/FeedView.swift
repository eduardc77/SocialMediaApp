//
//  FeedView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct FeedView: View {
    @StateObject var model = FeedViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                FeedFilterView(currentFilter: $model.currentFilter)
                postsTabView
            }
            .navigationDestination(for: User.self, destination: { user in
                if user.isCurrentUser {
                    CurrentUserProfileCoordinator(didNavigate: true)
                } else {
                    ProfileView(user: user)
                }
            })
            .navigationDestination(for: Post.self, destination: { post in
                PostDetailsView(post: post)
            })
            .navigationDestination(for: PostCategory.self, destination: { category in
                PostCategoryDetailView(category: category)
            })
            .background(Color.groupedBackground)
           
            .refreshable {
                Task {
                    try await model.refreshFeedForCurrentFilter()
                }
            }
        }
    }
}

// MARK: - Subviews

private extension FeedView {
    
    var postsTabView: some View {
        TabView(selection: $model.currentFilter) {
            ScrollView {
                PostGrid(postGridType: .posts(model.forYouPosts), isLoading: $model.isLoading, itemsPerPage: model.itemsPerPage, fetchNewPage: {
                    try await model.fetchFeedForCurrentFilter()
                })

            }
            .tag(FeedFilter.forYou)
            .overlay {
                if model.isLoading { ProgressView() }
            }
            .onAppear {
                Task {
                    try await model.fetchFeedForCurrentFilter()
                }
            }

            ScrollView {
                PostGrid(postGridType: .posts(model.followingPosts), isLoading: $model.isLoading, itemsPerPage: model.itemsPerPage, fetchNewPage: {
                        Task {
                            try await model.fetchFeedForCurrentFilter()
                        }
                })
            }
            .tag(FeedFilter.following)
            .overlay {
                if model.isLoading { ProgressView() }
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
