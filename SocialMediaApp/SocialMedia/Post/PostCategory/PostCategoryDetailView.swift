//
//  PostCategoryDetailView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

struct PostCategoryDetailView: View {
    var router: any Router
    @StateObject var model: PostCategoryViewModel
    
    init(router: any Router, category: PostCategory) {
        self.router = router
        _model = StateObject(wrappedValue: PostCategoryViewModel(category: category))
    }
    
    var body: some View {
        VStack {
            TopFilterBar(currentFilter: $model.currentFilter, onSelection: {
                model.sortPosts()
            })
            postsTabView
        }
        .navigationTitle("\(model.category.icon) \(model.category.rawValue.capitalized)")
        .background(Color.groupedBackground)
    }
}

// MARK: - Subviews

private extension PostCategoryDetailView {
    
    var postsTabView: some View {
        TabView(selection: $model.currentFilter) {
            ScrollView {
                PostGrid(router: router,
                         postGridType: .posts(model.posts),
                         loading: $model.loading,
                         endReached: model.noMoreItemsToFetch,
                         loadNewPage: model.loadMorePosts)
            }
            .tag(CategoryFilter.hot)
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
            ScrollView {
                PostGrid(router: router,
                         postGridType: .posts(model.posts),
                         loading: $model.loading,
                         endReached: model.noMoreItemsToFetch,
                         loadNewPage: model.loadMorePosts)
            }
            .tag(CategoryFilter.new)
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
#if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
#endif
    }
    
}

#Preview {
    NavigationView {
        PostCategoryDetailView(router: FeedViewRouter(), category: .affirmations)
    }
}
