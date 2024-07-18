//
//  PostButtonGroupViewModel.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct TempPost: Hashable {
    var didLike: Bool = false
    var didSave: Bool = false
    
    var numberOfLikes: Int = 0
    var numberOfReplies: Int = 0
    var numberOfReposts: Int = 0
}

@Observable
final class PostButtonGroupViewModel {
    var postType: PostType
    var tempPost = TempPost()
    var loading: Bool = false
    
    // MARK: - Lifecycle
    
    init(postType: PostType) {
        self.postType = postType
        
        switch postType {
        case .post(let post):
            tempPost.numberOfLikes = post.likes
            tempPost.numberOfReplies = post.replies
            tempPost.numberOfReposts = post.reposts
        case .reply(let reply):
            tempPost.numberOfLikes = reply.likes
            tempPost.numberOfReplies = reply.replies
            tempPost.numberOfReposts = reply.reposts
        }
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

// MARK: - User Activity

extension PostButtonGroupViewModel {
    func likeButtonTapped() async throws {
        guard !loading else { return }
        loading = true
        
        if tempPost.didLike {
            tempPost.didLike = false
            try await unlikePost()
            loading = false
        } else {
            tempPost.didLike = true
            try await likePost()
            loading = false
        }
    }
    
    func saveButtonTapped() async throws {
        guard !loading else { return }
        loading = true
        
        if tempPost.didSave {
            tempPost.didSave = false
            try await unsavePost()
            loading = false
        } else {
            tempPost.didSave = true
            try await savePost()
            loading = false
        }
    }
    
    func checkIfUserLikedPost() async throws {
        switch postType {
        case .post(let post):
            if try await PostService.checkIfUserLikedPost(post) {
                self.tempPost.didLike = true
            } else {
                self.tempPost.didLike = false
            }
        case .reply(let reply):
            if try await ReplyService.checkIfUserLikedReply(reply) {
                self.tempPost.didLike = true
            } else {
                self.tempPost.didLike = false
            }
        }
    }
    
    func checkIfUserSavedPost() async throws {
        switch postType {
        case .post(let post):
            if try await PostService.checkIfUserSavedPost(post) {
                self.tempPost.didSave = true
            } else {
                self.tempPost.didSave = false
            }
        case .reply(let reply):
            if try await ReplyService.checkIfUserSavedReply(reply) {
                self.tempPost.didSave = true
            } else {
                self.tempPost.didSave = false
            }
        }
    }
    
    func checkForUserActivity() async {
        do {
            loading = true
            try await checkIfUserLikedPost()
            try await checkIfUserSavedPost()
            loading = false
        } catch {
            print("DEBUG: Failed to check for user post activity.")
            loading = false
        }
    }
}
