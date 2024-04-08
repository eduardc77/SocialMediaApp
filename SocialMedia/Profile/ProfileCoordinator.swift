//
//  ProfileCoordinator.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaData
import SocialMediaNetwork

struct ProfileCoordinator: View {
    @StateObject private var router = ProfileViewRouter()
    private var didNavigate: Bool = false
    @EnvironmentObject private var tabRouter: AppScreenRouter
    
    init(didNavigate: Bool = false) {
        self.didNavigate = didNavigate
    }
    
    var body: some View {
        
        NavigationStack(path: $router.path) {
            if let user = UserService.shared.currentUser {
                ProfileTabsContainer(router: router, user: user, didNavigate: didNavigate)
                    .navigationDestination(for: AnyHashable.self) { destination in
                        switch destination {
                        case let user as User:
                            ProfileTabsContainer(router: router, user: user, didNavigate: true)
                        case let postType as PostType:
                            PostDetailsView(router: router, postType: postType)
                        case let category as PostCategory:
                            PostCategoryDetailView(router: router, category: category)
                        case let settingsDestination as SettingsDestination:
                            settings(destination: settingsDestination)
                        default:
                            EmptyView()
                        }
                    }
            }
        }
        .onReceive(tabRouter.$tabReselected) { tabReselected in
            guard tabReselected, tabRouter.selection == .profile, !router.path.isEmpty else { return }
            router.popToRoot()
        }
        .environmentObject(router)
    }
    
    @ViewBuilder
    private func settings(destination: SettingsDestination) -> some View {
        switch destination {
        case .settings:
            SettingsView()
                .environmentObject(router)
        case .termsOfUse:
            PlaceholderText(title: .termsOfUse)
        case .privacyPolicy:
            PlaceholderText(title: .privacyPolicy)
        case .about:
            AboutView()
        case .feedback:
            FeedbackView()
        }
    }
}

enum SettingsDestination: Hashable {
    case settings
    case termsOfUse
    case privacyPolicy
    case about
    case feedback
    
}

#Preview {
    ProfileCoordinator()
}
