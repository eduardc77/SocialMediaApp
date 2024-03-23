//
//  ContentButtonsViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

@MainActor
final class ContentButtonsViewModel: ObservableObject {
    @Published var post: Post?
    @Published var reply: PostReply?

    @Published var temporaryRepostCount: Int = 0
    
    var didLike: Bool {
        post?.didLike ?? false
    }
    
    var didSave: Bool {
        return post?.didSave ?? false
    }
    
    init(contentType: ContentType) {
        switch contentType {
        case .post(let post):
            self.post = post
            Task {
                try await checkIfUserLikedPost()
                try await checkIfUserSavedPost()
            }
            
        case .reply(let reply):
            self.reply = reply
        }
    }
    
    func likePost() async throws {
        guard let post = post else { return }
        
        try await PostService.likePost(post)
        self.post?.didLike = true
        self.post?.likes += 1
    }
    
    func unlikePost() async throws {
        guard let post = post else { return }

        try await PostService.unlikePost(post)
        self.post?.didLike = false
        self.post?.likes -= 1
    }
    
    func savePost() async throws {
        guard let post = post else { return }
        
        try await PostService.savePost(post)
        self.post?.didSave = true
    }
    
    func unsavePost() async throws {
        guard let post = post else { return }
        try await PostService.unsavePost(post)
        self.post?.didSave = false
    }
    
    func checkIfUserLikedPost() async throws {
        guard let post = post else { return }

        let didLike = try await PostService.checkIfUserLikedPost(post)
        if didLike {
            self.post?.didLike = true
        }
    }
    
    func checkIfUserSavedPost() async throws {
        guard let post = post else { return }

        let didSave = try await PostService.checkIfUserSavedPost(post)
        if didSave {
            self.post?.didSave = true
        }
    }
    
    static func deletePost(_ post: Post) async throws {
        guard post.user?.isCurrentUser != nil else { return }
        
        try await PostService.deletePost(post)
    }
}
