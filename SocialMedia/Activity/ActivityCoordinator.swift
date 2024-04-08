//
//  ActivityCoordinator.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaData
import SocialMediaNetwork

struct ActivityCoordinator: View {
    @StateObject private var router = ActivityViewRouter()
    @EnvironmentObject private var tabRouter: AppScreenRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            ActivityView()
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
                    guard tabReselected, tabRouter.selection == .activity, !router.path.isEmpty else { return }
                    router.popToRoot()
                }
                .environmentObject(router)
        }
    }
}

#Preview {
    SearchCoordinator()
        .environmentObject(SearchViewRouter())
}
