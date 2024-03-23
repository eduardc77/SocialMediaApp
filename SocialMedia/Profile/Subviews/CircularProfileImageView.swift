//
//  CircularProfileImageView.swift
//  SocialMedia
//

import SwiftUI

struct CircularProfileImageView: View {
    var profileImageURL: String?
    var size = ImageSize.medium
    
    var body: some View {
        Group {
            if let profileURLString = profileImageURL, let profileUrl = URL(string: profileURLString) {
                AsyncImageView(url: profileUrl, size: size)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
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