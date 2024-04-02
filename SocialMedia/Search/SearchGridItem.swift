//
//  SearchGridItem.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct SearchGridItem: View {
    var user: User
    var thumbnailSize: CGFloat
    
    var body: some View {
        VStack {
            CircularProfileImageView(profileImageURL: user.profileImageURL, size: .custom(width: thumbnailSize, height: thumbnailSize))
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .bold()
                Text(user.fullName)
            }
            .font(.footnote)
            .multilineTextAlignment(.center)
            
            if !user.isCurrentUser {
                Button {
                    //                    model.toggleFollow(for: user)
                } label: {
                    Text(user.isFollowed ? "Following" : "Follow")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                //                .buttonStyle(.secondary(buttonWidth: 100, buttonHeight: 32, foregroundColor: isFollowed ? Color.secondary : Color.primary, inactiveBackgroundColor: Color.clear, isLoading: $model.isLoading, isActive: isFollowed))
            }
        }
    }
}

#Preview {
    SearchView()
}
