//
//  CircularProfileImageView.swift
//  SocialMedia
//

import SwiftUI

public struct CircularProfileImageView: View {
    private let profileImageURL: String?
    private let size: ImageSize
    private let contentMode: ContentMode
    
    public init(profileImageURL: String?, size: ImageSize = .small, contentMode: ContentMode = .fill) {
        self.profileImageURL = profileImageURL
        self.size = size
        self.contentMode = contentMode
    }
    
    public var body: some View {
        Group {
            if let profileURLString = profileImageURL, let profileUrl = URL(string: profileURLString) {
                AsyncImageView(url: profileUrl, contentMode: contentMode)
                    .frame(maxWidth: size.value.width, maxHeight: size.value.height)
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
    CircularProfileImageView(profileImageURL: "https://docs-assets.developer.apple.com/published/9c4143a9a48a080f153278c9732c03e7/Image-1~dark@2x.png", size: .xxLarge)
}
