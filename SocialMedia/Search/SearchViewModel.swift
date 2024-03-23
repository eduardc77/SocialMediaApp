//
//  SearchViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var users = [User]()
    @Published var searchText = ""
    @Published var isLoading = false
    
    var filteredUsers: [User] {
        return searchText.isEmpty ? users : filteredUsers(searchText)
    }
    
    init() {
        Task { try await fetchUsers() }
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
    
    func filteredUsers(_ query: String) -> [User] {
        let lowercasedQuery = query.lowercased()
        return users.filter({
            $0.fullName.lowercased().contains(lowercasedQuery) ||
            $0.username.contains(lowercasedQuery)
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
