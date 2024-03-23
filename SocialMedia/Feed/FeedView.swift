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
                CategoryDetailView(category: category)
            })
            .navigationTitle("Posts")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.groupedBackground)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            try await model.refreshFeedForCurrentFilter()
                        }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                            .foregroundStyle(Color.primary)
                    }
                }
            }
            .refreshable {
                Task {
                    try await model.refreshFeedForCurrentFilter()
                }
            }
            .onChange(of: model.currentFilter) { _, _ in
                Task {
                    try await model.fetchFeedForCurrentFilter()
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
                ContentGrid(contentGridType: .posts(model.forYouPosts), pageCount: $model.pageCount, isLoading: $model.isLoading, itemsPerPage: model.itemsPerPage, fetchNewPage: {
                        model.addListenersForFeed()
                })
            }
            .tag(FeedFilter.forYou)
            .overlay {
                if model.isLoading { ProgressView() }
            }
            .onAppear {
                model.addListenersForFeed()
            }
            .onDisappear {
                model.removeListeners()
            }
            ScrollView {
                ContentGrid(contentGridType: .posts(model.followingPosts), pageCount: $model.pageCount, isLoading: $model.isLoading, itemsPerPage: model.itemsPerPage, fetchNewPage: {
                    if model.lastForYouPostDocument != nil {
                        Task {
                            try await model.fetchFeedForCurrentFilter()
                        }
                    }
                })
            }
            .tag(FeedFilter.following)
            .overlay {
                if model.isLoading { ProgressView() }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}
