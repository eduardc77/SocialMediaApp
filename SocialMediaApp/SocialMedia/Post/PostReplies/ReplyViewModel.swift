//
//  ReplyViewModel.swift
//  SocialMedia
//

import Observation
import SocialMediaNetwork

@Observable final class ReplyViewModel {
    var replyText = ""
    
    var postType: PostType
    
    var currentUser: User? {
        return UserService.shared.currentUser
    }
    
    init(postType: PostType) {
        self.postType = postType
    }
    
    func uploadReply(with replyText: String) async throws {
        switch postType {
        case .post(let post):
            try await ReplyService.replyToPost(post, replyText: replyText)
            
        case .reply(let reply):
            try await ReplyService.replyToReply(reply, replyText: replyText)
        }
    }
}
