//
//  SearchGridItem.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct SearchGridItem: View {
    @ObservedObject var model: SearchItemViewModel
    
    init(user: User, thumbnailSize: CGFloat) {
        self.model = SearchItemViewModel(user: user, thumbnailSize: thumbnailSize)
    }
    
    var body: some View {
        VStack {
            CircularProfileImageView(profileImageURL: model.user.profileImageURL, size: .custom(width: model.thumbnailSize, height: model.thumbnailSize))
            
            VStack {
                Text(model.user.username)
                    .bold()
                Text(model.user.fullName)
            }
            .foregroundStyle(Color.primary)
            .font(.footnote)
            .multilineTextAlignment(.center)
            
            if !model.user.isCurrentUser {
                Button {
                    Task {
                        try await model.toggleFollow()
                    }
                } label: {
                    Text(model.isFollowed ? "Following" : "Follow")
                }
                .buttonStyle(.secondary(buttonWidth: nil, loading: model.loading, isActive: model.isFollowed))
                .overlay {
                    if model.loading {
                        ProgressView()
                    }
                }
                .disabled(model.loading)
            }
        }
    }
}

#Preview {
    SearchGridItem(user: Preview.user, thumbnailSize: 50).padding()
}
