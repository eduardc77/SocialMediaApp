//
//  ActivityRowView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

struct ActivityRowView: View {
    private var router: any Router
    @ObservedObject private var model: ActivityRowViewModel
    
    init(router: any Router, activity: Activity) {
        self.router = router
        model = ActivityRowViewModel(activity: activity)
    }
    
    var body: some View {
        HStack(spacing: 10) {
            NavigationButton {
                router.push(model.activity.user)
            } label: {
                ZStack(alignment: .bottomTrailing) {
                    CircularProfileImageView(profileImageURL: model.activity.user?.profileImageURL)
                    ActivityBadgeView(type: model.activity.type)
                        .offset(x: 8, y: 4)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(model.activity.user?.username ?? "")
                        .bold()
                        .foregroundStyle(Color.primary)
                    
                    Text(model.activity.timestamp.timestampString())
                        .foregroundStyle(Color.secondary)
                }
                
                Text(model.activityMessage)
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
            }
            .font(.footnote)
            
            Spacer()
            
            if model.activity.type == .follow {
                Button {
                    Task {
                        try await model.toggleFollow()
                    }
                } label: {
                    Text(model.isFollowed ? "Following" : "Follow")
                }
                .buttonStyle(.secondary(buttonWidth: nil, loading: model.loading, isActive: model.isFollowed))
                .disabled(model.loading)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

#Preview {
    ActivityRowView(router: ActivityViewRouter(), activity: Preview.activityModel)
}
