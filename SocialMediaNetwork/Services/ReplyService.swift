//
//  ReplyService.swift
//  SocialMedia
//

import Combine
import Firebase
import FirebaseFirestoreSwift

public struct ReplyService {
    
    private static var currentListener: ListenerRegistration? = nil
    
    static var currentListenerRemoved: Bool {
        ReplyService.currentListener == nil
    }
    
    public static func removeCurrentListener() {
        guard !currentListenerRemoved else { return }
        ReplyService.currentListener?.remove()
        ReplyService.currentListener = nil
    }
    
    public static func replyToPost(_ post: Post, replyText: String) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        
        let reply = Reply(
            postID: postID,
            replyText: replyText,
            ownerUID: currentUID,
            postOwnerUID: post.ownerUID,
            timestamp: Timestamp()
        )
        guard let data = try? Firestore.Encoder().encode(reply) else { return }
        try await FirestoreConstants.replies.document().setData(data)
        try await FirestoreConstants.posts.document(postID).updateData([
            "replies": post.replies + 1
        ])
        ActivityService.uploadNotification(toUID: post.ownerUID, type: .reply, postID: postID)
    }
    
    public static func replyToReply(_ reply: Reply, replyText: String) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid, let replyID = reply.id else { return }
        
        let reply = Reply(
            postID: replyID,
            replyText: replyText,
            ownerUID: currentUID,
            postOwnerUID: reply.ownerUID,
            timestamp: Timestamp()
        )
        guard let data = try? Firestore.Encoder().encode(reply) else { return }
        try await FirestoreConstants.replies.document(reply.postID).collection("replyReplies").document().setData(data)
        try await FirestoreConstants.replies.document(replyID).updateData([
            "replies": reply.replies + 1
        ])
        ActivityService.uploadNotification(toUID: reply.ownerUID, type: .reply, postID: replyID)
    }
    
    public static func fetchPostReplies(forPost post: Post, countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documents: [Reply], lastDocument: DocumentSnapshot?) {
        guard let postID = post.id else { return ([], nil) }
        
        let snapshotQuery = try await FirestoreConstants.replies
            .whereField("postID", isEqualTo: postID)
            .order(by: "timestamp", descending: descending)
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Reply.self)
        return snapshotQuery
    }
    
    public static func fetchReplyReplies(forReply reply: Reply, countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documents: [Reply], lastDocument: DocumentSnapshot?) {
        guard let postID = reply.id else { return ([], nil) }
        
        let snapshotQuery = try await FirestoreConstants.replies.document(postID).collection("replyReplies")
            .whereField("postID", isEqualTo: postID)
            .order(by: "timestamp", descending: descending)
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Reply.self)
        return snapshotQuery
    }
    
    public static func fetchPostReplies(forUser user: User, countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documents: [Reply], lastDocument: DocumentSnapshot?) {
        guard let userID = user.id else { return ([], nil) }
        
        let snapshotQuery = try await FirestoreConstants.replies
            .whereField("ownerUID", isEqualTo: userID)
            .order(by: "timestamp", descending: descending)
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Reply.self)
        
        return snapshotQuery
    }
  
    public static func addListenerForPostReplies(forUserID userID: String) -> (AnyPublisher<(DocChangeType<Reply>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.replies
            .whereField("ownerUID", isEqualTo: userID)
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
        
        try await FirestoreConstants.posts.document(replyID).collection("replyLikes").document(uid).setData([:])
        try await FirestoreConstants.users.document(uid).collection("userLikedReplies").document(replyID).setData([:])
        try await FirestoreConstants.posts.document(replyID).updateData(["likes": reply.likes])
        ActivityService.uploadNotification(toUID: reply.ownerUID, type: .like, postID: reply.postID)
    }
    
    static func unlikeReply(_ reply: Reply) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let replyID = reply.id else { return }
        
        try await FirestoreConstants.posts.document(replyID).collection("replyLikes").document(uid).delete()
        try await FirestoreConstants.users.document(uid).collection("userLikedReplies").document(replyID).delete()
        try await FirestoreConstants.posts.document(replyID).updateData(["likes": reply.likes])
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
    
    static func deleteReply(_ reply: Reply) async throws {
        guard reply.user?.isCurrentUser ?? false, let userID = Auth.auth().currentUser?.uid, let replyID = reply.id else { return }
        try await FirestoreConstants.replies.document(replyID).delete()
        try await FirestoreConstants.replies.document(replyID).collection("replies").document(userID).delete()
        try await FirestoreConstants.users.document(userID).collection("userLikedReplies").document(replyID).delete()
        try await FirestoreConstants.users.document(userID).collection("userSavedReplies").document(replyID).delete()
        
        let users = try await UserService.fetchUsers()
        for user in users {
            guard let userID = user.id else { return }
            let userLikesDocument = FirestoreConstants.users.document(userID).collection("userLikedReplies").document(replyID)
            let userSavesDocument = FirestoreConstants.users.document(userID).collection("userSavedReplies").document(replyID)
            
            try await userLikesDocument.delete()
            try await userSavesDocument.delete()
        }
        let snapshot = try await FirestoreConstants
            .replies
            .whereField("postID", isEqualTo: replyID)
            .getDocuments()
        
        for document in snapshot.documents {
            let reply = try? document.data(as: Reply.self)
            guard replyID == reply?.postID else { return }
            try await document.reference.delete()
        }
    }
}
