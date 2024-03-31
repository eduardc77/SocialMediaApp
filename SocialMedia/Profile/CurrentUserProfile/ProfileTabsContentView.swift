//
//  ProfileTabsContentView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

final class RefreshedFilterModel: ObservableObject {
    @Published var refreshedFilter: ProfilePostFilter = .posts
}

struct ProfileTabsContentView<Content: View>: View {
    @StateObject private var refreshedFilterModel = RefreshedFilterModel()
    @StateObject private var model: UserContentListViewModel
    
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
    
    init(user: User, tab: ProfilePostFilter, @ViewBuilder info: @escaping () -> Content) {
        self._model = StateObject(wrappedValue: UserContentListViewModel(user: user))
        self.tab = tab
        self.info = info
    }
    
    init(user: User, tab: ProfilePostFilter) where Content == EmptyView {
        self.init(user: user, tab: tab, info: { EmptyView() })
    }
    
    var body: some View {
        TabContainerScroll(
            tab: tab, refreshableAction: onRefresh) { _ in
                LazyVStack(spacing: 0) {
                    info()
                        .padding([.leading, .trailing, .top], 20)
                        .id(0)
                    switch tab {
                    case .posts:
                        UserPostsView(user: model.user, noContentText: model.noContentText(filter: .saved))
                        
                    case .replies:
                        Group {
                            if model.replies.isEmpty {
                                VStack {
                                    Text(model.noContentText(filter: .replies))
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondary)
                                }
                            } else {
                                ForEach(Array(model.replies.enumerated()), id: \.element) { index, reply in
                                    ReplyRow(reply: reply)
                                        .padding(.vertical, 5)
                                        .padding(.horizontal, 10)
                                }
                            }
                        }
                        
                    case .liked:
                        UserLikedPostsView(user: model.user, noContentText: model.noContentText(filter: .liked))
                        
                    case .saved:
                        UserSavedPostsView(user: model.user, noContentText: model.noContentText(filter: .saved))
                    }
                }
                .padding(.vertical, 5)
                .scrollTargetLayout()
                .environmentObject(refreshedFilterModel)
            }
            .background(Color.groupedBackground)
    }
    
    func onRefresh() {
        refreshedFilterModel.refreshedFilter = tab
    }
}

