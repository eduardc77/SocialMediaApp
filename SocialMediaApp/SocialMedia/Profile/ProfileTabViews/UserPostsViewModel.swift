//
//  UserPostsViewModel.swift
//  SocialMedia
//

import Observation
import SwiftUI
import Combine
import SocialMediaNetwork
import Firebase

@MainActor
@Observable final class UserPostsViewModel {
    var user: SocialMediaNetwork.User
    
    var posts = [Post]()
    var loading = false
    
    var itemsPerPage: Int = 10
    var noMoreItemsToFetch: Bool = false
    
    private var lastPostDocument: DocumentSnapshot?
    private var cancellables = Set<AnyCancellable>()
    
    init(user: SocialMediaNetwork.User) {
        self.user = user
    }
    
    func addListenerForPostUpdates() {
        guard let userID = user.id else { return }
        
        PostService.addListenerForUserPosts(forUserID: userID)
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
    
    func loadMorePosts() async {
        guard !noMoreItemsToFetch, let userID = user.id else {
            return
        }
        loading = true

        do {
            let (newPosts, lastPostDocument) = try await PostService.fetchUserPosts(userID: userID, countLimit: itemsPerPage, descending: true, lastDocument: self.lastPostDocument)
            
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
                self.posts.append(contentsOf: userDataPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
                
                self.loading = false
            }
        } catch {
            print("Error fetching user posts: \(error)")
        }
    }
    
    func refresh() async {
        posts.removeAll()
        noMoreItemsToFetch = false
        lastPostDocument = nil
        await loadMorePosts()
    }
}

// MARK: - Private Methods

private extension UserPostsViewModel {
    
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
