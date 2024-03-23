//
//  ActivityViewModel.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

@MainActor
class ActivityViewModel: ObservableObject {
    var notifications = [Activity]()
    @Published var filteredNotifications = [Activity]()
    @Published var isLoading = false
    
    @Published var selectedFilter: ActivityFilter = .all {
        didSet {
            switch selectedFilter {
            case .all:
                filteredNotifications = notifications
            case .follows:
                filteredNotifications = notifications.filter({ $0.type == .follow })
            case .replies:
                filteredNotifications = notifications.filter({ $0.type == .reply })
            case .likes:
                filteredNotifications = notifications.filter({ $0.type == .like })
            }
        }
    }

    init() {
        Task {
            self.isLoading = true
            try await updateNotifications()
            self.isLoading = false
            filteredNotifications = notifications
        }
    }

    private func updateNotifications() async throws {
        self.notifications = try await ActivityService.fetchUserActivity()
        
        await withThrowingTaskGroup(of: Void.self, body: { group in
            for notification in notifications {
                group.addTask { try await self.updateNotificationMetadata(notification: notification) }
            }
        })
    }
    
    private func updateNotificationMetadata(notification: Activity) async throws {
        guard let indexOfNotification = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        
        async let notificationUser = try await UserService.fetchUser(withUID: notification.senderUID)
        var user = try await notificationUser
        
        if notification.type == .follow {
            async let isFollowed = await UserService.checkIfUserIsFollowedWithUID(notification.senderUID)
            user.isFollowed = await isFollowed
        }

        self.notifications[indexOfNotification].user = user
        
        if let postID = notification.postID {
            async let postSnapshot = await FirestoreConstants.posts.document(postID).getDocument()
            self.notifications[indexOfNotification].post = try? await postSnapshot.data(as: Post.self)
        }
    }
}
