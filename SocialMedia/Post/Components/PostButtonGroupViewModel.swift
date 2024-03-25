//
//  PostButtonGroupViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

@MainActor
final class PostButtonGroupViewModel: ObservableObject {
    @Published var post: Post?
    @Published var reply: PostReply?

    @Published var temporaryRepostCount: Int = 0
    
    var postLikes: Int {
       post?.likes ?? 0
    }
   
    var didLike: Bool {
        post?.didLike ?? false
    }
    
    var didSave: Bool {
        return post?.didSave ?? false
    }
    
    init(postType: PostType) {
        switch postType {
        case .post(let post):
            self.post = post
          
        case .reply(let reply):
            self.reply = reply
        }
    }
    
    func likePost() async throws {
        guard var post = post else { return }
        post.didLike = true
        post.likes += 1
        try await PostService.likePost(post)
      
    }
    
    func unlikePost() async throws {
        guard var post = post else { return }
        post.didLike = false
        post.likes -= 1
        try await PostService.unlikePost(post)
    }
    
    func savePost() async throws {
        post?.didSave = true
        guard let post = post else { return }
        try await PostService.savePost(post)
    }
    
    func unsavePost() async throws {
        self.post?.didSave = false
        guard let post = post else { return }
        try await PostService.unsavePost(post)
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
