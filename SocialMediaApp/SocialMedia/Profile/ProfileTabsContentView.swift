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

struct ProfileTabsContentView<Content: View>: View {
    @StateObject private var model: ProfileTabsViewModel
    @StateObject private var refreshedFilterModel = RefreshedFilterModel()
    var router: any Router
    var contentUnavailable: Bool = false
    
    private let tab: ProfilePostFilter
    @ViewBuilder private let info: () -> Content
    
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
    
    init(router: any Router, user: User, tab: ProfilePostFilter, contentUnavailable: Bool = false, @ViewBuilder info: @escaping () -> Content) {
        self._model = StateObject(wrappedValue: ProfileTabsViewModel(user: user))
        self.router = router
        self.tab = tab
        self.contentUnavailable = contentUnavailable
        self.info = info
    }
    
    init(router: any Router, user: User, tab: ProfilePostFilter, contentUnavailable: Bool = false) where Content == EmptyView {
        self.init(router: router, user: user, tab: tab, contentUnavailable: contentUnavailable, info: { EmptyView() })
    }
    
    var body: some View {
        TabContainerScroll(
            tab: tab, refreshableAction: onRefresh) { _ in
                LazyVStack(spacing: 0) {
                    info()
                        .padding([.leading, .trailing, .top], 20)
                        .id(0)
                    
                    if !contentUnavailable {
                        switch tab {
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
                .padding(.vertical, 5)
                .scrollTargetLayout()
            }
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .background(Color.groupedBackground)
            .environmentObject(refreshedFilterModel)
    }
    
    func onRefresh() {
        refreshedFilterModel.refreshedFilter = tab
    }
}
