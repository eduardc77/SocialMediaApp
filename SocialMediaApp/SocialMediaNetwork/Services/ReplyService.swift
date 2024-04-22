
import Combine
import Firebase
import FirebaseFirestoreSwift

public struct ReplyService {
    
    private static var currentListener: ListenerRegistration? = nil
    
    public static func removeCurrentListener() {
        ReplyService.currentListener?.remove()
        ReplyService.currentListener = nil
    }
    
    public static func fetchReply(replyID: String) async throws -> Reply {
        let snapshot = try await FirestoreConstants.replies().document(replyID).getDocument()
        return try snapshot.data(as: Reply.self)
    }
    
    public static func replyToPost(_ post: Post, replyText: String) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        
        let reply = Reply(
            caption: replyText,
            ownerUID: currentUID,
            replyID: postID,
            timestamp: Timestamp(),
            postID: postID,
            postOwnerUID: post.ownerUID
        )
        guard let data = try? Firestore.Encoder().encode(reply) else { return }
        try await FirestoreConstants.replies().document().setData(data)
        try await FirestoreConstants.posts.document(postID).updateData([
            "replies": post.replies + 1
        ])
        ActivityService.uploadNotification(toUID: post.ownerUID, type: .reply, postID: postID)
    }
    
    public static func replyToReply(_ reply: Reply, replyText: String) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid, let replyID = reply.id else { return }
        
        let newReply = Reply(
            caption: replyText,
            ownerUID: currentUID,
            replyID: replyID,
            timestamp: Timestamp(),
            postID: reply.postID,
            postOwnerUID: reply.ownerUID,
            depthLevel: reply.depthLevel + 1
        )
        guard let data = try? Firestore.Encoder().encode(newReply) else { return }
        
        try await FirestoreConstants.replies(newReply.depthLevel).document().setData(data)
        try await FirestoreConstants.replies(reply.depthLevel).document(replyID).updateData([
            "replies": reply.replies + 1
        ])
        try await FirestoreConstants.posts.document(reply.postID).updateData([
            "replyDepthLevel": newReply.depthLevel
        ])
        
        ActivityService.uploadNotification(toUID: reply.ownerUID, type: .reply, postID: replyID)
    }
    
    public static func fetchPostReplies(forPost post: Post, countLimit: Int = 0, lastDocument: DocumentSnapshot? = nil) async throws -> (documents: [Reply], lastDocument: DocumentSnapshot?) {
        guard let postID = post.id else { return ([], nil) }
        
        let snapshotQuery = try await FirestoreConstants.replies()
            .whereField("postID", isEqualTo: postID)
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Reply.self)
        return snapshotQuery
    }
    
    public static func fetchReplyReplies(forReply reply: Reply, countLimit: Int = 0, lastDocument: DocumentSnapshot? = nil) async throws -> (documents: [Reply], lastDocument: DocumentSnapshot?) {
        guard let replyID = reply.id else { return ([], nil) }
        
        let snapshotQuery = try await Firestore.firestore().collection("replies\(reply.depthLevel + 1)")
            .whereField("replyID", isEqualTo: replyID)
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Reply.self)
        return snapshotQuery
    }
    
    public static func fetchPostReplies(forUser user: User, countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documents: [Reply], lastDocument: DocumentSnapshot?) {
        guard let userID = user.id else { return ([], nil) }
        
        // FIXME: - query all depth levels
        let snapshotQuery = try await FirestoreConstants.replies()
            .whereField("ownerUID", isEqualTo: userID)
            .order(by: "timestamp", descending: descending)
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Reply.self)
        
        return snapshotQuery
    }
    
    public static func addListenerForPostReplies(postID: String, depthLevel: Int) -> (AnyPublisher<(DocChangeType<Reply>, DocumentSnapshot?), Error>) {
        let field = depthLevel == 0 ? "postID" : "replyID"
        let (publisher, listener) =
        FirestoreConstants.replies(depthLevel)
            .whereField(field, isEqualTo: postID)
            .addSnapshotListener(as: Reply.self)
        
        removeCurrentListener()
        self.currentListener = listener
        
        return publisher
    }
    
}

// MARK: - Likes

public extension ReplyService {
    static func likeReply(_ reply: Reply) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let replyID = reply.id else { return }
        
        try await FirestoreConstants.replies(reply.depthLevel).document(replyID).collection("replyLikes").document(uid).setData([:])
        try await FirestoreConstants.users.document(uid).collection("userLikedReplies").document(replyID).setData([:])
        try await FirestoreConstants.replies(reply.depthLevel).document(replyID).updateData(["likes": reply.likes + 1])
        ActivityService.uploadNotification(toUID: reply.ownerUID, type: .like, postID: reply.postID)
    }
    
    static func unlikeReply(_ reply: Reply) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let replyID = reply.id else { return }
        
        try await FirestoreConstants.replies(reply.depthLevel).document(replyID).collection("replyLikes").document(uid).delete()
        try await FirestoreConstants.users.document(uid).collection("userLikedReplies").document(replyID).delete()
        try await FirestoreConstants.replies(reply.depthLevel).document(replyID).updateData(["likes": reply.likes - 1])
        try await ActivityService.deleteNotification(toUID: reply.ownerUID, type: .like, postID: reply.postID)
    }
    
    static func checkIfUserLikedReply(_ reply: Reply) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid, let replyID = reply.id else { return false }
        
        let snapshot = try await FirestoreConstants.users.document(uid).collection("userLikedReplies").document(replyID).getDocument()
        return snapshot.exists
    }
    
    static func fetchUserLikedReplies(userID: String, countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documentIDs: [String], lastDocument: DocumentSnapshot?) {
        
        let querySnapshot = try await FirestoreConstants.users
            .document(userID)
            .collection("userLikedReplies")
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentIDsWithSnapshot()
        
        return querySnapshot
    }
    
    static func addListenerForLikedReplies(forUserID userID: String) -> (AnyPublisher<(DocChangeType<String>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.users
            .document(userID)
            .collection("userLikedReplies")
            .addSnapshotListener(as: String.self)
        
        removeCurrentListener()
        self.currentListener = listener
        
        return publisher
    }
}

// MARK: - Save

public extension ReplyService {
    static func saveReply(_ reply: Reply) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let replyID = reply.id else { return }
        try await FirestoreConstants.users.document(uid).collection("userSavedReplies").document(replyID).setData([:])
    }
    
    static func unsaveReply(_ reply: Reply)async throws {
        guard let uid = Auth.auth().currentUser?.uid, let replyID = reply.id else { return }
        try await FirestoreConstants.users.document(uid).collection("userSavedReplies").document(replyID).delete()
    }
    
    static func checkIfUserSavedReply(_ reply: Reply) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid, let replyID = reply.id else { return false }
        
        let snapshot = try await FirestoreConstants.users.document(uid).collection("userSavedReplies").document(replyID).getDocument()
        return snapshot.exists
    }
    
    static func fetchUserSavedReplies(userID: String, countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documentIDs: [String], lastDocument: DocumentSnapshot?) {
        
        let querySnapshot = try await FirestoreConstants.users
            .document(userID)
            .collection("userSavedReplies")
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentIDsWithSnapshot()
        
        return querySnapshot
    }
    
    static func addListenerForSavedReplies(forUserID userID: String) -> (AnyPublisher<(DocChangeType<String>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.users
            .document(userID)
            .collection("userSavedReplies")
            .addSnapshotListener(as: String.self)
        
        removeCurrentListener()
        self.currentListener = listener
        
        return publisher
    }
}

// MARK: - Delete

public extension ReplyService {
    
    static func deleteReply(for postID: String, maxReplyDepthLevel: Int) async throws {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        for replyLevel in 0...maxReplyDepthLevel {
            let replySnapshot = try await FirestoreConstants.replies(replyLevel)
                .whereField("postID", isEqualTo: postID)
                .getDocuments().documents
            
            for document in replySnapshot {
                if let reply = try? document.data(as: Reply.self), let replyID = reply.id {
                    async let deleteReplyUserData: Void = deleteReplyUserData(for: userID, replyID: replyID)
                    async let deleteReplyLikes: Void = deleteReplyLikes(for: replyID, currentReplyLevel: replyLevel)
                    async let deleteReply: Void = FirestoreConstants.replies(replyLevel).document(replyID).delete()
                    _ = try await [deleteReplyUserData, deleteReplyLikes, deleteReply]
                }
            }
        }
    }
    
    private static func deleteReplyUserData(for userID: String, replyID: String) async throws {
        // Delete current user data
        async let deleteUserLikes: Void = FirestoreConstants.users
            .document(userID)
            .collection("userLikedReplies")
            .document(replyID).delete()
        async let deleteUserSaves: Void = FirestoreConstants.users
            .document(userID)
            .collection("userSavedReplies")
            .document(replyID).delete()
        
        _ = try await [deleteUserLikes, deleteUserSaves]
        
        // Delete user data for all users except current
        let users = try await UserService.fetchUsers()
        
        for user in users {
            guard let userID = user.id else { return }
            
            async let deleteUserLikes: Void = FirestoreConstants.users
                .document(userID)
                .collection("userLikedReplies")
                .document(replyID).delete()
            async let deleteUserSaves: Void = FirestoreConstants.users
                .document(userID)
                .collection("userSavedReplies")
                .document(replyID).delete()
            
            _ = try await [deleteUserLikes, deleteUserSaves]
        }
    }
    
    private static func deleteReplyLikes(for replyID: String, currentReplyLevel: Int) async throws {
        let replyLikes = try await FirestoreConstants.replies(currentReplyLevel)
            .document(replyID)
            .collection("replyLikes")
            .getDocuments().documents
        
        for document in replyLikes {
            try await document.reference.delete()
        }
    }
}

