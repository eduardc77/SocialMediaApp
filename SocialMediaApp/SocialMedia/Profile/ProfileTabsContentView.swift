//
//  ProfileTabsContentView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

final class RefreshedFilterModel: ObservableObject {
    @Published var refreshedFilter: ProfilePostFilter = .posts
}

@MainActor
struct ProfileTabsContentView: View {
    @State private var model: ProfileTabsViewModel
    @StateObject private var refreshedFilterModel = RefreshedFilterModel()
    var router: Router
    var contentUnavailable: Bool = false
    
    private let selectedTab: ProfilePostFilter

    @Environment(\.horizontalSizeClass) private var sizeClass
    
    private var isCompact: Bool {
        
        if sizeClass == .compact {
            return true
        } else {
            return false
        }
    }
    
    private var profileImageSize: ImageSize {
#if os(iOS)
        return isCompact ? .small : .large
#else
        return isCompact ? .xSmall : .medium
#endif
    }
    
    init(router: Router, user: User, selectedTab: ProfilePostFilter, contentUnavailable: Bool = false) {
        model = ProfileTabsViewModel(user: user)
        self.router = router
        self.selectedTab = selectedTab
        self.contentUnavailable = contentUnavailable
    }
    
    var body: some View {
        Group {
            if !contentUnavailable {
                switch selectedTab {
                case .posts:
                    UserPostsView(router: router, user: model.user, contentUnavailableText: model.contentUnavailableText(filter: .posts))
                    
                case .replies:
                    UserRepliesView(router: router, user: model.user, contentUnavailableText: model.contentUnavailableText(filter: .replies))
                    
                case .liked:
                    UserLikedPostsView(router: router, user: model.user, contentUnavailableText: model.contentUnavailableText(filter: .liked))
                    
                case .saved:
                    UserSavedPostsView(router: router, user: model.user, contentUnavailableText: model.contentUnavailableText(filter: .saved))
                }
            } else {
                ContentUnavailableView(
                    "Private Account",
                    systemImage: "lock.fill",
                    description: Text("Follow this account to see their content.")
                )
            }
        }
    }
}

#Preview {
    ProfileTabsContentView(router: ViewRouter(), user: Preview.user, selectedTab: .posts)
        .environment(ModalScreenRouter())
}
