//
//  UserLikedPostsViewModel.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork
import Firebase

@MainActor
final class UserLikedPostsViewModel: FeedViewModel {
    var user: SocialMediaNetwork.User
    
    init(user: SocialMediaNetwork.User) {
        self.user = user
        super.init()
        self.listenForAddUpdates = false
    }
    
    func addListenerForLikedPosts() {
        guard let userID = user.id else { return }
        
        PostService.addListenerForLikedPosts(forUserID: userID)
            .sink { completion in
                
            } receiveValue: { [weak self] documentChangeType, lastDocument in
                guard let self = self else { return }
                
                Task {
                    switch documentChangeType {
                    case .added(let postID):
                        try await self.addPost(with: postID)
                    case .removed(let postID):
                        withAnimation {
                            self.posts.removeAll(where: { $0.id == postID })
                        }
                        
                    default: break
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func addPost(with postID: String) async throws {
        guard !posts.contains(where: { $0.id == postID }) else { return }
        
        let post = try await PostService.fetchPost(postID: postID)
        let userDataPost = try await self.fetchPostUserData(post: post)
        
        if !posts.contains(where: { $0.id == post.id }) {
            withAnimation {
                self.posts.insert(userDataPost, at: 0)
            }
        }
    }
    
    func addListenersForPostUpdates() {
        addListenerForPostUpdates()
        addListenerForLikedPosts()
    }

    func loadMorePosts() async throws {
        guard !noMoreItemsToFetch, let userID = user.id else {
            return
        }
        isLoading = true
        
        let (newPostIDs, lastPostDocument) = try await PostService.fetchUserLikedPosts(userID: userID, countLimit: itemsPerPage, lastDocument: self.lastPostDocument)
        
        guard !newPostIDs.isEmpty else {
            self.noMoreItemsToFetch = true
            self.isLoading = false
            self.lastPostDocument = nil
            return
        }
        
        do {
            try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
                guard let self = self else {
                    self?.isLoading = false
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
            }
        } catch {
            print("Error fetching user liked posts: \(error)")
        }
    }

    func refresh() async throws {
        reset()
        try await loadMorePosts()
    }
}
