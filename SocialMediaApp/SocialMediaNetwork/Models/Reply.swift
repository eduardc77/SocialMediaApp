
import Firebase
import FirebaseFirestoreSwift

public struct Reply: Identifiable, Codable, Hashable {
    @DocumentID public var id: String?
    
    public let caption: String
    public let ownerUID: String
    public let replyID: String
    public let timestamp: Timestamp
    
    public let postID: String
    public let postOwnerUID: String
    
    public var likes: Int
    public var reposts: Int
    public var replies: Int
    public var depthLevel: Int
    public var imageUrl: String?
    
    public var post: Post?
    public var user: User?
    
    public var isLiked: Bool? = nil
    public var isSaved: Bool? = nil
    public var isReposed: Bool? = nil

    public init(id: String? = nil, caption: String, ownerUID: String, replyID: String, timestamp: Timestamp, postID: String, postOwnerUID: String, likes: Int = 0, reposts: Int = 0, replies: Int = 0, depthLevel: Int = 0, imageUrl: String? = nil, post: Post? = nil, user: User? = nil) {
        self.id = id
        self.caption = caption
        self.ownerUID = ownerUID
        self.replyID = replyID
        self.timestamp = timestamp
        self.postID = postID
        self.postOwnerUID = postOwnerUID
        self.likes = likes
        self.reposts = reposts
        self.replies = replies
        self.depthLevel = depthLevel
        self.imageUrl = imageUrl
        self.post = post
        self.user = user
    }
}
