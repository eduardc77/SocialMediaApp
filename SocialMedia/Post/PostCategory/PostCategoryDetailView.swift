//
//  PostCategoryDetailView.swift
//  SocialMedia
//

import SwiftUI
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
            PostCategoryFilter(filter: $model.currentFilter) { newFilter in
                model.currentFilter = newFilter
                model.sortPosts()
            }
            postsTabView
        }
        .navigationBar(title: "\(model.category.icon) \(model.category.rawValue.capitalized)")
        .background(Color.groupedBackground)
    }
}

// MARK: - Subviews

private extension PostCategoryDetailView {
    
    var postsTabView: some View {
        TabView(selection: $model.currentFilter) {
            ScrollView {
                PostGrid(router: router, postGridType: .posts(model.posts), isLoading: $model.isLoading)

            }
            .tag(CategoryExploreFilter.hot)
            
            ScrollView {
                PostGrid(router: router, postGridType: .posts(model.posts), isLoading: $model.isLoading)

            }
            .tag(CategoryExploreFilter.new)
            
        }
#if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
#endif
    }
    
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostCategoryDetailView(router: FeedViewRouter(), category: .affirmations)
        }
    }
}
