//
//  UserProfileHeader.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserProfileHeader: View {
    @StateObject private var model: UserProfileHeaderModel
    @EnvironmentObject private var router: ProfileViewRouter
    @EnvironmentObject private var modalRouter: ModalScreenRouter
    
    init(user: User) {
        self._model = StateObject(wrappedValue: UserProfileHeaderModel(user: user))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(model.user.fullName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        Text(model.user.username)
                            .font(.footnote)
                        Text("Joined \(model.user.joinDate.dateValue().formatted(.dateTime.month(.wide).day(.twoDigits).year()))",
                             comment: "Variable is the calendar date when the person joined.")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    }
                    
                    if model.user.aboutMe.isEmpty {
                        Text(model.user.aboutMe)
                            .font(.subheadline)
                    }
                    Button {
                        modalRouter.presentSheet(destination: ProfileSheetDestination.userRelations(user: model.user))
                    } label: {
                        Text("\(model.user.stats.followersCount) followers")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                CircularProfileImageView(profileImageURL: model.user.profileImageURL, size: .medium)
            }
            
            Button {
                handleFollowTapped()
            } label: {
                Text(model.isFollowed ? "Following" : "Follow")
            }
            .buttonStyle(.secondary(loading: model.loading, isActive: model.isFollowed))
        }
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
    
    func handleFollowTapped() {
        Task {
            if model.isFollowed {
                try await model.unfollow()
            } else {
                try await model.follow()
            }
        }
    }
}

#Preview {
    VStack {
        UserProfileHeader(user: Preview.user).padding()
        Spacer()
    }
}
