//
//  CurrentUserProfileHeader.swift
//  SocialMedia
//

import SwiftUI
import Combine
import SocialMediaUI

struct CurrentUserProfileHeader: View {
    @State private var model = CurrentUserProfileHeaderModel()
    
    var router: Router
    @Environment(ModalScreenRouter.self) private var modalRouter
    
    var didNavigate: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(model.currentUser?.fullName ?? "")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(model.currentUser?.username ?? "")
                            .font(.footnote)
                        
                        if let joinDate = model.currentUser?.joinDate.dateValue() {
                            Text("Joined \(joinDate.formatted(.dateTime.month(.wide).day(.twoDigits).year()))",
                                 comment: "Variable is the calendar date when the person joined.")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                        }
                    }
                }
                Spacer()
                
                if model.updatingProfile {
                    ProgressView()
                } else {
                    CircularProfileImageView(profileImageURL: model.currentUser?.profileImageURL, size: .medium)
                }
            }
            
            if let bio = model.currentUser?.aboutMe, !bio.isEmpty {
                Text(bio)
                    .font(.subheadline)
            }
            
            NavigationButton {
                if let user = model.currentUser {
                    router.push(UserDestination.relations(user: user))
                }
            } label: {
                if let followersCount = model.currentUser?.stats.followersCount {
                    Text("\(followersCount) followers")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.accentColor)
                } else {
                    ProgressView()
                }
            }
            .buttonStyle(.borderless)
            
            HStack {
                Button {
                    modalRouter.presentSheet(
                        destination:
                            ProfileSheetDestination
                            .editProfile(
                                model: model))
                } label: {
                    Text("Edit Profile")
                }
                .buttonStyle(.secondary)
                
                Button {
                    print("Share Profile button tapped.")
                } label: {
                    Text("Share Profile")
                }
                .buttonStyle(.secondary)
            }
        }
        .toolbar {
            if !didNavigate {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        router.push(SettingsDestination.settings)
                    } label: {
                        Image(systemName: "line.3.horizontal")

                    }
                }
            }
        }
        .onFirstAppear {
            model.loadUserData()
        }
    }
}

#Preview {
    CurrentUserProfileHeader(router: ViewRouter())
        .padding()
        .environment(ModalScreenRouter())
}
