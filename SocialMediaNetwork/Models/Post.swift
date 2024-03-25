//
//  Post.swift
//  SocialMedia
//

import Firebase
import FirebaseFirestoreSwift

public struct Post: Identifiable, Codable, Hashable {
    @DocumentID public var id: String?
    
    public let caption: String
    public let ownerUID: String
    public let category: PostCategory
    public let timestamp: Timestamp
    
    public var likes: Int = 0
    public var reposts: Int = 0
    public var replies: Int = 0
    public var imageUrl: String? = nil
    public var user: User? = nil
    public var didLike: Bool? = false
    public var didRepost: Bool = false
    public var didSave: Bool? = false
    
    public init(id: String? = nil, caption: String, ownerUID: String, category: PostCategory, timestamp: Timestamp, likes: Int = 0, replies: Int = 0, imageUrl: String? = nil, user: User? = nil, didLike: Bool? = false, didSave: Bool? = false) {
        self.id = id
        self.caption = caption
        self.ownerUID = ownerUID
        self.category = category
        self.timestamp = timestamp
        self.likes = likes
        self.replies = replies
        self.imageUrl = imageUrl
        self.user = user
        self.didLike = didLike
        self.didSave = didSave
    }
}

extension Post: Equatable {
    public static func ==(lhs: Post, rhs: Post) -> Bool {
        return lhs.id == rhs.id && lhs.ownerUID == rhs.ownerUID && lhs.caption == rhs.caption && lhs.category == rhs.category && lhs.imageUrl == rhs.imageUrl && lhs.likes == rhs.likes && lhs.replies == rhs.replies && lhs.reposts == rhs.reposts
    }
}
