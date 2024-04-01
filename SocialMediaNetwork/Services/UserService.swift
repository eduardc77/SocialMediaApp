//
//  UserService.swift
//  SocialMedia
//

import Firebase
import FirebaseFirestoreSwift

public class UserService: UserServiceable {
    @Published public var currentUser: User?
    
    public static let shared = UserService()
    private static let userCache = NSCache<NSString, NSData>()

    @MainActor
    public func fetchCurrentUser() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let snapshot = try await FirestoreConstants.users.document(uid).getDocument()
        let user = try snapshot.data(as: User.self)
        self.currentUser = user
    }
    
    public static func fetchUser(userID: String) async throws -> User {
        if let nsData = userCache.object(forKey: userID as NSString) {
            if let user = try? JSONDecoder().decode(User.self, from: nsData as Data) {
                return user
            }
        }
        let snapshot = try await FirestoreConstants.users.document(userID).getDocument()
        let user = try snapshot.data(as: User.self)
        
        if let userData = try? JSONEncoder().encode(user) {
            userCache.setObject(userData as NSData, forKey: userID as NSString)
        }
        return user
    }
    
    public static func fetchUsers() async throws -> [User] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        let snapshot = try await FirestoreConstants.users.getDocuments()
        let users = snapshot.documents.compactMap({ try? $0.data(as: User.self) })
        return users.filter({ $0.id != uid })
    }
}

// MARK: - Following

public extension UserService {
    @MainActor
    func follow(userID: String) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        async let _ = try await FirestoreConstants
            .following
            .document(currentUID)
            .collection("userFollowing")
            .document(userID)
            .setData([:])
        
        async let _ = try await FirestoreConstants
            .followers
            .document(userID)
            .collection("userFollowers")
            .document(currentUID)
            .setData([:])
        
        ActivityService.uploadNotification(toUID: userID, type: .follow)
        currentUser?.stats?.followingCount += 1
        
        async let _ = try await UserService.updateUserFeedAfterFollowing(userID: userID)
    }
    
    @MainActor
    func unfollow(userID: String) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        
        async let _ = try await FirestoreConstants
            .following
            .document(currentUID)
            .collection("userFollowing")
            .document(userID)
            .delete()

        async let _ = try await FirestoreConstants
            .followers
            .document(userID)
            .collection("userFollowers")
            .document(currentUID)
            .delete()
        
        currentUser?.stats?.followingCount -= 1
        async let _ = try await ActivityService.deleteNotification(toUID: userID, type: .follow)
        async let _ = try await UserService.updateUserFeedAfterUnfollowing(userID: userID)
    }
    
    static func checkIfUserIsFollowed(userID uid: String) async -> Bool {
        guard let currentUID = Auth.auth().currentUser?.uid else { return false }
        let collection = FirestoreConstants.following.document(currentUID).collection("userFollowing")
        guard let snapshot = try? await collection.document(uid).getDocument() else { return false }
        return snapshot.exists
    }
    
    static func checkIfUserIsFollowed(_ user: User) async -> Bool {
        guard let currentUID = Auth.auth().currentUser?.uid, let userID = user.id else { return false }
        let collection = FirestoreConstants.following.document(currentUID).collection("userFollowing")
        guard let snapshot = try? await collection.document(userID).getDocument() else { return false }
        return snapshot.exists
    }
    
    static func fetchUserStats(userID: String) async throws -> UserStats {
        async let followingSnapshot = try await FirestoreConstants.following.document(userID).collection("userFollowing").getDocuments()
        async let followerSnapshot = try await FirestoreConstants.followers.document(userID).collection("userFollowers").getDocuments()
        async let postsSnapshot = try await FirestoreConstants.posts.whereField("ownerUID", isEqualTo: userID).getDocuments()

        return .init(followersCount: try await followerSnapshot.count,
                     followingCount: try await followingSnapshot.count,
                     postsCount: try await postsSnapshot.count)
    }
        
    static func fetchUserFollowers(userID: String) async throws -> [User] {
        let snapshot = try await FirestoreConstants
            .followers
            .document(userID)
            .collection("userFollowers")
            .getDocuments()
        
        return try await fetchUsers(snapshot)

    }
    
    static func fetchUserFollowing(userID: String) async throws -> [User] {
        let snapshot = try await FirestoreConstants
            .following
            .document(userID)
            .collection("userFollowing")
            .getDocuments()
        
        return try await fetchUsers(snapshot)
    }
}

// MARK: Feed Updates

public extension UserService {
    static func updateUserFeedAfterFollowing(userID: String) async throws {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        let postsSnapshot = try await FirestoreConstants.posts.whereField("ownerUID", isEqualTo: userID).getDocuments()
        
        for document in postsSnapshot.documents {
            try await FirestoreConstants
                .users
                .document(currentUID)
                .collection("userFeed")
                .document(document.documentID)
                .setData([:])
        }
    }
    
    static func updateUserFeedAfterUnfollowing(userID: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        let postsSnapshot = try await FirestoreConstants.posts.whereField("ownerUID", isEqualTo: userID).getDocuments()
        
        for document in postsSnapshot.documents {
            try await FirestoreConstants
                .users
                .document(currentUid)
                .collection("userFeed")
                .document(document.documentID)
                .delete()
        }
    }
}

// MARK: - Helpers 

public extension UserService {
    private static func fetchUsers(_ snapshot: QuerySnapshot?) async throws -> [User] {
        var users = [User]()
        guard let documents = snapshot?.documents else { return [] }
        
        for doc in documents {
            let user = try await UserService.fetchUser(userID: doc.documentID)
            users.append(user)
        }
        
        return users
    }
    
    func resetUser() {
        currentUser = nil
    }
}
