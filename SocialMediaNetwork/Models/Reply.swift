//
//  Reply.swift
//  SocialMedia
//

import Firebase
import FirebaseFirestoreSwift

public struct Reply: Identifiable, Codable, Hashable {
    @DocumentID public var id: String?
    
    public let postID: String
    
    public let replyID: String
    public let replyText: String
    public let ownerUID: String
    public let postOwnerUID: String
    public let timestamp: Timestamp
    
    public var likes: Int
    public var reposts: Int
    public var replies: Int
    public var depthLevel: Int
    public var imageUrl: String?
    public var didLike: Bool
    public var didRepost: Bool
    public var didSave: Bool
    
    public var post: Post?
    public var user: User?
    
    public init(id: String? = nil, postID: String, replyID: String, replyText: String, ownerUID: String, postOwnerUID: String, timestamp: Timestamp, likes: Int = 0, reposts: Int = 0, replies: Int = 0, depthLevel: Int = 0, imageUrl: String? = nil, didLike: Bool = false, didRepost: Bool = false, didSave: Bool = false, post: Post? = nil, replyUser: User? = nil) {
        self.id = id
        self.postID = postID
        self.replyID = replyID
        self.replyText = replyText
        self.ownerUID = ownerUID
        self.postOwnerUID = postOwnerUID
        self.timestamp = timestamp
        self.likes = likes
        self.reposts = reposts
        self.replies = replies
        self.depthLevel = depthLevel
        self.imageUrl = imageUrl
        self.didLike = didLike
        self.didRepost = didRepost
        self.didSave = didSave
        self.post = post
        self.user = replyUser
    }
}
