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
            
            VStack {
                Text(user.username)
                    .bold()
                Text(user.fullName)
            }
            .foregroundStyle(Color.primary)
            .font(.footnote)
            .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    SearchView()
}
