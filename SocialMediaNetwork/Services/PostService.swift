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
        let documentReference = try await FirestoreConstants.posts.addDocument(data: postData)
        try await updateUserFeedAfterPost(postID: documentReference.documentID)
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
    
    static func updateUserFeedAfterPost(postID: String) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let followersSnapshot = try await FirestoreConstants.followers.document(uid).collection("userFollowers").getDocuments()
        
        for document in followersSnapshot.documents {
            try await FirestoreConstants
                .users
                .document(document.documentID)
                .collection("userFeed")
                .document(postID).setData([:])
        }
        try await FirestoreConstants.users.document(uid).collection("userFeed").document(postID).setData([:])
    }

    public static func addListenerForUserFollowingFeed(forUserID userID: String) -> (AnyPublisher<(DocChangeType<String>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.users
            .document(userID)
            .collection("userFeed")
            .addSnapshotListener(as: String.self)
        
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
    
    public static func addListenerForUserPosts(forUserID userID: String) -> (AnyPublisher<(DocChangeType<Post>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.posts
            .whereField("ownerUID", isEqualTo: userID)
            .addSnapshotListener(as: Post.self)
        
        removeCurrentListener()
        self.currentListener = listener
        
        return publisher
    }
    
    // MARK: - Category Posts
    
    public static func fetchPosts(by category: PostCategory, descending: Bool = true) async throws -> [Post] {
        let querySnapshot = try await FirestoreConstants
            .posts
            .whereField("category", isEqualTo: category.rawValue.lowercased())
            .order(by: "timestamp", descending: descending)
            .getDocuments()
        
        return querySnapshot.documents.compactMap({ try? $0.data(as: Post.self) })
    }
}

// MARK: - Likes

public extension PostService {
    static func likePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        
        try await FirestoreConstants.posts.document(postID).collection("postLikes").document(uid).setData([:])
        try await FirestoreConstants.users.document(uid).collection("userLikedPosts").document(postID).setData([:])
        try await FirestoreConstants.posts.document(postID).updateData(["likes": post.likes])
        ActivityService.uploadNotification(toUID: post.ownerUID, type: .like, postID: postID)
    }
    
    static func unlikePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        
        try await FirestoreConstants.posts.document(postID).collection("postLikes").document(uid).delete()
        try await FirestoreConstants.users.document(uid).collection("userLikedPosts").document(postID).delete()
        try await FirestoreConstants.posts.document(postID).updateData(["likes": post.likes])
        try await ActivityService.deleteNotification(toUID: post.ownerUID, type: .like, postID: postID)
    }
    
    static func checkIfUserLikedPost(_ post: Post) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid, let postID = post.id else { return false }
        
        let snapshot = try await FirestoreConstants.users.document(uid).collection("userLikedPosts").document(postID).getDocument()
        return snapshot.exists
    }
    
    static func fetchUserLikedPosts(userID: String, countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documentIDs: [String], lastDocument: DocumentSnapshot?) {
        
        let querySnapshot = try await FirestoreConstants.users
            .document(userID)
            .collection("userLikedPosts")
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentIDsWithSnapshot()
        
        return querySnapshot
    }
    
    static func addListenerForLikedPosts(forUserID userID: String) -> (AnyPublisher<(DocChangeType<String>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.users
            .document(userID)
            .collection("userLikedPosts")
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
        try await FirestoreConstants.users.document(uid).collection("userSavedPosts").document(postID).setData([:])
    }
    
    static func unsavePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        try await FirestoreConstants.users.document(uid).collection("userSavedPosts").document(postID).delete()
    }

    static func checkIfUserSavedPost(_ post: Post) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid, let postID = post.id else { return false }
        
        let snapshot = try await FirestoreConstants.users.document(uid).collection("userSavedPosts").document(postID).getDocument()
        return snapshot.exists
    }
    
    static func fetchUserSavedPosts(userID: String, countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documentIDs: [String], lastDocument: DocumentSnapshot?) {
    
        let querySnapshot = try await FirestoreConstants.users
            .document(userID)
            .collection("userSavedPosts")
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentIDsWithSnapshot()
        
        return querySnapshot
    }
    
    static func addListenerForSavedPosts(forUserID userID: String) -> (AnyPublisher<(DocChangeType<String>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.users
            .document(userID)
            .collection("userSavedPosts")
            .addSnapshotListener(as: String.self)
        
        removeCurrentListener()
        self.currentListener = listener
        
        return publisher
    }
}

// MARK: - Delete

public extension PostService {
    
    static func deletePost(_ post: Post) async throws {
        guard post.user?.isCurrentUser ?? false, let userID = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        try await FirestoreConstants.posts.document(postID).delete()
        try await FirestoreConstants.posts.document(postID).collection("postLikes").document(userID).delete()
        try await FirestoreConstants.users.document(userID).collection("userLikedPosts").document(postID).delete()
        try await FirestoreConstants.users.document(userID).collection("userSavedPosts").document(postID).delete()
        try await FirestoreConstants.users.document(userID).collection("userFeed").document(postID).delete()
        
        let users = try await UserService.fetchUsers()
        for user in users {
            guard let userID = user.id else { return }
            let userFeedDocument = FirestoreConstants.users.document(userID).collection("userFeed").document(postID)
            let userLikesDocument = FirestoreConstants.users.document(userID).collection("userLikedPosts").document(postID)
            let userSavesDocument = FirestoreConstants.users.document(userID).collection("userSavedPosts").document(postID)
            
            try await userFeedDocument.delete()
            try await userLikesDocument.delete()
            try await userSavesDocument.delete()
        }
        let snapshot = try await FirestoreConstants
            .replies
            .whereField("postID", isEqualTo: postID)
            .getDocuments()
        
        for document in snapshot.documents {
            let reply = try? document.data(as: Reply.self)
            guard postID == reply?.postID else { return }
            try await document.reference.delete()
        }
    }
}
