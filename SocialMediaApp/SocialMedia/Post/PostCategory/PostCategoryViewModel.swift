//
//  PostCategoryViewModel.swift
//  SocialMedia
//

import SwiftUI
import Combine
import SocialMediaNetwork
import SocialMediaUI
import Firebase

@Observable final class PostCategoryViewModel {
    let category: PostCategory
    
    var posts = [Post]()
    var currentFilter: CategoryFilter = .hot
    var loading = false
    
    var itemsPerPage: Int = 10
    var noMoreItemsToFetch: Bool = false
    
    private var lastPostDocument: DocumentSnapshot?
    private var cancellables = Set<AnyCancellable>()
    
    init(category: PostCategory) {
        self.category = category
    }
    
    func addListenerForPostUpdates() {
        PostService.addListenerForPostsByCategory(category)
            .sink { completion in
                
            } receiveValue: { [weak self] documentChangeType, lastDocument in
                guard let self = self else { return }
                
                Task {
                    switch documentChangeType {
                    case .added(let post):
                        try await self.add(post)
                        
                    case .modified(let post):
                        try await self.modify(post)
                        
                    case .removed(let post):
                        self.remove(post)
                        
                    case .none: break
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func loadMorePosts() async {
        guard !noMoreItemsToFetch else {
            return
        }
        loading = true

        do {
            let (newPosts, lastPostDocument) = try await PostService.fetchPosts(by: category, countLimit: itemsPerPage, descending: true, lastDocument: lastPostDocument)
            guard !newPosts.isEmpty else {
                self.noMoreItemsToFetch = true
                self.loading = false
                self.lastPostDocument = nil
                return
            }
            
            try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
                guard let self = self else {
                    self?.loading = false
                    return
                }
                var userDataPosts = [Post]()
                
                for post in newPosts {
                    group.addTask { try await self.fetchPostUserData(post: post) }
                }
                for try await post in group {
                    userDataPosts.append(post)
                }
                
                if let lastPostDocument {
                    self.lastPostDocument = lastPostDocument
                    self.noMoreItemsToFetch = false
                } else {
                    self.noMoreItemsToFetch = true
                    self.lastPostDocument = nil
                }
                self.posts.append(contentsOf: userDataPosts)
                sortPosts()
                self.loading = false
            }
        } catch {
            print("Error fetching for you posts: \(error)")
        }
    }
    
    func refresh() async {
        posts.removeAll()
        noMoreItemsToFetch = false
        lastPostDocument = nil
        await loadMorePosts()
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

// MARK: - Private Methods

private extension PostCategoryViewModel {
    
    func add(_ post: Post) async throws {
        guard !posts.contains(where: { $0.id == post.id }) else { return }
        
        let userDataPost = try await self.fetchPostUserData(post: post)
        if userDataPost.ownerUID == post.ownerUID, (!posts.contains(where: { $0.id == post.id })  || posts.isEmpty) {
            withAnimation {
                self.posts.insert(userDataPost, at: 0)
            }
        }
    }
    
    func modify(_ post: Post) async throws {
        guard let index = posts.firstIndex(where: { $0.id == post.id }), posts[index].id == post.id else { return }
        
        let userDataPost = try await self.fetchPostUserData(post: post)
        guard posts[index] != userDataPost else { return }
        
        if posts[index].likes != post.likes {
            posts[index].likes = post.likes
        }
        if posts[index].replies != post.replies {
            posts[index].replies = post.replies
        }
        if posts[index].reposts != post.reposts {
            posts[index].reposts = post.reposts
        }
    }
    
    func remove(_ post: Post) {
        withAnimation {
            posts.removeAll(where: { $0.id == post.id })
        }
    }
    
    func fetchPostUserData(post: Post) async throws -> Post {
        var result = post
        
        async let user = try await UserService.fetchUser(userID: post.ownerUID)
        result.user = try await user
        
        return result
    }
}
