//
//  UserRelationsViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

@MainActor
final class UserRelationsViewModel: ObservableObject {
    private let user: User
    @Published var currentStatString: String = ""
    @Published var searchText = ""
    @Published var loading = false
    
    var contentUnavailableTitle: String {
        "No results for '\(searchText)'"
    }
    
    var contentUnavailableText: String {
        "Check the spelling or try a new search"
    }
    
    @Published var sort = UserSortOrder.name
    
   
    @Published private var users = [User]()
    private var followers = [User]()
    private var following = [User]()
    
    var filteredUsers: [User] {
        users(sortedBy: sort).filter { $0.matches(searchText: searchText) }
    }
    
    @Published var filterSelection: UserRelationType = .followers {
        didSet { updateRelationData() }
    }
    
    var mostPopularUsers: [User] {
        users.lazy.sorted { $0.stats.followersCount > $1.stats.followersCount }
    }
    
    init(user: User) {
        self.user = user
    }
    
    func loadUserRelations() async throws {
        loading = true
        try await fetchUserFollowers()
        try await fetchUserFollowing()
        loading = false
    }
}

// MARK: - Private Methods

private extension UserRelationsViewModel {
    func users(sortedBy sort: UserSortOrder = .popularity) -> [User] {
        switch sort {
        case .popularity:
            return users.sorted { $0.stats.followersCount > $1.stats.followersCount }
        case .name:
            return users.sorted { $0.fullName.localizedCompare($1.fullName) == .orderedAscending }
        case .engagement:
            return users.sorted { $0.stats.postsCount > $1.stats.postsCount }
        }
    }
    
    func fetchUserFollowers() async throws {
        guard let userID = user.id else { return }
        let followers = try await UserService.fetchUserFollowers(userID: userID)
        self.followers = await checkIfUsersAreFollowed(followers)
        self.updateRelationData()
    }
    
    func fetchUserFollowing() async throws {
        guard let userID = user.id else { return }
        var following = try await UserService.fetchUserFollowing(userID: userID)
        
        if user.isCurrentUser {
            for i in 0 ..< following.count {
                following[i].followedByCurrentUser = true
            }
        }
        
        self.following = following
        guard !user.isCurrentUser else { return }
        self.following = await checkIfUsersAreFollowed(following)
    }
    
    func updateRelationData() {
        switch filterSelection {
        case .followers:
            self.users = followers
            self.currentStatString = "\(user.stats.followersCount) followers"
        case .following:
            self.users = following
            self.currentStatString = "\(user.stats.followingCount) following"
        }
    }
    
    func checkIfUsersAreFollowed(_ users: [User]) async -> [User] {
        var result = users
        
        for i in 0 ..< result.count {
            let user = result[i]
            
            let isFollowed = await UserService.checkIfUserIsFollowed(user)
            result[i].followedByCurrentUser = isFollowed
        }
        
        return result
    }
}
