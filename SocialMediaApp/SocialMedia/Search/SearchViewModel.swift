//
//  SearchViewModel.swift
//  SocialMedia
//

import Observation
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
    
    var sort = UserSortOrder.name
    
    var filteredUsers: [User] {
        users(sortedBy: sort).filter { $0.matches(searchText: searchText) }
    }
    
    var mostPopularUsers: [User] {
        users.lazy.sorted { $0.stats.followersCount > $1.stats.followersCount }
    }

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

