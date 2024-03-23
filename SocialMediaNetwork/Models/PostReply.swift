//
//  PostReply.swift
//  SocialMedia
//

import FirebaseFirestoreSwift
import Firebase

public struct PostReply: Identifiable, Codable, Hashable {
    @DocumentID public var id: String?
    
    public let postID: String
    public let replyText: String
    public let postReplyOwnerUID: String
    public let postOwnerUID: String
    public let timestamp: Timestamp
    
    public var post: Post?
    public var replyUser: User?
    
    public init(id: String? = nil, postID: String, replyText: String, postReplyOwnerUID: String, postOwnerUID: String, timestamp: Timestamp, post: Post? = nil, replyUser: User? = nil) {
        self.id = id
        self.postID = postID
        self.replyText = replyText
        self.postReplyOwnerUID = postReplyOwnerUID
        self.postOwnerUID = postOwnerUID
        self.timestamp = timestamp
        self.post = post
        self.replyUser = replyUser
    }
}
