//
//  SearchViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var users: [User] = []
    
    @Published var searchText = ""
    @Published var isLoading = false
    
    @Published var sort = UserSortOrder.name

    var filteredUsers: [User] {
        users(sortedBy: sort).filter { $0.matches(searchText: searchText) }
    }
    
    var mostPopularUsers: [User] {
        users.lazy.sorted { $0.stats.followersCount > $1.stats.followersCount }
    }
    
    init() {
        Task { try await fetchUsers() }
    }
    
    public func users(sortedBy sort: UserSortOrder = .popularity) -> [User] {
        switch sort {
        case .popularity:
            return users.sorted { $0.stats.followersCount > $1.stats.followersCount }
        case .name:
            return users.sorted { $0.fullName.localizedCompare($1.fullName) == .orderedAscending }
        case .engagement:
            return users.sorted { $0.stats.postsCount > $1.stats.postsCount }
        }
    }
    
    func fetchUsers() async throws {
        self.isLoading = true
        let users = try await UserService.fetchUsers()
        
        try await withThrowingTaskGroup(of: User.self, body: { group in
            var result = [User]()
            
            for i in 0 ..< users.count {
                group.addTask { return await self.checkIfUserIsFollowed(user: users[i]) }
            }
                        
            for try await user in group {
                result.append(user)
            }
            
            self.isLoading = false
            self.users = result
        })
    }
    
    func toggleFollow(for user: User) {
    if let index = users.firstIndex(where: { $0.id == user.id }) {
        users[index].isFollowed.toggle()
    }
}

func checkIfUserIsFollowed(user: User) async -> User {
        var result = user
        result.isFollowed = await UserService.checkIfUserIsFollowed(user)
        return result
    }
}

public enum UserSortOrder: Hashable {
    case name
    case popularity
    case engagement
}
