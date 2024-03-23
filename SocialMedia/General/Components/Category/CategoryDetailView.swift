//
//  CategoryDetailView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct CategoryDetailView: View {
    @StateObject var viewModel: CategoryViewModel
    
    init(category: PostCategory) {
        _viewModel = StateObject(wrappedValue: CategoryViewModel(category: category))
    }
    
    var body: some View {
        VStack {
            CategoryFilter(filter: $viewModel.currentFilter) { newFilter in
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

private extension CategoryDetailView {
    
    var postsTabView: some View {
        TabView(selection: $viewModel.currentFilter) {
            ScrollView {
                ContentGrid(contentGridType: .posts(viewModel.posts), pageCount: .constant(0), isLoading: $viewModel.isLoading)
            }
            .tag(CategoryExploreFilter.hot)
            .overlay {
                if viewModel.isLoading { ProgressView() }
            }
            
            ScrollView {
                ContentGrid(contentGridType: .posts(viewModel.posts), pageCount: .constant(0), isLoading: $viewModel.isLoading)
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
            CategoryDetailView(category: .affirmations)
        }
    }
}
