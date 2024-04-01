//
//  PostButtonGroupViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

@MainActor
final class PostButtonGroupViewModel: ObservableObject {
    @Published var post: Post?
    @Published var reply: Reply?
    
    var postType: PostType
    
    @Published var temporaryRepostCount: Int = 0
    
    var numberOfLikes: Int {
        switch postType {
        case .post:
            post?.likes ?? 0
        case .reply:
            reply?.likes ?? 0
        }
    }
    
    var numberOfReplies: Int {
        switch postType {
        case .post:
            post?.replies ?? 0
        case .reply:
            reply?.replies ?? 0
        }
    }
    
    var didLike: Bool {
        switch postType {
        case .post:
            post?.didLike ?? false
        case .reply:
            reply?.didLike ?? false
        }
    }
    
    var didSave: Bool {
        switch postType {
        case .post:
            post?.didSave ?? false
        case .reply:
            reply?.didSave ?? false
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
    }
    
    func likePost() async throws {
        switch postType {
        case .post:
            guard var post = post else { return }
            
            post.didLike = true
            post.likes += 1
            try await PostService.likePost(post)
            
        case .reply:
            guard var reply = reply else { return }
            
            reply.didLike = true
            reply.likes += 1
            try await ReplyService.likeReply(reply)
        }
    }
    
    func unlikePost() async throws {
        switch postType {
        case .post:
            guard var post = post else { return }
            
            post.didLike = false
            post.likes -= 1
            try await PostService.unlikePost(post)
            
        case .reply:
            guard var reply = reply else { return }
            
            reply.didLike = false
            reply.likes -= 1
            try await ReplyService.unlikeReply(reply)
        }
    }
    
    func savePost() async throws {
        switch postType {
        case .post(var post):
            post.didSave = true
            try await PostService.savePost(post)
            
        case .reply(var reply):
            reply.didSave = true
            try await ReplyService.saveReply(reply)
        }
    }
    
    func unsavePost() async throws {
        switch postType {
        case .post(var post):
            post.didSave = false
            try await PostService.unsavePost(post)
            
        case .reply(var reply):
            reply.didSave = false
            try await ReplyService.unsaveReply(reply)
        }
    }
    
    func checkIfUserLikedPost() async throws {
        switch postType {
        case .post:
            guard let post = post else { return }
            
            if try await PostService.checkIfUserLikedPost(post) {
                self.post?.didLike = true
            }
            
        case .reply:
            guard let reply = reply else { return }
            
            if try await ReplyService.checkIfUserLikedReply(reply) {
                self.reply?.didLike = true
            }
        }
    }
    
    func checkIfUserSavedPost() async throws {
        switch postType {
        case .post:
            guard let post = post else { return }
            
            if try await PostService.checkIfUserSavedPost(post) {
                self.post?.didSave = true
            }
            
        case .reply:
            guard let reply = reply else { return }
            
            if try await ReplyService.checkIfUserSavedReply(reply) {
                self.reply?.didSave = true
            }
        }
    }
    
    static func deletePost(_ post: Post) async throws {
        guard post.user?.isCurrentUser != nil else { return }
        try await PostService.deletePost(post)
    }
    
    static func deleteReply(_ reply: Reply) async throws {
        guard reply.user?.isCurrentUser != nil else { return }
        let post = try await PostService.fetchPost(postID: reply.postID)
        try await ReplyService.deleteReply(for: reply.postID, maxReplyDepthLevel: post.replyDepthLevel)
    }
}
