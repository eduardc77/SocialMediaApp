//
//  CurrentUserProfileHeader.swift
//  SocialMedia
//

import SwiftUI

struct CurrentUserProfileHeader: View {
    @StateObject private var model = CurrentUserProfileHeaderModel()
    @StateObject private var imageData = ImageData()
    @EnvironmentObject private var router: ProfileViewRouter
    @EnvironmentObject private var modalRouter: ModalScreenRouter
    
    var didNavigate: Bool = false
    
    var body: some View {
        if !didNavigate {
            HStack {
                Spacer()
                
                NavigationButton {
                    router.push(SettingsDestination.settings)
                } label: {
                    Image(systemName: "line.3.horizontal")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary)
                }
            }
        }
        
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
        
        if let bio = model.currentUser?.aboutMe {
            Text(bio)
                .font(.subheadline)
        }
        
        Button {
            if let user = model.currentUser {
                modalRouter.presentSheet(destination: ProfileSheetDestination.userRelations(user: user))
            }
        } label: {
            Text("\(model.currentUser?.stats.followersCount ?? 0) followers")
                .font(.subheadline)
                .foregroundStyle(Color.accentColor)
        }
        .buttonStyle(.borderless)
        
        HStack {
            Button {
                modalRouter.presentSheet(
                    destination:
                        ProfileSheetDestination
                        .editProfile(
                            model: model,
                            imageData: imageData))
            } label: {
                Text("Edit Profile")
            }
            .buttonStyle(.secondary(foregroundColor: Color.primary))
            
            Button {
                print("Share Profile button tapped.")
            } label: {
                Text("Share Profile")
            }
            .buttonStyle(.secondary(foregroundColor: Color.primary))
        }
        .onFirstAppear {
            model.loadUserData()
        }
        .onReceive(imageData.$imageState) { newValue in
            model.imageState = newValue
        }
    }
}

#Preview {
    CurrentUserProfileHeader()
}
