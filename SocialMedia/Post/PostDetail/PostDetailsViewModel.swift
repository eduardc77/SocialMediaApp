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
    var contentUnavailableText = "Be the first to reply."
    
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
        guard !noMoreItemsToFetch else { return }
        
        isLoading = true
        var (newReplies, lastReplyDocument): ([Reply], DocumentSnapshot?)
        
        switch postType {
        case .post:
            guard let post = post else { return }
            (newReplies, lastReplyDocument) = try await ReplyService.fetchPostReplies(forPost: post, countLimit: itemsPerPage, lastDocument: lastDocument)
    
        case .reply:
            guard let reply = reply else { return }
            (newReplies, lastReplyDocument) = try await ReplyService.fetchReplyReplies(forReply: reply, countLimit: itemsPerPage, lastDocument: lastDocument)
        }
        
        guard !newReplies.isEmpty else {
            self.noMoreItemsToFetch = true
            self.isLoading = false
            self.lastDocument = nil
            return
        }
        
        do {
            try await withThrowingTaskGroup(of: Reply.self) { [weak self] group in
                guard let self = self else {
                    self?.isLoading = false
                    print("DEBUG: FeedViewModel object not found.")
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
                
            }
        } catch {
            print("Error fetching post replies: \(error)")
        }
    }
    
    func fetchUserData(for reply: Reply) async throws -> Reply {
        var result = reply
        async let user = try await UserService.fetchUser(userID: reply.ownerUID)
        result.user = try await user
        
        return result
    }
    
    func addListenerForReplyUpdates(depthLevel: Int = 0) {
        var repliedPostID: String = ""
        
        if let postID = post?.id {
            repliedPostID = postID
        } else if let replyID = reply?.id {
            repliedPostID = replyID
        }
        guard !repliedPostID.isEmpty else { return }
        
        ReplyService.addListenerForPostReplies(postID: repliedPostID, depthLevel: depthLevel)
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
    
    
    func refresh() async throws {
        replies.removeAll()
        noMoreItemsToFetch = false
        lastDocument = nil
        try await loadMoreReplies()
    }
}

private extension PostDetailsViewModel {
    func add(_ reply: Reply) async throws {
        guard !self.replies.contains(where: { $0.id == reply.id }) else { return }
        
        let userDataReply = try await self.fetchUserData(for: reply)
        
        if !replies.contains(where: { $0.id == reply.id }) || replies.isEmpty {
            withAnimation {
                self.replies.insert(userDataReply, at: 0)
            }
        }
    }
    
    func modify(_ reply: Reply) async throws {
        guard let index = replies.firstIndex(where: { $0.id == reply.id }) else { return }
        
        guard replies[index].id == reply.id, replies[index] != reply else { return }
        
                if replies[index].likes != reply.likes {
                    replies[index].likes = reply.likes
                }
                if replies[index].replies != reply.replies {
                    replies[index].replies = reply.replies
                }
                if replies[index].reposts != reply.reposts {
                    replies[index].reposts = reply.reposts
                }
    }
    
    func remove(_ reply: Reply) {
        withAnimation {
            replies.removeAll(where: { $0.id == reply.id })
        }
    }
}
