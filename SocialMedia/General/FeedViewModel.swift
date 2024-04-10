//
//  FeedViewModel.swift
//  SocialMedia
//

import SwiftUI
import Combine
import SocialMediaNetwork
import Firebase

@MainActor
class FeedViewModel: ObservableObject {
    @Published var posts = [Post]()
    @Published var loading = false
    var itemsPerPage: Int = 10
    
    var listenForAddUpdates: Bool = true
    var noMoreItemsToFetch: Bool = false
    var lastPostDocument: DocumentSnapshot?
    var cancellables = Set<AnyCancellable>()
    
    func addListenerForPostUpdates() {
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

    func fetchPostUserData(post: Post) async throws -> Post {
        var result = post
        async let user = try await UserService.fetchUser(userID: post.ownerUID)
        result.user = try await user
        
        return result
    }
    
    func reset() {
        posts.removeAll()
        noMoreItemsToFetch = false
        lastPostDocument = nil
    }
}

// MARK: - Private Methods

private extension FeedViewModel {
    
    func add(_ post: Post) async throws {
        guard listenForAddUpdates, !posts.contains(where: { $0.id == post.id }) else { return }
        
        let userDataPost = try await self.fetchPostUserData(post: post)
        if !posts.contains(where: { $0.id == post.id }) || posts.isEmpty {
            withAnimation {
                self.posts.insert(userDataPost, at: 0)
            }
        }
    }
    
    func modify(_ post: Post) async throws {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        let userDataPost = try await self.fetchPostUserData(post: post)
        guard posts[index].id == post.id, posts[index] != userDataPost else { return }
        
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
}
