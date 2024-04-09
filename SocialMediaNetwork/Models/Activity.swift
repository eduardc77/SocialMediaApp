
import Firebase
import FirebaseFirestoreSwift

public struct Activity: Identifiable, Codable, Hashable {
    @DocumentID public var id: String?
    
    public let type: ActivityType
    public let senderUID: String
    public let timestamp: Timestamp
    public var postID: String?
    
    public var user: User?
    public var post: Post?
    public var reply: Reply?
    public var isFollowed: Bool?
    
    public init(id: String? = nil, type: ActivityType, senderUID: String, timestamp: Timestamp, postID: String? = nil, user: User? = nil, post: Post? = nil, reply: Reply? = nil, isFollowed: Bool? = nil) {
        self.id = id
        self.type = type
        self.senderUID = senderUID
        self.timestamp = timestamp
        self.postID = postID
        self.user = user
        self.post = post
        self.reply = reply
        self.isFollowed = isFollowed
    }
}
