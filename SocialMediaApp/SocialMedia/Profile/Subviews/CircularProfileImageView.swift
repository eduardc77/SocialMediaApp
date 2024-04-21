//
//  CircularProfileImageView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI

struct CircularProfileImageView: View {
    var profileImageURL: String?
    var size: ImageSize = .small
    var contentMode: ContentMode = .fill
    
    var body: some View {
        Group {
            if let profileURLString = profileImageURL, let profileUrl = URL(string: profileURLString) {
                AsyncImageView(url: profileUrl, size: size)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .foregroundStyle(Color.secondary.opacity(0.6))
            }
        }
        .frame(width: size.value.width, height: size.value.height)
        .clipShape(Circle())
    }
}

#Preview {
    CircularProfileImageView()
}
