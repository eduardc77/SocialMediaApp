//
//  UserPostsViewModel.swift
//  SocialMedia
//

import SwiftUI
import Combine
import SocialMediaNetwork
import Firebase

@MainActor
final class UserPostsViewModel: ObservableObject {
    var user: SocialMediaNetwork.User
    
    @Published var posts = [Post]()
    @Published var isLoading = false
    
    var itemsPerPage: Int = 10
    
    private var noMoreItemsToFetch: Bool = false
    private var lastPostDocument: DocumentSnapshot?
    private var cancellables = Set<AnyCancellable>()
    
    init(user: SocialMediaNetwork.User) {
        self.user = user
    }
    
    func addListenerForUpdates() {
        PostService.addListenerForFeed()
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
    
    func loadMorePosts() async throws {
        guard !noMoreItemsToFetch, let userID = user.id else {
            addListenerForUpdates()
            return
        }
        isLoading = true
        
        let (newPosts, lastPostDocument) = try await PostService.fetchUserPosts(userID: userID, countLimit: itemsPerPage, descending: true, lastDocument: self.lastPostDocument)
        
        guard !newPosts.isEmpty else {
            self.noMoreItemsToFetch = true
            self.isLoading = false
            self.lastPostDocument = nil
            self.addListenerForUpdates()
            return
        }
        try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
            guard let self = self else {
                self?.isLoading = false
                self?.addListenerForUpdates()
                return
            }
            var userDataPosts = [Post]()
            
            for post in newPosts {
                group.addTask { return try await self.fetchPostUserData(post: post) }
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
            
            self.isLoading = false
            self.addListenerForUpdates()
        }
    }
}

private extension UserPostsViewModel {
    func add(_ post: Post) async throws {
        guard !self.posts.contains(where: { $0.id == post.id }),
              let index = self.posts.firstIndex(where: { $0.id != post.id }) else { return }
        
        let userDataPost = try await self.fetchPostUserData(post: post)
        withAnimation {
            self.posts.insert(userDataPost, at: index)
        }
    }
    
    func modify(_ post: Post) async throws {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        
        guard posts[index].id == post.id, posts[index] != post else { return }
        
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
    
    func refresh() async throws {
        posts.removeAll()
        noMoreItemsToFetch = false
        lastPostDocument = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        try await loadMorePosts()
    }
    
    func fetchPostUserData(post: Post) async throws -> Post {
        var result = post
        
        async let user = try await UserService.fetchUser(userID: post.ownerUID)
        result.user = try await user
        
        return result
    }
}
