//
//  User.swift
//  SocialMedia
//

import Firebase
import FirebaseFirestoreSwift

public struct User: Identifiable, Codable, Hashable {
    @DocumentID public var id: String?
    
    public let email: String
    public let username: String
    public var fullName: String
    public let joinDate: Timestamp
    public var profileImageURL: String
    public var aboutMe: String
    public var link: String
    public var stats: UserStats
    public var isFollowed: Bool
    public var privateProfile: Bool

    public var isCurrentUser: Bool {
        return id == Auth.auth().currentUser?.uid
    }
    
    public init(id: String? = nil, email: String, username: String, fullName: String, joinDate: Timestamp, profileImageURL: String = "", aboutMe: String = "", link: String = "", stats: UserStats = .init(), isFollowed: Bool = false, privateProfile: Bool = false) {
        self.id = id
        self.email = email
        self.username = username
        self.fullName = fullName
        self.joinDate = joinDate
        self.profileImageURL = profileImageURL
        self.aboutMe = aboutMe
        self.link = link
        self.stats = stats
        self.isFollowed = isFollowed
        self.privateProfile = privateProfile
    }
    
    public func matches(searchText: String) -> Bool {
        guard !searchText.isEmpty else { return true }
        return fullName.localizedCaseInsensitiveContains(searchText) || username.localizedCaseInsensitiveContains(searchText)
    }
}

public struct UserStats: Codable, Hashable {
    public var followersCount: Int
    public var followingCount: Int
    public var postsCount: Int
    
    public init(followersCount: Int = 0, followingCount: Int = 0, postsCount: Int = 0) {
        self.followersCount = followersCount
        self.followingCount = followingCount
        self.postsCount = postsCount
    }
}
