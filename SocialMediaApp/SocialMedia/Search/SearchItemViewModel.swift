//
//  SearchItemViewModel.swift
//  SocialMedia
//

import Foundation
import Observation
import SocialMediaNetwork

@Observable final class SearchItemViewModel {
    var user: User
    let thumbnailSize: CGFloat
    var loading: Bool = false
    
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
        user.followedByCurrentUser?.toggle()
        loading = true
        if user.isFollowed {
            try await UserService.shared.follow(userID: userID)
        } else {
            try await UserService.shared.unfollow(userID: userID)
        }
        loading = false
    }
}
