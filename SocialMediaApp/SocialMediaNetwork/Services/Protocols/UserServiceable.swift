//
//  UserServiceable.swift
//  SocialMedia
//

protocol UserServiceable {
    var currentUser: User? { get }
    
    func fetchCurrentUser() async throws
    static func fetchUser(userID: String) async throws -> User
    static func fetchUsers() async throws -> [User]
    
    // Following
    func follow(userID: String) async throws
    func unfollow(userID: String) async throws
    static func checkIfUserIsFollowed(userID: String) async -> Bool
    static func checkIfUserIsFollowed(_ user: User) async -> Bool
    static func fetchUserStats(userID: String) async throws -> UserStats
    static func fetchUserFollowers(userID: String) async throws -> [User]
    static func fetchUserFollowing(userID: String) async throws -> [User]
    
    // Feed Updates
    static func updateUserFeedAfterFollowing(userID: String) async throws
    static func updateUserFeedAfterUnfollowing(userID: String) async throws
}
