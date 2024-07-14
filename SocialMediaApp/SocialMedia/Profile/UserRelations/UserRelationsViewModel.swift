//
//  UserRelationsViewModel.swift
//  SocialMedia
//

import Observation
import SocialMediaNetwork

@MainActor
@Observable final class UserRelationsViewModel {
    private let user: User
    var currentStatString: String = ""
    var searchText = ""
    var loading = false
    
    var contentUnavailableTitle: String {
        "No results for '\(searchText)'"
    }
    
    var contentUnavailableText: String {
        "Check the spelling or try a new search"
    }
    
    var sort = UserSort.name

    private var users = [User]()
    private var followers = [User]()
    private var following = [User]()
    
    var sortedAndFilteredUsers: [User] {
        users(sortedBy: sort)
            .filter { $0.matches(searchText: searchText) }
    }
    
    var filterSelection: UserRelationType = .followers {
        didSet { updateRelationData() }
    }
    
    var nameSortedUsers: [User] {
        users.sorted { $0.fullName.localizedCompare($1.fullName) == .orderedAscending }
    }
    
    var mostPopularUsers: [User] {
        users.lazy.sorted { $0.stats.followersCount > $1.stats.followersCount }
    }
    
    var mostEngagedUsers: [User] {
        users.lazy.sorted { $0.stats.followersCount > $1.stats.followersCount }
    }
    
    init(user: User) {
        self.user = user
    }
    
    func loadUserRelations() async {
        loading = true
        do {
            try await fetchUserFollowers()
            try await fetchUserFollowing()
        } catch {
            print("DEBUG: Failed to fetch user relations.")
        }
        loading = false
    }
}

// MARK: - Private Methods

private extension UserRelationsViewModel {
    func users(sortedBy sort: UserSort = .popularity) -> [User] {
        switch sort {
        case .popularity:
            return mostPopularUsers
        case .name:
            return nameSortedUsers
        case .engagement:
            return mostEngagedUsers
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
