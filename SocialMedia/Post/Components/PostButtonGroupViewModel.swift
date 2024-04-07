//
//  PostButtonGroupViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

@MainActor
final class PostButtonGroupViewModel: ObservableObject {
    var postType: PostType
    
    @Published var temporaryRepostCount: Int = 0
    
    var numberOfLikes: Int {
        switch postType {
        case .post(let post):
            post.likes
        case .reply(let reply):
            reply.likes
        }
    }
    
    var numberOfReplies: Int {
        switch postType {
        case .post(let post):
            post.replies
        case .reply(let reply):
            reply.replies
        }
    }
    
    var numberOfReposts: Int {
        switch postType {
        case .post(let post):
            post.reposts
        case .reply(let reply):
            reply.reposts
        }
    }
    
    // MARK: - Lifecycle
    
    init(postType: PostType) {
        self.postType = postType
    }
    
    // MARK: - Like
    
    func likePost() async throws {
        switch postType {
        case .post(let post):
            try await PostService.likePost(post)
        case .reply(let reply):
            try await ReplyService.likeReply(reply)
            
        }
    }
    
    func unlikePost() async throws {
        switch postType {
        case .post(let post):
            guard post.likes > 0 else { return }
            try await PostService.unlikePost(post)
            
        case .reply(let reply):
            guard reply.likes > 0 else { return }
            try await ReplyService.unlikeReply(reply)
        }
    }
    
    
    // MARK: - Save
    
    func savePost() async throws {
        switch postType {
        case .post(let post):
            try await PostService.savePost(post)
        case .reply(let reply):
            try await ReplyService.saveReply(reply)
        }
    }
    
    func unsavePost() async throws {
        switch postType {
        case .post(let post):
            try await PostService.unsavePost(post)
        case .reply(let reply):
            try await ReplyService.unsaveReply(reply)
        }
    }
    
    // MARK: - Delete
    
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

// MARK: - Check User Activity

extension PostButtonGroupViewModel {
    
    func didUserLike(post: Post) async throws -> Bool {
        try await PostService.checkIfUserLikedPost(post)
    }
    
    func didUserLike(reply: Reply) async throws -> Bool {
        try await ReplyService.checkIfUserLikedReply(reply)
    }
    
    func didUserSave(post: Post) async throws -> Bool {
        try await PostService.checkIfUserSavedPost(post)
    }
    
    func didUserSave(reply: Reply) async throws -> Bool {
        try await ReplyService.checkIfUserSavedReply(reply)
    }
}
