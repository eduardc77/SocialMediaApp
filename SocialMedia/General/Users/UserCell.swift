//
//  UserCell.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserCell: View {
    @ObservedObject var model: SearchViewModel
    let user: User
    
    private var isFollowed: Bool {
        return user.isFollowed
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12) {
                CircularProfileImageView(profileImageURL: user.profileImageURL, size: .small)
                
                VStack(alignment: .leading) {
                    Text(user.username)
                        .bold()
                    
                    Text(user.fullName)
                }
                .font(.footnote)
                
                Spacer()
                
                if !user.isCurrentUser {
                    Button {
                        model.toggleFollow(for: user)
                    } label: {
                        Text(isFollowed ? "Following" : "Follow")
                    }
                    .buttonStyle(.secondary(buttonWidth: 100, buttonHeight: 32, foregroundColor: isFollowed ? Color.secondary : Color.primary, inactiveBackgroundColor: Color.clear, isLoading: $model.isLoading, isActive: isFollowed))
                }
                
            }
            .padding(.horizontal)
            
            Divider()
        }
        .padding(.vertical, 4)
        .foregroundStyle(Color.primary)
    }
}

struct UserCell_Previews: PreviewProvider {
    static var previews: some View {
        UserCell(model: SearchViewModel(), user: preview.user)
    }
}

