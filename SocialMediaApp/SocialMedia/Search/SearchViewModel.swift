//
//  SearchViewModel.swift
//  SocialMedia
//

import Observation
import SocialMediaUI
import SocialMediaNetwork

@MainActor
@Observable final class SearchViewModel {
    private var users = [User]()
    
    var searchText = ""
    var loading = false
    
    var contentUnavailableTitle: String {
        "No results for '\(searchText)'"
    }
    
    var contentUnavailableText: String {
        "Check the spelling or try a new search"
    }
    
    var filterSelection: UserSearchFilter = .all
    var sortSelection = UserSort.name
    
    var sortedAndFilteredUsers: [User] {
        users(sortedBy: sortSelection)
            .filter { $0.matches(searchText: searchText) }
            .filter { filter(user: $0, by: filterSelection) }
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
    
    func filter(user: User, by filter: UserSearchFilter = .all) -> Bool {
        switch filter {
        case .all:
            return true
        case .followed:
            return user.isFollowed
        case .notFollowed:
            return !user.isFollowed
        }
    }
    
    func fetchUsers() async {
        self.loading = true
        
        do {
            let users = try await UserService.fetchUsers()
            
            try await withThrowingTaskGroup(of: User.self, body: { group in
                var result = [User]()
                
                for i in 0 ..< users.count {
                    group.addTask { return await self.checkIfUserIsFollowed(user: users[i]) }
                }
                
                for try await user in group {
                    result.append(user)
                }
                
                self.loading = false
                self.users = result
            })
        } catch {
            
        }
    }
    
    func checkIfUserIsFollowed(user: User) async -> User {
        var result = user
        result.followedByCurrentUser = await UserService.checkIfUserIsFollowed(user)
        return result
    }
    
    func refresh() async {
        users.removeAll()
        await fetchUsers()
    }
}

//MARK: - Private Methods

private extension SearchViewModel {
    func follow(user: User, at index: Int) async throws {
        guard let userID = user.id else { return }
        loading = true
        users[index].followedByCurrentUser = true
        users[index].stats.followersCount += 1
        try await UserService.shared.follow(userID: userID)
        
        loading = false
    }
    
    func unfollow(user: User, at index: Int) async throws {
        guard let userID = user.id else { return }
        loading = true
        users[index].followedByCurrentUser = false
        users[index].stats.followersCount -= 1
        try await UserService.shared.unfollow(userID: userID)
        
        loading = false
    }
}

enum UserSearchFilter: String, TopFilter {
    case all
    case followed
    case notFollowed
    
    var id: UserSearchFilter { self }
    
    var title: String {
        switch self {
        case .notFollowed:
            return "Not Followed"
        default:
            return rawValue.capitalized
        }
    }
}
