//
//  UserProfileHeader.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

@MainActor
struct UserProfileHeader: View {
    @State private var model: UserProfileHeaderModel
    var router: Router
    @Environment(ModalScreenRouter.self) private var modalRouter
    
    init(router: Router, user: User) {
        self.router = router
        model = UserProfileHeaderModel(user: user)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
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
                }
                Spacer()
                CircularProfileImageView(profileImageURL: model.user.profileImageURL, size: .medium)
            }
            
            if !model.user.aboutMe.isEmpty {
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
            
            Button {
                handleFollowTapped()
            } label: {
                Text(model.isFollowed ? "Following" : "Follow")
            }
            .buttonStyle(.secondary(loading: model.loading, isActive: model.isFollowed))
            .disabled(model.loading)
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
        UserProfileHeader(router: ViewRouter(), user: Preview.user).padding()
        Spacer()
    }
    .environment(ModalScreenRouter())
}
