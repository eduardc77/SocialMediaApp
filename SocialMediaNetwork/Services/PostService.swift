//
//  PostService.swift
//  SocialMedia
//

import Combine
import Firebase
import FirebaseFirestoreSwift

public struct PostService {
    
    public static func uploadPost(_ post: Post) async throws {
        guard let postData = try? Firestore.Encoder().encode(post) else { return }
        _ = try await FirestoreConstants.posts.addDocument(data: postData)
    }
    
    public static func fetchPost(postID: String) async throws -> Post {
        let snapshot = try await FirestoreConstants.posts.document(postID).getDocument()
        return try snapshot.data(as: Post.self)
    }
    
    // MARK: - For You Feed
    
    private static var currentListener: ListenerRegistration? = nil
    
    static var currentListenerRemoved: Bool {
        PostService.currentListener == nil
    }
    
    public static func addListenerForFeed() -> (AnyPublisher<(DocChangeType<Post>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.posts
            .order(by: "timestamp", descending: false)
            .addSnapshotListener(as: Post.self)
        
        removeCurrentListener()
        self.currentListener = listener
        
        return publisher
    }
    
    public static func removeCurrentListener() {
        guard !currentListenerRemoved else { return }
        PostService.currentListener?.remove()
        PostService.currentListener = nil
    }
    
    public static func fetchForYouPosts(countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documents: [Post], lastDocument: DocumentSnapshot?) {
        let querySnapshot = try await FirestoreConstants.posts
            .order(by: "timestamp", descending: descending)
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
        
        return querySnapshot
    }
    
    // MARK: - Following Feed
    
    public static func fetchUserFollowingPosts(countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documentIDs: [String], lastDocument: DocumentSnapshot?) {
        guard let userID = Auth.auth().currentUser?.uid else { return (documentIDs: [], lastDocument: nil) }

        let querySnapshot = try await FirestoreConstants.users
            .document(userID)
            .collection("userFeed")
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentIDsWithSnapshot()

        return querySnapshot
    }

    public static func addListenerForUserFollowingFeed(forUserID userID: String) -> (AnyPublisher<(DocChangeType<Post>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.users
            .document(userID)
            .collection("userFeed")
            .addSnapshotListener(as: Post.self)
        
        removeCurrentListener()
        self.currentListener = listener
        
        return publisher
    }
    
    // MARK: - User Posts
    
    public static func fetchUserPosts(userID: String, countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documents: [Post], lastDocument: DocumentSnapshot?) {
        let querySnapshot = try await FirestoreConstants.posts
            .whereField("ownerUID", isEqualTo: userID)
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
        
        return querySnapshot
    }
    
    // MARK: - Category Posts
    
    public static func fetchPosts(by category: PostCategory) async throws -> [Post] {
        let querySnapshot = try await FirestoreConstants
            .posts
            .whereField("category", isEqualTo: category.rawValue.lowercased())
            .getDocuments()
        
        return querySnapshot.documents.compactMap({ try? $0.data(as: Post.self) })
    }
}

// MARK: - Replies

public extension PostService {
    static func replyToPost(_ post: Post, replyText: String) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        
        let reply = PostReply(
            postID: postID,
            replyText: replyText,
            postReplyOwnerUID: currentUID,
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
    
    static func fetchPostReplies(forPost post: Post, countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documents: [PostReply], lastDocument: DocumentSnapshot?) {
        guard let postID = post.id else { return ([], nil) }
        
        let snapshotQuery = try await FirestoreConstants.replies
            .whereField("postID", isEqualTo: postID)
            .order(by: "timestamp", descending: descending)
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: PostReply.self)
        return snapshotQuery
    }
    
    static func fetchPostReplies(forUser user: User, countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documents: [PostReply], lastDocument: DocumentSnapshot?) {
        guard let userID = user.id else { return ([], nil) }
        
        var snapshotQuery = try await FirestoreConstants.replies
            .whereField("postReplyOwnerUID", isEqualTo: userID)
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: PostReply.self)
        
        for i in 0 ..< snapshotQuery.documents.count {
            snapshotQuery.documents[i].replyUser = user
        }
        return snapshotQuery
    }
  
    static func addListenerForPostReplies(forUserID userID: String) -> (AnyPublisher<(DocChangeType<PostReply>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.replies
            .whereField("postReplyOwnerUID", isEqualTo: userID)
            .addSnapshotListener(as: PostReply.self)
        
        removeCurrentListener()
        self.currentListener = listener
        
        return publisher
    }
}

// MARK: - Likes

public extension PostService {
    static func likePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        
        try await FirestoreConstants.posts.document(postID).collection("postLikes").document(uid).setData([:])
        try await FirestoreConstants.posts.document(postID).updateData(["likes": post.likes])
        try await FirestoreConstants.users.document(uid).collection("userLikes").document(postID).setData([:])
        
        ActivityService.uploadNotification(toUID: post.ownerUID, type: .like, postID: postID)
    }
    
    static func unlikePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        
        try await FirestoreConstants.posts.document(postID).collection("postLikes").document(uid).delete()
        try await FirestoreConstants.posts.document(postID).updateData(["likes": post.likes])
        try await FirestoreConstants.users.document(uid).collection("userLikes").document(postID).delete()

        try await ActivityService.deleteNotification(toUID: post.ownerUID, type: .like, postID: postID)
    }
    
    static func checkIfUserLikedPost(_ post: Post) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid, let postID = post.id else { return false }
        
        let snapshot = try await FirestoreConstants.users.document(uid).collection("userLikes").document(postID).getDocument()
        return snapshot.exists
    }
    
    static func fetchUserLikedPosts(userID: String, countLimit: Int, lastDocument: DocumentSnapshot?) async throws -> (documentIDs: [String], lastDocument: DocumentSnapshot?) {
        
        let querySnapshot = try await FirestoreConstants.users
            .document(userID)
            .collection("userLikes")
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentIDsWithSnapshot()
        
        return querySnapshot
    }
    
    static func addListenerForLikedPosts(forUserID userID: String) -> (AnyPublisher<(DocChangeType<String>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.users
            .document(userID)
            .collection("userLikes")
            .addSnapshotListener(as: String.self)
        
        removeCurrentListener()
        self.currentListener = listener
        
        return publisher
    }
}

// MARK: - Save

public extension PostService {
    static func savePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        try await FirestoreConstants.users.document(uid).collection("userSaves").document(postID).setData([:])
    }
    
    static func unsavePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        try await FirestoreConstants.users.document(uid).collection("userSaves").document(postID).delete()
    }

    static func checkIfUserSavedPost(_ post: Post) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid, let postID = post.id else { return false }
        
        let snapshot = try await FirestoreConstants.users.document(uid).collection("userSaves").document(postID).getDocument()
        return snapshot.exists
    }
    
    static func fetchUserSavedPosts(userID: String, countLimit: Int, lastDocument: DocumentSnapshot?) async throws -> (documentIDs: [String], lastDocument: DocumentSnapshot?) {
    
        let querySnapshot = try await FirestoreConstants.users
            .document(userID)
            .collection("userSaves")
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentIDsWithSnapshot()
        
        return querySnapshot
    }
    
    static func addListenerForSavedPosts(forUserID userID: String) -> (AnyPublisher<(DocChangeType<String>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.users
            .document(userID)
            .collection("userSaves")
            .addSnapshotListener(as: String.self)
        
        removeCurrentListener()
        self.currentListener = listener
        
        return publisher
    }
}

// MARK: - Delete

public extension PostService {
    
    static func deletePost(_ post: Post) async throws {
        guard post.user?.isCurrentUser ?? false, let uid = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        try await FirestoreConstants.posts.document(postID).delete()
        try await FirestoreConstants.posts.document(postID).collection("postLikes").document(uid).delete()
        try await FirestoreConstants.users.document(uid).collection("userLikes").document(postID).delete()
        try await FirestoreConstants.users.document(uid).collection("userFeed").document(postID).delete()
        
        let users = try await UserService.fetchUsers()
        for user in users {
            guard let userID = user.id else { return }
            let document = FirestoreConstants.users.document(userID).collection("userFeed").document(postID)
            let snapshot = try await document.getDocument()
            if snapshot.exists {
                try await document.delete()
            }
        }
        let snapshot = try await FirestoreConstants
            .replies
            .whereField("postID", isEqualTo: postID)
            .getDocuments()
        
        for document in snapshot.documents {
            let reply = try? document.data(as: PostReply.self)
            guard postID == reply?.postID else { return }
            try await document.reference.delete()
        }
    }
}
