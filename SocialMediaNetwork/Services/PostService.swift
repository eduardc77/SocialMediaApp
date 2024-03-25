//
//  PostService.swift
//  SocialMedia
//

import Combine
import Firebase
import FirebaseFirestoreSwift

public struct PostService {
    private static var feedListener: ListenerRegistration? = nil
    
    public static var feedListenerRemoved: Bool {
        PostService.feedListener == nil
    }
    
    public static func uploadPost(_ post: Post) async throws {
        guard let postData = try? Firestore.Encoder().encode(post) else { return }
        _ = try await FirestoreConstants.posts.addDocument(data: postData)
    }
    
    public static func addListenerForFeed(countLimit: Int, lastDocument: DocumentSnapshot?, descending: Bool = false) -> (AnyPublisher<(DocChangeType<Post>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants
            .posts
            .order(by: "timestamp", descending: descending)
           // .limit(to: countLimit)
//            .startOptionally(afterDocument: lastDocument)
            .addSnapshotListener(as: Post.self)
        
        self.feedListener = listener
        return publisher
    }
    
    public static func removeListenerForFeed() {
        guard !feedListenerRemoved else { return }
        PostService.feedListener?.remove()
        PostService.feedListener = nil
    }
    
    public static func fetchPosts(countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (posts: [Post], lastDocument: DocumentSnapshot?) {
        let snapshotQuery = try await FirestoreConstants
            .posts
            .order(by: "timestamp", descending: descending)
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
        
        return snapshotQuery
    }
    
    public static func fetchPostIDs(countLimit: Int, lastDocument: DocumentSnapshot?) async throws -> (postIDs: [String], lastDocument: DocumentSnapshot?) {
        guard let userID = Auth.auth().currentUser?.uid else { return (postIDs: [], lastDocument: nil) }
        let snapshotQuery = try await FirestoreConstants
            .users
            .document(userID)
            .collection("userFeed")
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentIDsWithSnapshot()
        
        return snapshotQuery
    }
    
    public static func fetchUserPosts(uid: String) async throws -> [Post] {
        let query = FirestoreConstants.posts.whereField("ownerUID", isEqualTo: uid)
        let snapshot = try await query.getDocuments()
        return snapshot.documents.compactMap({ try? $0.data(as: Post.self) })
    }
    
    public static func fetchPost(postID: String) async throws -> Post {
        let snapshot = try await FirestoreConstants.posts.document(postID).getDocument()
        return try snapshot.data(as: Post.self)
    }
    
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
    
    static func fetchPostReplies(forPost post: Post) async throws -> [PostReply] {
        guard let postID = post.id else { return [] }
        let snapshot = try await FirestoreConstants
            .replies
            .whereField("postID", isEqualTo: postID)
            .order(by: "timestamp", descending: false)
            .getDocuments()
        return snapshot.documents.compactMap({ try? $0.data(as: PostReply.self) })
    }
    
    static func fetchPostReplies(forUser user: User) async throws -> [PostReply] {
        guard let userID = user.id else { return [] }
        let snapshot = try await FirestoreConstants
            .replies
            .whereField("postReplyOwnerUID", isEqualTo: userID)
            .getDocuments()
        
        var replies = snapshot.documents.compactMap({ try? $0.data(as: PostReply.self) })
        
        for i in 0 ..< replies.count {
            replies[i].replyUser = user
        }
        return replies
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
    
    static func fetchLikedPosts(forUserID userID: String) async throws -> [Post] {
        var likedPosts: [Post] = []
        
        let querySnapshot = try await FirestoreConstants.users
            .document(userID)
            .collection("userLikes")
            .getDocuments()
        
        for doc in querySnapshot.documents {
            let postID = doc.documentID
            let documentSnapshot = try await FirestoreConstants.posts.document(postID).getDocument()
            
            if let quote = try? documentSnapshot.data(as: Post.self) {
                likedPosts.append(quote)
            }
        }
        return likedPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue()})
    }
    
    static func addListenerForLikedPosts(forUserID userID: String) -> (listener: ListenerRegistration, publisher: AnyPublisher<(DocChangeType<Post>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.users
            .document(userID)
            .collection("userLikes")
            .addSnapshotListener(as: Post.self)
        
        return (listener, publisher)
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
    
    static func fetchSavedPosts(forUserID userID: String) async throws -> [Post] {
        var savedPosts: [Post] = []
        
        let snapshot = try await FirestoreConstants.users
            .document(userID)
            .collection("userSaves")
            .getDocuments()
        
        for doc in snapshot.documents {
            let postID = doc.documentID
            let snapshot = try await FirestoreConstants.posts.document(postID).getDocument()
            if let quote = try? snapshot.data(as: Post.self) {
                savedPosts.append(quote)
            }
        }
        return savedPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue()})
    }
    
    static func addListenerForSavedPosts(forUserID userID: String) -> (listener: ListenerRegistration, publisher: AnyPublisher<(DocChangeType<Post>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.users
            .document(userID)
            .collection("userSaves")
            .addSnapshotListener(as: Post.self)
        
        return (listener, publisher)
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
