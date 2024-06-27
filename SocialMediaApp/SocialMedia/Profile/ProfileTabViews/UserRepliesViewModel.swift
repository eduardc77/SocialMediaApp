//
//  UserRepliesViewModel.swift
//  SocialMedia
//

import Observation
import SwiftUI
import Combine
import SocialMediaNetwork
import Firebase

@MainActor
@Observable final class UserRepliesViewModel {
    var user: SocialMediaNetwork.User
    
    var replies = [Reply]()
    var loading = false
    var refreshed: ProfilePostFilter = .replies
    
    var itemsPerPage: Int = 10
    var noMoreItemsToFetch: Bool = false
    
    private var lastPostDocument: DocumentSnapshot?
    private var cancellables = Set<AnyCancellable>()
    
    init(user: SocialMediaNetwork.User) {
        self.user = user
    }
    
    //    func addListenerForPostUpdates() {
    //        guard let userID = user.id else { return }
    //
    //        PostService.addListenerForUserReplies(forUserID: userID)
    //            .sink { completion in
    //
    //            } receiveValue: { [weak self] documentChangeType, lastDocument in
    //                guard let self = self else { return }
    //
    //                Task {
    //                    switch documentChangeType {
    //                    case .added(let reply):
    //                        try await self.add(reply)
    //
    //                    case .modified(let reply):
    //                        try await self.modify(reply)
    //
    //                    case .removed(let reply):
    //                        self.remove(reply)
    //
    //                    case .none: break
    //                    }
    //                }
    //            }
    //            .store(in: &cancellables)
    //    }
    
    func loadMoreReplies() async {
        guard !noMoreItemsToFetch, let userID = user.id, !userID.isEmpty else {
            return
        }
        loading = true

        do {
            let (newReplies, lastPostDocument) = try await ReplyService.fetchPostReplies(forUser: user, countLimit: itemsPerPage, descending: true, lastDocument:  self.lastPostDocument)
            
            guard !newReplies.isEmpty else {
                self.noMoreItemsToFetch = true
                self.loading = false
                self.lastPostDocument = nil
                return
            }
            
            try await withThrowingTaskGroup(of: Reply.self) { [weak self] group in
                guard let self = self else {
                    self?.loading = false
                    return
                }
                var userDataPosts = [Reply]()
                
                for reply in newReplies {
                    group.addTask {
                        try await self.fetchReplyUserData(reply: reply)
                    }
                }
                for try await reply in group {
                    userDataPosts.append(reply)
                }
                
                if let lastPostDocument {
                    self.lastPostDocument = lastPostDocument
                    self.noMoreItemsToFetch = false
                } else {
                    self.noMoreItemsToFetch = true
                    self.lastPostDocument = nil
                }
                self.replies.append(contentsOf: userDataPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
                
                for var reply in self.replies {
                    if let post = try await self.fetchReplyPostData(reply: reply) {
                        reply.post = post
                    }
                }
                
                self.loading = false
            }
        } catch {
            print("Error fetching user replies: \(error)")
        }
    }
    
    func refresh() async {
        replies.removeAll()
        noMoreItemsToFetch = false
        lastPostDocument = nil
        await loadMoreReplies()
    }
}

// MARK: - Private Methods

private extension UserRepliesViewModel {
    
    func add(_ reply: Reply) async throws {
        guard !replies.contains(where: { $0.id == reply.id }) else { return }
        
        let userDataPost = try await self.fetchReplyUserData(reply: reply)
        if userDataPost.ownerUID == reply.ownerUID, (!replies.contains(where: { $0.id == reply.id })  || replies.isEmpty) {
            withAnimation {
                self.replies.insert(userDataPost, at: 0)
            }
        }
    }
    
    func modify(_ reply: Reply) async throws {
        guard let index = replies.firstIndex(where: { $0.id == reply.id }), replies[index].id == reply.id else { return }
        
        let userDataPost = try await self.fetchReplyUserData(reply: reply)
        guard replies[index] != userDataPost else { return }
        
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
    
    func fetchReplyUserData(reply: Reply) async throws -> Reply {
        var result = reply
        
        async let user = try await UserService.fetchUser(userID: reply.ownerUID)
        result.user = try await user
        
        return result
    }
    
    func fetchReplyPostData(reply: Reply) async throws -> Post? {
        guard let replyIndex = replies.firstIndex(where: { $0.id == reply.id }) else { return nil }
        
        async let post = try await PostService.fetchPost(postID: reply.postID)
        
        let postOwnerUID = try await post.ownerUID
        async let user = try await UserService.fetchUser(userID: postOwnerUID)
        
        var postCopy = try await post
        postCopy.user = try await user
        replies[replyIndex].post = postCopy
        
        return postCopy
    }
}
