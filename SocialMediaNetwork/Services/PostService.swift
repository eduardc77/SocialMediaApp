//
//  PostService.swift
//  SocialMedia
//

import Combine
import Firebase
import FirebaseFirestoreSwift

public struct PostService {
    
    private static var feedListener: ListenerRegistration? = nil
    private static var likedPostsListener: ListenerRegistration? = nil
    private static var savedPostsListener: ListenerRegistration? = nil

    public static func uploadPost(_ post: Post) async throws {
        guard let postData = try? Firestore.Encoder().encode(post) else { return }
        let documentReference = try await FirestoreConstants.posts.addDocument(data: postData)
        try await updateUserFeedAfterPost(postID: documentReference.documentID)
    }
    
    public static func fetchPost(postID: String) async throws -> Post {
        let snapshot = try await FirestoreConstants.posts.document(postID).getDocument()
        return try snapshot.data(as: Post.self)
    }
    
    public static func replaceCurrentListeners(with listener: ListenerRegistration) {
        guard !listenersRemoved else { return }
        PostService.feedListener?.remove()
        PostService.feedListener = nil

        self.feedListener = listener
    }
    
    private static var listenersRemoved: Bool {
        PostService.feedListener == nil && PostService.likedPostsListener == nil && PostService.savedPostsListener == nil
    }
    
    // MARK: - For You Feed
    
    public static func fetchForYouPosts(countLimit: Int, descending: Bool = true, lastDocument: DocumentSnapshot?) async throws -> (documents: [Post], lastDocument: DocumentSnapshot?) {
        let querySnapshot = try await FirestoreConstants.posts
            .order(by: "timestamp", descending: descending)
            .limit(to: countLimit)
            .startOptionally(afterDocument: lastDocument)
            .getDocumentsWithSnapshot(as: Post.self)
        
        return querySnapshot
    }
    
    public static func addListenerForFeed() -> (AnyPublisher<(DocChangeType<Post>, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.posts
            .addSnapshotListener(as: Post.self)
        
        replaceCurrentListeners(with: listener)
        
        return publisher
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
        
        replaceCurrentListeners(with: listener)
        
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
        guard let userID = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        
        try await FirestoreConstants.posts.document(postID).collection("postLikes").document(userID).setData([:])
        try await FirestoreConstants.users.document(userID).collection("userLikedPosts").document(postID).setData([:])
        try await FirestoreConstants.posts.document(postID).updateData(["likes": post.likes + 1])
        ActivityService.uploadNotification(toUID: post.ownerUID, type: .like, postID: postID)
    }
    
    static func unlikePost(_ post: Post) async throws {
        guard let userID = Auth.auth().currentUser?.uid, let postID = post.id else { return }
       
        try await FirestoreConstants.posts.document(postID).collection("postLikes").document(userID).delete()
        try await FirestoreConstants.users.document(userID).collection("userLikedPosts").document(postID).delete()
        try await FirestoreConstants.posts.document(postID).updateData(["likes": post.likes - 1])
        try await ActivityService.deleteNotification(toUID: post.ownerUID, type: .like, postID: postID)
    }
    
    static func checkIfUserLikedPost(_ post: Post) async throws -> Bool {
        guard let userID = Auth.auth().currentUser?.uid, let postID = post.id else { return false }
        
        let snapshot = try await FirestoreConstants.users.document(userID).collection("userLikedPosts").document(postID).getDocument()
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
    
    static func addListenerForLikedPosts(forUserID userID: String) -> (AnyPublisher<(DocIDChangeType, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.users
            .document(userID)
            .collection("userLikedPosts")
            .addSnapshotListenerForDocumentIDs()
        
        likedPostsListener?.remove()
        likedPostsListener = nil
        self.likedPostsListener = listener
        
        return publisher
    }
}

// MARK: - Save

public extension PostService {
    static func savePost(_ post: Post) async throws {
        guard let userID = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        try await FirestoreConstants.users.document(userID).collection("userSavedPosts").document(postID).setData([:])
    }
    
    static func unsavePost(_ post: Post) async throws {
        guard let userID = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        try await FirestoreConstants.users.document(userID).collection("userSavedPosts").document(postID).delete()
    }
    
    static func checkIfUserSavedPost(_ post: Post) async throws -> Bool {
        guard let userID = Auth.auth().currentUser?.uid, let postID = post.id else { return false }
        
        let snapshot = try await FirestoreConstants.users.document(userID).collection("userSavedPosts").document(postID).getDocument()
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
    
    static func addListenerForSavedPosts(forUserID userID: String) -> (AnyPublisher<(DocIDChangeType, DocumentSnapshot?), Error>) {
        let (publisher, listener) =
        FirestoreConstants.users
            .document(userID)
            .collection("userSavedPosts")
            .addSnapshotListenerForDocumentIDs()
        
        savedPostsListener?.remove()
        savedPostsListener = nil
        self.savedPostsListener = listener
        
        return publisher
    }
}

// MARK: - Delete

public extension PostService {
    
    static func deletePost(_ post: Post) async throws {
        guard post.user?.isCurrentUser ?? false, let userID = Auth.auth().currentUser?.uid, let postID = post.id else { return }
        
        async let deletePostUserData: Void = deletePostUserData(for: userID, postID: postID)
        async let deletePostLikes: Void = deletePostLikes(for: postID)
        async let deletePostReplies: Void = deletePostReplies(for: postID)

        _ = try await [deletePostUserData, deletePostLikes, deletePostReplies, deletePost]
    }
    
    private static func deletePostUserData(for userID: String, postID: String) async throws {
        // Delete current user data
        async let deleteUserFeed: Void = FirestoreConstants.users
            .document(userID)
            .collection("userFeed")
            .document(postID).delete()
        async let deleteUserLikes: Void = FirestoreConstants.users
            .document(userID)
            .collection("userLikedPosts")
            .document(postID).delete()
        async let deleteUserSaves: Void = FirestoreConstants.users
            .document(userID)
            .collection("userSavedPosts")
            .document(postID).delete()
        
        _ = try await [deleteUserFeed, deleteUserLikes, deleteUserSaves]
        
        // Delete user data for all users except current
        let users = try await UserService.fetchUsers()
        
        for user in users {
            guard let userID = user.id else { return }
            
            async let deleteUserFeed: Void = FirestoreConstants.users
                .document(userID)
                .collection("userFeed")
                .document(postID).delete()
            async let deleteUserLikes: Void = FirestoreConstants.users
                .document(userID)
                .collection("userLikedPosts")
                .document(postID).delete()
            async let deleteUserSaves: Void = FirestoreConstants.users
                .document(userID)
                .collection("userSavedPosts")
                .document(postID).delete()
            
            _ = try await [deleteUserFeed, deleteUserLikes, deleteUserSaves]
        }
    }
    
    private static func deletePostLikes(for postID: String) async throws {
        let postLikes = try await FirestoreConstants.posts
            .document(postID)
            .collection("postLikes")
            .getDocuments().documents
        
        for document in postLikes {
            try await document.reference.delete()
        }
    }
    
    private static func deletePostReplies(for postID: String) async throws {
        let post = try await fetchPost(postID: postID)
        try await ReplyService.deleteReply(for: postID, maxReplyDepthLevel: post.replyDepthLevel)
        try await FirestoreConstants.posts.document(postID).delete()
    }
}
