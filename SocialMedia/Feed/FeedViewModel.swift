//
//  FeedViewModel.swift
//  SocialMedia
//

import SwiftUI
import Combine
import SocialMediaNetwork
import Firebase

@MainActor
final class FeedViewModel: ObservableObject {
    @Published var forYouPosts = [Post]()
    @Published var followingPosts = [Post]()
    @Published var isLoading = false
    @Published var currentFilter: FeedFilter = .forYou
    var itemsPerPage: Int = 10
    
    private var noMoreItemsToFetch: Bool = false
    private var lastForYouPostDocument: DocumentSnapshot?
    private var lastFollowingPostDocument: DocumentSnapshot?
    private var cancellables = Set<AnyCancellable>()
    
    func addListenersForFeed() {
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
    
    func fetchFeedForCurrentFilter() async throws {
        switch currentFilter {
        case .forYou:
            try await fetchForYouPosts()
        case .following:
            try await fetchFollowingPosts()
        }
    }
    
    func refreshFeedForCurrentFilter() async throws {
        switch currentFilter {
        case .forYou:
            try await refreshForYouFeed()
        case .following:
            try await refreshFollowingFeed()
        }
    }
}

private extension FeedViewModel {
    func add(_ post: Post) async throws {
        guard !forYouPosts.contains(where: { $0.id == post.id }),
              let index = self.forYouPosts.firstIndex(where: { $0.id != post.id }) else { return }
        
        let userDataPost = try await self.fetchPostUserData(post: post)
        withAnimation {
            self.forYouPosts.insert(userDataPost, at: index)
        }
    }
    
    func modify(_ post: Post) async throws {
        guard let index = forYouPosts.firstIndex(where: { $0.id == post.id }) else { return }
        let userDataPost = try await self.fetchPostUserData(post: post)
        guard forYouPosts[index].id == post.id, forYouPosts[index] != userDataPost else { return }
        
        if forYouPosts[index].likes != post.likes {
            forYouPosts[index].likes = post.likes
        }
        if forYouPosts[index].replies != post.replies {
            forYouPosts[index].replies = post.replies
        }
        if forYouPosts[index].reposts != post.reposts {
            forYouPosts[index].reposts = post.reposts
        }
    }
    
    func remove(_ post: Post) {
        withAnimation {
            forYouPosts.removeAll(where: { $0.id == post.id })
        }
    }
    
    func refreshForYouFeed() async throws {
        forYouPosts.removeAll()
        noMoreItemsToFetch = false
        lastForYouPostDocument = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        try await fetchForYouPosts()
    }
    
    func refreshFollowingFeed() async throws {
        followingPosts.removeAll()
        noMoreItemsToFetch = false
        lastFollowingPostDocument = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        try await fetchFollowingPosts()
    }
    
    func fetchForYouPosts() async throws {
        guard !noMoreItemsToFetch else {
            addListenersForFeed()
            return
        }
        isLoading = true
        
        let (newPosts, lastPostDocument) = try await PostService.fetchForYouPosts(countLimit: itemsPerPage, descending: true, lastDocument: lastForYouPostDocument)
        
        guard !newPosts.isEmpty else {
            self.noMoreItemsToFetch = true
            self.isLoading = false
            self.lastForYouPostDocument = nil
            self.addListenersForFeed()
            return
        }
        
        do {
            try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
                guard let self = self else {
                    self?.isLoading = false
                    self?.addListenersForFeed()
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
                    self.lastForYouPostDocument = lastPostDocument
                    self.noMoreItemsToFetch = false
                } else {
                    self.noMoreItemsToFetch = true
                    self.lastForYouPostDocument = nil
                }
                self.forYouPosts.append(contentsOf: userDataPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
                
                self.isLoading = false
                self.addListenersForFeed()
            }
        } catch {
            print("Error fetching for you posts: \(error)")
        }
    }
    
    func fetchFollowingPosts() async throws {
        guard !noMoreItemsToFetch else { return }
        isLoading = true
        
        let (newPostIDs, lastDocument) = try await PostService.fetchUserFollowingPosts(countLimit: itemsPerPage, descending: true, lastDocument: lastFollowingPostDocument)
        
        do {
            try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
                guard let self = self else { return }
                var followingPosts = [Post]()
                
                guard !newPostIDs.isEmpty else {
                    self.noMoreItemsToFetch = true
                    self.isLoading = false
                    return
                }
                for postID in newPostIDs {
                    group.addTask { try await PostService.fetchPost(postID: postID) }
                }
                for try await post in group {
                    followingPosts.append(try await fetchPostUserData(post: post))
                }
                if let lastDocument {
                    self.lastFollowingPostDocument = lastDocument
                    self.noMoreItemsToFetch = false
                } else {
                    self.noMoreItemsToFetch = true
                }
                
                self.followingPosts.append(contentsOf: followingPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
                self.isLoading = false
            }
        } catch {
            print("Error fetching following posts: \(error)")
        }
    }
    
    func fetchPostUserData(post: Post) async throws -> Post {
        var result = post
        async let user = try await UserService.fetchUser(userID: post.ownerUID)
        result.user = try await user
        
        return result
    }
}
