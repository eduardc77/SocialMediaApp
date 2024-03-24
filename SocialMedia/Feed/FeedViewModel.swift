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
    var lastForYouPostDocument: DocumentSnapshot?
    private var lastFollowingPostDocument: DocumentSnapshot?
    private var cancellables = Set<AnyCancellable>()
    
    @Published var pageCount: Int = 0
    
    func addListenersForFeed() {
        
        if !PostService.feedListenerRemoved {
            removeListener()
        }
        
        PostService.addListenerForFeed(countLimit: itemsPerPage, lastDocument: lastForYouPostDocument)
            .sink { completion in
                
            } receiveValue: { [weak self] documentChangeType, lastDocument in
                guard let self = self else { return }
                
                Task { @MainActor in
                    self.isLoading = true
                    
                    switch documentChangeType {
                    case .added(let post):
                        if !self.forYouPosts.contains(where: { $0.id == post.id }),
                           let index = self.forYouPosts.firstIndex(where: { $0.id != post.id }) {
                            let userDataPost = try await self.fetchPostUserData(post: post)
                            withAnimation {
                                self.forYouPosts.insert(userDataPost, at: index)
                            }
                        }
                        
                    case .modified(let post):
                        if let index = self.forYouPosts.firstIndex(where: { $0.id == post.id }) {
                            try await self.modify(post, at: index)
                        }
                        
                    case .removed(let post):
                        withAnimation {
                            self.delete(post)
                        }
                        
                    case .none:
                        print("NONE")
                    }
                    self.isLoading = false
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
    
    func removeListener() {
        PostService.removeListenerForFeed()
    }
}

private extension FeedViewModel {
    func add(_ post: Post) {
        
    }
    
    func modify(_ post: Post, at index: Int) async throws {
        if forYouPosts[index].id == post.id, forYouPosts[index] != post {
            forYouPosts[index] = try await fetchPostUserData(post: post)
        }
    }
    
    func delete(_ post: Post) {
        forYouPosts.removeAll(where: { $0.id == post.id })
    }
    
    func refreshForYouFeed() async throws {
        forYouPosts.removeAll()
        noMoreItemsToFetch = false
        lastForYouPostDocument = nil
        pageCount = 0
        cancellables.removeAll()
        try await fetchForYouPosts()
    }
    
    func refreshFollowingFeed() async throws {
        followingPosts.removeAll()
        noMoreItemsToFetch = false
        lastFollowingPostDocument = nil
        try await fetchFollowingPosts()
    }
    
    func fetchForYouPosts() async throws {
        guard !noMoreItemsToFetch else {
            if PostService.feedListenerRemoved {
                addListenersForFeed()
            }
            return
        }
        isLoading = true
        removeListener()
        
        let (newPosts, lastDocument) = try await PostService.fetchPosts(countLimit: itemsPerPage, descending: true, lastDocument: lastForYouPostDocument)
        
        try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
            guard let self = self else {
                isLoading = false
                print("FeedViewModel object not found.")
                if PostService.feedListenerRemoved {
                    addListenersForFeed()
                }
                return }
            
            guard !newPosts.isEmpty else {
                self.noMoreItemsToFetch = true
                self.isLoading = false
                self.lastFollowingPostDocument = nil
                
                if PostService.feedListenerRemoved {
                    addListenersForFeed()
                }
                return
            }
            var forYouPosts = [Post]()
            
            for post in newPosts {
                group.addTask { return try await self.fetchPostUserData(post: post) }
            }
            for try await post in group {
                forYouPosts.append(post)
            }
            
            if let lastDocument {
                self.lastForYouPostDocument = lastDocument
                self.noMoreItemsToFetch = false
            } else {
                self.noMoreItemsToFetch = true
                self.lastFollowingPostDocument = nil
            }
            self.forYouPosts.append(contentsOf: forYouPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
            
            self.isLoading = false
            
            if PostService.feedListenerRemoved {
                addListenersForFeed()
            }
        }
    }
    
    func fetchFollowingPosts() async throws {
        guard !noMoreItemsToFetch else { return }
        isLoading = true
        
        let (newPostIDs, lastDocument) = try await PostService.fetchPostIDs(countLimit: itemsPerPage, lastDocument: lastFollowingPostDocument)
        
        try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
            guard let self = self else { return }
            var followingPosts = [Post]()
            
            guard !newPostIDs.isEmpty else {
                self.noMoreItemsToFetch = true
                self.isLoading = false
                return
            }
            for postID in newPostIDs {
                group.addTask { return try await PostService.fetchPost(postID: postID) }
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
    }
    
    func fetchPostUserData(post: Post) async throws -> Post {
        var result = post
        
        async let user = try await UserService.fetchUser(withUID: post.ownerUID)
        result.user = try await user
        
        return result
    }
}
