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
        TabView(selection: $model.currentFilter) {
            ForEach(CategoryFilter.allCases) { filter in
                tabPage(filter: filter)
            }
        }
        .ignoresSafeArea(edges: .vertical)
        .navigationTitle("\(model.category.icon) \(model.category.rawValue.capitalized)")
#if !os(macOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
        .navigationBarTitleDisplayMode(.inline)
#endif
        .safeAreaInset(edge: .top, content: {
            TopFilterBar(currentFilter: $model.currentFilter, onSelection: {
                withAnimation {
                    model.sortPosts()
                }
            })
            .background(.bar)
        })
        .background(Color.groupedBackground)
    }
}

// MARK: - Subviews

private extension PostCategoryDetailView {
    
    func tabPage(filter: CategoryFilter) -> some View {
        ScrollView {
            PostGrid(router: router,
                     postGridType: .posts(model.posts),
                     loading: $model.loading,
                     endReached: model.noMoreItemsToFetch,
                     loadNewPage: model.loadMorePosts)
        }
        .tag(filter)
        .contentMargins(.top, 30, for: .scrollContent)
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
}

#Preview {
    NavigationView {
        PostCategoryDetailView(router: ViewRouter(), category: .affirmations)
            .environment(ModalScreenRouter())
    }
}
