//
//  UserProfileHeaderModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

@MainActor
final class UserProfileHeaderModel: ObservableObject {
    @Published var user: User
    @Published var loading: Bool = false
    
    @Published var selectedPostFilter: ProfilePostFilter = .posts
    @Published var showEditProfile = false
    @Published var showUserRelationSheet = false
    
    var isFollowed: Bool { user.isFollowed }
    
    init(user: User) {
        self.user = user
        loadUserData()
    }
    
    func loadUserData() {
        guard let userID = user.id else { return }
        Task {
            loading = true
            async let stats = try await UserService.fetchUserStats(userID: userID)
            self.user.stats = try await stats
            
            async let isFollowed = await checkIfUserIsFollowed()
            self.user.followedByCurrentUser = await isFollowed
            loading = false
        }
    }
}

// MARK: - Following

extension UserProfileHeaderModel {
    func follow() async throws {
        guard let userID = user.id else { return }
        loading = true
        user.followedByCurrentUser = true
        user.stats.followersCount += 1
        try await UserService.shared.follow(userID: userID)
        loading = false
    }
    
    func unfollow() async throws {
        guard let userID = user.id else { return }
        loading = true
        user.followedByCurrentUser = false
        user.stats.followersCount -= 1
        try await UserService.shared.unfollow(userID: userID)
        loading = false
    }
    
    func checkIfUserIsFollowed() async -> Bool {
        await UserService.checkIfUserIsFollowed(user)
    }
}
