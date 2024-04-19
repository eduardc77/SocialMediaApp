//
//  ActivityRowViewModel.swift
//  SocialMedia
//

import Foundation
import SocialMediaNetwork

final class ActivityRowViewModel: ObservableObject {
    @Published var activity: Activity
    @Published var loading: Bool = false
    
    var isFollowed: Bool {
        activity.user?.isFollowed ?? false
    }
    
   var activityMessage: String {
        switch activity.type {
        case .like:
            return activity.post?.caption ?? ""
        case .follow:
            return "Followed you"
        case .reply:
            return "Replied to one of your posts"
        }
    }
    
    init(activity: Activity) {
        self.activity = activity
    }
    
    @MainActor
    func toggleFollow() async throws {
        guard let userID = activity.user?.id else { return }
        activity.user?.followedByCurrentUser?.toggle()
    
        loading = true
        if let user = activity.user, user.isFollowed {
            activity.user?.stats.followersCount += 1
            try await UserService.shared.follow(userID: userID)
        } else {
            activity.user?.stats.followersCount -= 1
            try await UserService.shared.unfollow(userID: userID)
        }
        loading = false
    }
}
