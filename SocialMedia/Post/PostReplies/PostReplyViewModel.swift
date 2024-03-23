//
//  PostReplyViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

final class PostReplyViewModel: ObservableObject {
    let post: Post
    @Published var replyText = ""
    
    var currentUser: User? {
        return UserService.shared.currentUser
    }
    
    init(post: Post) {
        self.post = post
        self.replyText = replyText
    }
    
    func uploadPostReply(toPost post: Post, replyText: String) async throws {
        try await PostService.replyToPost(post, replyText: replyText)
    }
}
