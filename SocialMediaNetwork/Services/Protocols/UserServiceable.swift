//
//  UserServiceable.swift
//  SocialMedia
//

protocol UserServiceable {
    var currentUser: User? { get }
    
    func fetchCurrentUser() async throws
    static func fetchUser(withUID uid: String) async throws -> User
    static func fetchUsers() async throws -> [User]
    
    // Following
    func follow(uid: String) async throws
    func unfollow(uid: String) async throws
    static func checkIfUserIsFollowedWithUID(_ uid: String) async -> Bool
    static func checkIfUserIsFollowed(_ user: User) async -> Bool
    static func fetchUserStats(uid: String) async throws -> UserStats
    static func fetchUserFollowers(uid: String) async throws -> [User]
    static func fetchUserFollowing(uid: String) async throws -> [User]
    
    // Feed Updates
    static func updateUserFeedAfterFollow(followedUid: String) async throws
    static func updateUserFeedAfterUnfollow(unfollowedUID: String) async throws
}
