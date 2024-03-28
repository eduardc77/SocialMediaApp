//
//  PostDetailsViewModel.swift
//  SocialMedia
//

import SwiftUI
import Combine
import Firebase
import SocialMediaNetwork

@MainActor
final class PostDetailsViewModel: ObservableObject {
    @Published var post: Post
    @Published var replies = [PostReply]()
    @Published var isLoading = false
    
    var itemsPerPage: Int = 10
    private var noMoreItemsToFetch: Bool = false
    private var lastDocument: DocumentSnapshot?
    
    private var cancellables = Set<AnyCancellable>()
 
    init(post: Post) {
        self.post = post
        setPostUserIfNecessary()
        
    }
    
    private func setPostUserIfNecessary() {
        guard post.user == nil else { return }
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        if post.ownerUID == currentUID {
            post.user = UserService.shared.currentUser
        }
    }
    
    func loadMoreReplies() async throws {
        guard !noMoreItemsToFetch else {
            addListenerForPostReplies()
            return
        }
        isLoading = true

        let (newReplies, lastReplyDocument) = try await PostService.fetchPostReplies(forPost: post, countLimit: itemsPerPage, descending: true, lastDocument: lastDocument)
  
        guard !newReplies.isEmpty else {
            self.noMoreItemsToFetch = true
            self.isLoading = false
            self.lastDocument = nil
            self.addListenerForPostReplies()
            return
        }
        try await withThrowingTaskGroup(of: PostReply.self) { [weak self] group in
            guard let self = self else {
                self?.isLoading = false
                print("FeedViewModel object not found.")
                self?.addListenerForPostReplies()
                return
            }
            var userDataReplies = [PostReply]()
            
            for reply in newReplies {
                group.addTask { return try await self.fetchUserData(for: reply) }
            }
            for try await post in group {
                userDataReplies.append(post)
            }
            
            if let lastReplyDocument {
                self.lastDocument = lastReplyDocument
                self.noMoreItemsToFetch = false
            } else {
                self.noMoreItemsToFetch = true
                self.lastDocument = nil
            }
            self.replies.append(contentsOf: userDataReplies.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
            
            self.isLoading = false
            self.addListenerForPostReplies()
        }
    }
    
    func fetchUserData(for reply: PostReply) async throws -> PostReply {
        var result = reply
        
        async let user = try await UserService.fetchUser(userID: post.ownerUID)
        result.replyUser = try await user
        
        return result
    }

    @MainActor
    func addListenerForPostReplies() {
        guard let userID = post.user?.id else { return }
    
        PostService.addListenerForPostReplies(forUserID: userID)
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
    
    
    func refreshReplies() async throws {
        replies.removeAll()
        noMoreItemsToFetch = false
        lastDocument = nil
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        try await loadMoreReplies()
    }
//
//    func fetchFeedForCurrentFilter() async throws {
//        switch currentFilter {
//        case .forYou:
//            try await fetchForYouPosts()
//        case .following:
//            try await fetchFollowingPosts()
//        }
//    }
//
    func refreshFeedForCurrentFilter() async throws {
//        switch currentFilter {
//        case .forYou:
//            try await refreshForYouFeed()
//        case .following:
//            try await refreshFollowingFeed()
//        }
    }
}

private extension PostDetailsViewModel {
    func add(_ reply: PostReply) async throws {
        guard !self.replies.contains(where: { $0.id == reply.id }),
              let index = self.replies.firstIndex(where: { $0.id != reply.id }) else { return }
        
        let userDataReply = try await self.fetchUserData(for: reply)
        withAnimation {
            self.replies.insert(userDataReply, at: index)
        }
    }
    
    func modify(_ reply: PostReply) async throws {
        guard let index = replies.firstIndex(where: { $0.id == reply.id }) else { return }
        
        guard replies[index].id == reply.id, replies[index] != reply else { return }
        
//        if replies[index].replyText != reply.replyText {
//            replies[index].replyText = reply.replyText
//        }
        //...
    }
    
    func remove(_ reply: PostReply) {
        withAnimation {
            replies.removeAll(where: { $0.id == reply.id })
        }
    }
}
