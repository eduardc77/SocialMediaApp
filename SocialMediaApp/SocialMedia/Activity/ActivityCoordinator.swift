//
//  ActivityCoordinator.swift
//  SocialMedia
//

import SwiftUI
import Combine
import SocialMediaNetwork

struct ActivityCoordinator: View {
    @State private var router = ViewRouter()
    @EnvironmentObject private var tabRouter: AppScreenRouter
    
    var body: some View {
        NavigationStack(path: $router.path) {
            ActivityView()
                .navigationDestination(for: AnyHashable.self) { destination in
                    switch destination {
                    case let userDestination as UserDestination:
                        self.user(destination: userDestination)
                    case let postType as PostType:
                        PostDetailsView(router: router, postType: postType)
                    case let category as PostCategory:
                        PostCategoryDetailView(router: router, category: category)
                    default:
                        EmptyView()
                    }
                }
                .onReceive(tabRouter.$tabReselected) { tabReselected in
                    guard tabReselected, tabRouter.selection == .activity, !router.path.isEmpty else { return }
                    router.popToRoot()
                }
                .environment(router)
        }
    }
    
    @MainActor
    @ViewBuilder private func user(destination: UserDestination) -> some View {
        switch destination {
        case .profile(let user):
            ProfileTabsContainer(router: router, user: user)
        case .relations(let user):
            UserRelationsView(router: router, user: user)
        }
    }
}

#Preview {
    SearchCoordinator()
        .environmentObject(AppScreenRouter())
        .environment(ViewRouter())
}
