//
//  ProfileView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct ProfileView: View {
    @StateObject private var model: UserProfileViewModel
    
    init(user: User) {
        self._model = StateObject(wrappedValue: UserProfileViewModel(user: user))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                if model.isLoading {
                    ProgressView()
                } else if !model.user.privateProfile || model.user.isFollowed {
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
                                model.showUserRelationSheet.toggle()
                            } label: {
                                Text("\(model.user.stats.followersCount) followers")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        CircularProfileImageView(profileImageURL: model.user.profileImageURL, size: .medium)
                    }
                } else {
                    Label("Private Profile", systemImage: "lock")
                }
                
                Button {
                    handleFollowTapped()
                } label: {
                    Text(model.isFollowed ? "Following" : "Follow")                    
                }
                .buttonStyle(.secondary(foregroundColor: model.isFollowed ? Color.primary : Color.secondaryGroupedBackground, isLoading: model.isLoading, isActive: model.isFollowed))
            }
            .padding(.horizontal)
            
            
        }
        .background(Color.groupedBackground)
        .sheet(isPresented: $model.showUserRelationSheet) {
            UserRelationsView(user: model.user)
        }
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

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: preview.user)
    }
}
