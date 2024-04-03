//
//  SearchCoordinator.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct SearchCoordinator: View {
    @StateObject private var router = SearchViewRouter()
    @EnvironmentObject private var tabRouter: AppTabRouter

    var body: some View {
        NavigationStack(path: $router.path) {
            SearchView()
                .navigationDestination(for: AnyHashable.self) { destination in
                    switch destination {
                    case let user as User:
                        ProfileView(user: user)
                    default: EmptyView()
                    }
                }
                .onReceive(tabRouter.$tabReselected) { tabReselected in
                    guard tabReselected, tabRouter.selection == .search, !router.path.isEmpty else { return }
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
