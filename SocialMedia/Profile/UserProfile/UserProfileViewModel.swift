//
//  ProfileViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

@MainActor
final class UserProfileViewModel: ObservableObject {
    @Published var user: User
    @Published var isLoading: Bool = false
    
    @Published var selectedPostFilter: ProfilePostFilter = .posts
    @Published var showEditProfile = false
    @Published var showUserRelationSheet = false

    var isFollowed: Bool { return user.isFollowed }
    
    init(user: User) {
        self.user = user
        loadUserData()
    }
    
    func loadUserData() {
        guard let userID = user.id else { return }
        Task {
            isLoading = true
            async let stats = try await UserService.fetchUserStats(userID: userID)
            self.user.stats = try await stats
            
            async let isFollowed = await checkIfUserIsFollowed()
            self.user.isFollowed = await isFollowed
            isLoading = false
        }
    }
}

// MARK: - Following

extension UserProfileViewModel {
    func follow() async throws {
        guard let userID = user.id else { return }
        isLoading = true
        try await UserService.shared.follow(userID: userID)
        self.user.isFollowed = true
        self.user.stats.followersCount += 1
        isLoading = false
    }
    
    func unfollow() async throws {
        guard let userID = user.id else { return }
        isLoading = true
        try await UserService.shared.unfollow(userID: userID)
        self.user.isFollowed = false
        self.user.stats.followersCount -= 1
        isLoading = false
    }
    
    func checkIfUserIsFollowed() async -> Bool {
        await UserService.checkIfUserIsFollowed(user)
    }
}
