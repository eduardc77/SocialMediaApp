//
//  UserSavedPostsViewModel.swift
//  SocialMedia
//

import SwiftUI
import Combine
import SocialMediaNetwork
import Firebase

@MainActor
final class UserSavedPostsViewModel: ObservableObject {
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
        guard let userID = user.id else { return }
        
        PostService.addListenerForSavedPosts(forUserID: userID)
            .sink { completion in
                
            } receiveValue: { [weak self] documentChangeType, lastDocument in
                guard let self = self else { return }
                
                Task {
                    switch documentChangeType {
                    case .added(let postID):
                        try await self.addPost(with: postID)
                        
                    case .modified(let postID):
                        try await self.modifyPost(with: postID)
                        
                    case .removed(let postID):
                        self.removePost(with: postID)
                        
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
        
        let (newPostIDs, lastPostDocument) = try await PostService.fetchUserSavedPosts(userID: userID, countLimit: itemsPerPage, lastDocument: self.lastPostDocument)
        
        guard !newPostIDs.isEmpty else {
            self.noMoreItemsToFetch = true
            self.isLoading = false
            self.lastPostDocument = nil
            self.addListenerForUpdates()
            return
        }
        
        do {
            try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
                
                guard let self = self else {
                    self?.isLoading = false
                    self?.addListenerForUpdates()
                    return
                }
                var userDataPosts = [Post]()
                
                for postID in newPostIDs {
                    group.addTask { try await PostService.fetchPost(postID: postID) }
                }
                for try await post in group {
                    userDataPosts.append(try await fetchPostUserData(post: post))
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
        } catch {
            print("Error fetching user saved posts: \(error)")
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
}

private extension UserSavedPostsViewModel {
    
    func addPost(with postID: String) async throws {
        guard !self.posts.contains(where: { $0.id == postID }),
              let index = self.posts.firstIndex(where: { $0.id != postID }) else { return }
        
        let post = try await PostService.fetchPost(postID: postID)
        let userDataPost = try await self.fetchPostUserData(post: post)
        withAnimation {
            self.posts.insert(userDataPost, at: index)
        }
    }
    
    func modifyPost(with postID: String) async throws {
        guard let index = posts.firstIndex(where: { $0.id == postID }), posts[index].id == postID else { return }
        
        let post = try await PostService.fetchPost(postID: postID)
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
    
    func removePost(with postID: String) {
        withAnimation {
            posts.removeAll(where: { $0.id == postID })
        }
    }
    
    func fetchPostUserData(post: Post) async throws -> Post {
        
        var result = post
        
        async let user = try await UserService.fetchUser(userID: post.ownerUID)
        result.user = try await user
        
        return result
    }
}

