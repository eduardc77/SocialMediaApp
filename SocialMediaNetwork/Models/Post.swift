
import Firebase
import FirebaseFirestoreSwift

public struct Post: Identifiable, Codable, Hashable {
    @DocumentID public var id: String?
    
    public let caption: String
    public let ownerUID: String
    public let category: PostCategory
    public let timestamp: Timestamp
    
    public var likes: Int
    public var reposts: Int
    public var replies: Int
    public var replyDepthLevel: Int
    public var imageUrl: String?
    
    public var user: User?
     
    public var isLiked: Bool? = nil
    public var isSaved: Bool? = nil
    public var isReposed: Bool? = nil
    
    public init(id: String? = nil, caption: String, ownerUID: String, category: PostCategory, timestamp: Timestamp, likes: Int = 0, reposts: Int = 0, replies: Int = 0, replyDepthLevel: Int = 0, imageUrl: String? = nil, user: User? = nil) {
        self.id = id
        self.caption = caption
        self.ownerUID = ownerUID
        self.category = category
        self.timestamp = timestamp
        self.likes = likes
        self.reposts = reposts
        self.replies = replies
        self.replyDepthLevel = replyDepthLevel
        self.imageUrl = imageUrl
        self.user = user
    }
}
