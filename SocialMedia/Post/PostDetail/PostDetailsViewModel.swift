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
    @Published var post: Post?
    @Published var reply: Reply?
    
    var postType: PostType
    
    @Published var replies = [Reply]()
    @Published var isLoading = false
    
    var itemsPerPage: Int = 10
    private var noMoreItemsToFetch: Bool = false
    private var lastDocument: DocumentSnapshot?
    
    private var cancellables = Set<AnyCancellable>()
    
     var user: SocialMediaNetwork.User? {
        switch postType {
            case .post:
                return post?.user
            case .reply:
                return reply?.user
        }
    }
    
     var caption: String? {
        switch postType {
            case .post:
                return post?.caption
            case .reply:
                return reply?.replyText
        }
    }
 
    init(postType: PostType) {
        self.postType = postType
        
        switch postType {
        case .post(let post):
            self.post = post
            
        case .reply(let reply):
            self.reply = reply
        }
        setPostUserIfNecessary()
    }
    
    private func setPostUserIfNecessary() {
        switch postType {
        case .post:
            guard post?.user == nil else { return }
            guard let currentUID = Auth.auth().currentUser?.uid else { return }
            
            if post?.ownerUID == currentUID {
                post?.user = UserService.shared.currentUser
            }
        case .reply:
            guard reply?.user == nil else { return }
            guard let currentUID = Auth.auth().currentUser?.uid else { return }
            
            if reply?.ownerUID == currentUID {
                reply?.user = UserService.shared.currentUser
            }
        }
    }
    
    func loadMoreReplies() async throws {
        guard !noMoreItemsToFetch else {
            addListenerForPostReplies()
            return
        }
        isLoading = true
        var (newReplies, lastReplyDocument): ([Reply], DocumentSnapshot?)
        switch postType {
        case .post:
            guard let post = post else { return }
            (newReplies, lastReplyDocument) = try await ReplyService.fetchPostReplies(forPost: post, countLimit: itemsPerPage, descending: true, lastDocument: lastDocument)
    
        case .reply:
            guard let reply = reply else { return }
            (newReplies, lastReplyDocument) = try await ReplyService.fetchReplyReplies(forReply: reply, countLimit: itemsPerPage, descending: true, lastDocument: lastDocument)
        }
        
        guard !newReplies.isEmpty else {
            self.noMoreItemsToFetch = true
            self.isLoading = false
            self.lastDocument = nil
            self.addListenerForPostReplies()
            return
        }
        
        do {
            try await withThrowingTaskGroup(of: Reply.self) { [weak self] group in
                guard let self = self else {
                    self?.isLoading = false
                    print("DEBUG: FeedViewModel object not found.")
                    self?.addListenerForPostReplies()
                    return
                }
                var userDataReplies = [Reply]()
                
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
        } catch {
            print("Error fetching post replies: \(error)")
        }
    }
    
    func fetchUserData(for reply: Reply) async throws -> Reply {
        switch postType {
        case .post:
            var result = reply
            if let post = post {
                async let user = try await UserService.fetchUser(userID: reply.ownerUID)
                result.user = try await user
            }

            return result
        case .reply:
            var result = reply
            if let reply = self.reply {
                async let user = try await UserService.fetchUser(userID: reply.ownerUID)
                result.user = try await user
            }
            return result
        }
    }

    @MainActor
    func addListenerForPostReplies() {
        guard let userID = post?.user?.id else { return }
    
        ReplyService.addListenerForPostReplies(forUserID: userID)
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
    func add(_ reply: Reply) async throws {
        guard !self.replies.contains(where: { $0.id == reply.id }),
              let index = self.replies.firstIndex(where: { $0.id != reply.id }) else { return }
        
        let userDataReply = try await self.fetchUserData(for: reply)
        withAnimation {
            self.replies.insert(userDataReply, at: index)
        }
    }
    
    func modify(_ reply: Reply) async throws {
        guard let index = replies.firstIndex(where: { $0.id == reply.id }) else { return }
        
        guard replies[index].id == reply.id, replies[index] != reply else { return }
        
//        if replies[index].replyText != reply.replyText {
//            replies[index].replyText = reply.replyText
//        }
        //...
    }
    
    func remove(_ reply: Reply) {
        withAnimation {
            replies.removeAll(where: { $0.id == reply.id })
        }
    }
}
