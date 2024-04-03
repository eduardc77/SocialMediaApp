//
//  CurrentUserProfileCoordinator.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct CurrentUserProfileCoordinator: View {
    @StateObject private var router = ProfileViewRouter()
    private var didNavigate: Bool = false
    @EnvironmentObject private var tabRouter: AppTabRouter
    
    init(didNavigate: Bool = false) {
        self.didNavigate = didNavigate
    }
    
    var body: some View {
        Group {
            if didNavigate {
                CurrentUserProfileView(didNavigate: didNavigate)
            } else {
                NavigationStack(path: $router.path) {
                    CurrentUserProfileView(didNavigate: didNavigate)
                        .navigationDestination(for: AnyHashable.self) { destination in
                            switch destination {
                            case let user as User:
                                if user.isCurrentUser {
                                    CurrentUserProfileCoordinator(didNavigate: true)
                                } else {
                                    ProfileView(user: user)
                                }
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
    CurrentUserProfileCoordinator()
}
