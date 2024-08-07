//
//  ProfileTabsContainer.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

struct ProfileTabsContainer: View {
    var router: Router
    var user: User
    var didNavigate: Bool = true
    
    @State private var selectedTab: ProfilePostFilter = .posts
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    private var isCompact: Bool {
        if sizeClass == .compact {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        TabsContainer(
            selectedTab: $selectedTab,
            headerTitle: { context in
                VStack(alignment: .leading, spacing: 16) {
                    if user.isCurrentUser {
                        CurrentUserProfileHeader(router: router, didNavigate: didNavigate)
                    } else {
                        UserProfileHeader(router: router, user: user)
                    }
                }
                .padding()
                .headerStyle(OffsetHeaderStyle<ProfilePostFilter>(fade: true), context: context)
                .minTitleHeight(.content(scale: 0.01))
            },
            headerTabBar: { context in
                ContainerTabBar<ProfilePostFilter>(selectedTab: $selectedTab, sizing: .equalWidth, context: context)
                    .foregroundStyle(
                        Color.primary,
                        Color.primary.opacity(0.7)
                    )
            },
            headerBackground: { context in
                Color.clear.background(.bar)
            },
            content: {
                ForEach(ProfilePostFilter.allCases) { tab in
                    ProfileTabsContentView(
                        router: router,
                        user: user,
                        tab: tab,
                        contentUnavailable: user.privateProfile && !(user.isFollowed)
                    )
                    .tabItem(tab: tab, label: .primary(tab.title))
                }
            }
        )
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .background(Color.groupedBackground)
    }
}

#Preview {
    CurrentUserProfileHeader(router: ViewRouter())
        .padding()
        .environment(ModalScreenRouter())
        .environment(ViewRouter())
}
