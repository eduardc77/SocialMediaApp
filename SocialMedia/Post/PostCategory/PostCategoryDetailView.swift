//
//  PostCategoryDetailView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct PostCategoryDetailView: View {
    @StateObject var viewModel: PostCategoryViewModel
    
    init(category: PostCategory) {
        _viewModel = StateObject(wrappedValue: PostCategoryViewModel(category: category))
    }
    
    var body: some View {
        VStack {
            PostCategoryFilter(filter: $viewModel.currentFilter) { newFilter in
                viewModel.currentFilter = newFilter
                viewModel.sortPosts()
            }
                        postsTabView
        }
        .navigationBar(title: "\(viewModel.category.icon) \(viewModel.category.rawValue.capitalized)")
        .background(Color.groupedBackground)
    }
}

// MARK: - Subviews

private extension PostCategoryDetailView {
    
    var postsTabView: some View {
        TabView(selection: $viewModel.currentFilter) {
            ScrollView {
                PostGrid(postGridType: .posts(viewModel.posts), isLoading: $viewModel.isLoading)
            }
            .tag(CategoryExploreFilter.hot)
            .overlay {
                if viewModel.isLoading { ProgressView() }
            }
            
            ScrollView {
                PostGrid(postGridType: .posts(viewModel.posts), isLoading: $viewModel.isLoading)
            }
            .tag(CategoryExploreFilter.new)
            .overlay {
                if viewModel.isLoading { ProgressView() }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
}

struct CategoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PostCategoryDetailView(category: .affirmations)
        }
    }
}
