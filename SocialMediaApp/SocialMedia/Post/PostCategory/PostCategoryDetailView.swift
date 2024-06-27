//
//  PostCategoryDetailView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

@MainActor
struct PostCategoryDetailView: View {
    private var router: Router
    @State private var model: PostCategoryViewModel
    
    init(router: Router, category: PostCategory) {
        self.router = router
        model = PostCategoryViewModel(category: category)
    }
    
    var body: some View {
        VStack {
            TopFilterBar(currentFilter: $model.currentFilter, onSelection: {
                model.sortPosts()
            })
            postsTabView
        }
        .navigationTitle("\(model.category.icon) \(model.category.rawValue.capitalized)")
        .navigationBarTitleDisplayMode(.inline)
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
                await model.refresh()
            }
            .task {
                if model.posts.isEmpty {
                    await model.loadMorePosts()
                }
                model.addListenerForPostUpdates()
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
                await model.refresh()
            }
            .task {
                if model.posts.isEmpty {
                    await model.loadMorePosts()
                }
                model.addListenerForPostUpdates()
            }
        }
#if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
#endif
    }
    
}

#Preview {
    NavigationView {
        PostCategoryDetailView(router: ViewRouter(), category: .affirmations)
            .environment(ModalScreenRouter())
    }
}
