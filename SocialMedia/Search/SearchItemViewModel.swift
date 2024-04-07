//
//  SearchItemViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

final class SearchItemViewModel: ObservableObject {
    @Published var user: User
    let thumbnailSize: CGFloat
    @Published var isLoading: Bool = false
    
    var isFollowed: Bool {
        user.isFollowed
    }
    
    init(user: User, thumbnailSize: CGFloat) {
        self.user = user
        self.thumbnailSize = thumbnailSize
    }
    
    @MainActor
    func toggleFollow() async throws {
        guard let userID = user.id else { return }
        user.isFollowed.toggle()
        isLoading = true
        if user.isFollowed {
            try await UserService.shared.follow(userID: userID)
        } else {
            try await UserService.shared.unfollow(userID: userID)
        }
        isLoading = false
    }
}
