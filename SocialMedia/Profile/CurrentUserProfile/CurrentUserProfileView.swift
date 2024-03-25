//
//  CurrentUserProfileView.swift
//  SocialMedia
//

import SwiftUI

struct CurrentUserProfileView: View {
    @StateObject private var model = CurrentUserProfileViewModel()
    @StateObject private var imageData = ImageData()
    var didNavigate: Bool = false
    
    @EnvironmentObject private var modalRouter: ModalScreenRouter
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    private var isCompact: Bool {
        if sizeClass == .compact {
            return true
        } else {
            return false
        }
    }
    
    @State private var selectedTab: ProfilePostFilter = .posts

    // MARK: - Body

    var body: some View {
        TabsContainer(
            selectedTab: $selectedTab,
            headerTitle: { context in
                VStack(alignment: .leading, spacing: 16) {
                    if !didNavigate {
                        HStack {
                            Spacer()
                            
                            NavigationLink {
                                SettingsView()
                            } label: {
                                Image(systemName: "line.3.horizontal")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color.primary)
                            }
                        }
                        .padding(.top, isCompact ? 0 : 20)
                        .padding([.bottom, .horizontal], isCompact ? 10 : 20)
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
                            ProgressView().frame(width: 50, height: 50)
                        } else {
                            CircularProfileImageView(profileImageURL: model.currentUser?.profileImageURL)
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
                        Text("\(model.currentUser?.stats?.followersCount ?? 0) followers")
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
                }
                .padding(.horizontal)
                .headerStyle(OffsetHeaderStyle<ProfilePostFilter>(fade: true), context: context)
            },
            headerTabBar: { context in
                ContainerTabBar<ProfilePostFilter>(selectedTab: $selectedTab, sizing: .equalWidth, context: context)
                    .foregroundStyle(
                        Color.primary,
                        Color.primary.opacity(0.7)
                    )
     
            },
            headerBackground: { context in
               Color.groupedBackground
            },
            content: {
                if let user = model.currentUser {
                    ForEach(ProfilePostFilter.allCases) { tab in
                        ProfileTabsContentView(
                            user: user,
                            tab: tab
                        )
                        .containerTabItem(tab: tab, label: .primary(tab.title))
                    }
                }
            }
        )
        .background(Color.groupedBackground)
     
        .onFirstAppear {
            model.loadUserData()
        }
        .onReceive(imageData.$imageState) { newValue in
            model.imageState = newValue
        }
    }
}

#Preview {
    CurrentUserProfileView()
}
