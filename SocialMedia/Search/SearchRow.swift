//
//  SearchRow.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct SearchRow: View {
    @ObservedObject var model: SearchViewModel
    let user: User
    let thumbnailSize: CGFloat
    
    private var isFollowed: Bool {
        return user.isFollowed
    }
    
    var body: some View {
        HStack {
            CircularProfileImageView(profileImageURL: user.profileImageURL,
                                     size: .custom(width: thumbnailSize, height: thumbnailSize),
                                     contentMode: .fit)
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .bold()
                Text(user.fullName)
            }
            .font(.footnote)
            
            Spacer()
            
            if !user.isCurrentUser {
                Button {
                    //                        model.toggleFollow(for: user)
                } label: {
                    Text(isFollowed ? "Following" : "Follow")
                }
                .buttonStyle(.borderedProminent)
                //                    .buttonStyle(.secondary(buttonWidth: 100, buttonHeight: 32, foregroundColor: isFollowed ? Color.secondary : Color.primary, inactiveBackgroundColor: Color.clear, isLoading: $model.isLoading, isActive: isFollowed))
            }
        }
    }
}

//struct UserGridItem_Previews: PreviewProvider {
//    static var previews: some View {
//        UserRow(model: SearchViewModel(), user: preview.user)
//    }
//}
