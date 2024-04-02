//
//  UserRelationsViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

@MainActor
final class UserRelationsViewModel: ObservableObject {
    @Published var users = [User]()
    @Published var currentStatString: String = ""
    @Published var selectedFilter: UserRelationType = .followers {
        didSet { updateRelationData() }
    }
    
    private let user: User
    private var followers = [User]()
    private var following = [User]()
    
    init(user: User) {
        self.user = user
        Task { try await fetchUserFollowers() }
        Task { try await fetchUserFollowing() }
    }
    
    private func fetchUserFollowers() async throws {
        guard let userID = user.id else { return }
        let followers = try await UserService.fetchUserFollowers(userID: userID)
        self.followers = await checkIfUsersAreFollowed(followers)
        self.updateRelationData()
    }
    
    private func fetchUserFollowing() async throws {
        guard let userID = user.id else { return }
        var following = try await UserService.fetchUserFollowing(userID: userID)
        
        if user.isCurrentUser {
            for i in 0 ..< following.count {
                following[i].isFollowed = true
            }
        }
        
        self.following = following
        guard !user.isCurrentUser else { return }
        self.following = await checkIfUsersAreFollowed(following)
    }
    
   private func updateRelationData() {
        switch selectedFilter {
        case .followers:
            self.users = followers
            self.currentStatString = "\(user.stats.followersCount) followers"
        case .following:
            self.users = following
            self.currentStatString = "\(user.stats.followingCount) following"
        }
    }
    
    private func checkIfUsersAreFollowed(_ users: [User]) async -> [User] {
        var result = users
        
        for i in 0 ..< result.count {
            let user = result[i]
            
            let isFollowed = await UserService.checkIfUserIsFollowed(user)
            result[i].isFollowed = isFollowed
        }
        
        return result
    }
}
