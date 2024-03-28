//
//  PostCategoryViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

final class PostCategoryViewModel: ObservableObject {
    let category: PostCategory
    
    @Published var posts: [Post] = []
    @Published var currentFilter: CategoryExploreFilter = .hot
    @Published var isLoading: Bool = false
    
    init(category: PostCategory) {
        self.category = category
        
        Task {
            try await fetchPostsByCategory()
        }
    }
    
    @MainActor
    func fetchPostsByCategory() async throws {
        isLoading = true
        let fetchedPosts = try await PostService.fetchPosts(by: category)
        self.posts = fetchedPosts
        
        for index in posts.indices {
            self.posts[index].user = try await UserService.fetchUser(userID: fetchedPosts[index].ownerUID)
        }
        sortPosts()
        isLoading = false
    }
    
    func sortPosts() {
        posts = posts.sorted {
            switch currentFilter {
                case .hot:
                    return $0.likes > $1.likes
                case .new:
                    return $0.timestamp.dateValue() > $1.timestamp.dateValue()
            }
        }
    }
}

enum CategoryExploreFilter: String, CaseIterable, Hashable {
    case hot
    case new
    
    var title: String {
        rawValue.capitalized
    }
}
