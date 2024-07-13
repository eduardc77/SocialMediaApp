//
//  SearchRow.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

struct SearchRow: View {
    @Bindable private var model: SearchItemViewModel
    
    init(user: User, thumbnailSize: CGFloat) {
        model = SearchItemViewModel(user: user, thumbnailSize: thumbnailSize)
    }
    
    var body: some View {
        HStack {
            CircularProfileImageView(profileImageURL: model.user.profileImageURL,
                                     size: .custom(width: model.thumbnailSize, height: model.thumbnailSize),
                                     contentMode: .fit)
            
            VStack(alignment: .leading) {
                Text(model.user.username)
                    .bold()
                Text(model.user.fullName)
            }
            .font(.footnote)
            .foregroundStyle(Color.primary)
            Spacer()
            
            if !model.user.isCurrentUser {
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
    }
}

#Preview {
    SearchRow(user: Preview.user, thumbnailSize: 30)
}
