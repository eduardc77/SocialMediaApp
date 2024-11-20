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
    @State private var headerOffsets: (CGFloat,CGFloat) = (0,0)
    
    @StateObject private var refreshedFilterModel = RefreshedFilterModel()
    
    @Environment(\.horizontalSizeClass) private var sizeClass
    
    private var isCompact: Bool {
        if sizeClass == .compact {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        ScrollView(.vertical) {
            Group {
                if user.isCurrentUser {
                    CurrentUserProfileHeader(router: router, didNavigate: didNavigate)
                } else {
                    UserProfileHeader(router: router, user: user)
                }
            }
            .padding(.horizontal)
            
            LazyVStack(pinnedViews: [.sectionHeaders]) {
                Section {
                    ProfileTabsContentView(router: router, user: user, selectedTab: selectedTab, contentUnavailable: user.privateProfile && !(user.isFollowed)
                    )
                } header: {
                    TopFilterBar(currentFilter: $selectedTab)
                        .background(Color.groupedBackground)
                }
            }
        }
        .refreshable {
            onRefresh()
        }
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .background(Color.groupedBackground)
        .environmentObject(refreshedFilterModel)
    }
    
    func onRefresh() {
        refreshedFilterModel.refreshedFilter = selectedTab
    }
}

#Preview {
    CurrentUserProfileHeader(router: ViewRouter())
        .padding()
        .environment(ModalScreenRouter())
        .environment(ViewRouter())
}

