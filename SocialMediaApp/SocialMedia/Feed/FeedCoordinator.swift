//
//  FeedCoordinator.swift
//  SocialMedia
//

import SwiftUI
import Combine
import SocialMediaNetwork

struct FeedCoordinator: View {
    @State private var router = ViewRouter()
    @EnvironmentObject private var tabRouter: AppScreenRouter
    
    var body: some View {
        NavigationStack(path: $router.path) {
            FeedTabContainer()
                .navigationDestination(for: AnyHashable.self) { destination in
                    switch destination {
                    case let user as User:
                        ProfileTabsContainer(router: router, user: user, didNavigate: true)
                    case let postType as PostType:
                        PostDetailsView(router: router, postType: postType)
                    case let category as PostCategory:
                        PostCategoryDetailView(router: router, category: category)
                    default:
                        EmptyView()
                    }
                }
                .onReceive(tabRouter.$tabReselected) { tabReselected in
                    guard tabReselected, tabRouter.selection == .home, !router.path.isEmpty else { return }
                    router.popToRoot()
                }
                .environment(router)
        }
    }
}

#Preview {
    FeedCoordinator()
        .environment(ModalScreenRouter())
        .environmentObject(AppScreenRouter())
}
