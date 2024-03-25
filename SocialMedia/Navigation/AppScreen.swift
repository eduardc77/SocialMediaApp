//
//  AppScreen.swift
//  SocialMedia
//

import SwiftUI

enum AppScreen: String, Codable, Hashable, Identifiable, CaseIterable {
    case home
    case search
    case newPost
    case activity
    case profile
    
    var id: AppScreen { self }
}

extension AppScreen {
    var title: String {
        switch self {
        case .newPost:
            "New Post"
        default:
            self.rawValue.capitalized
        }
    }
    
    var icon: String {
        switch self {
        case .home:
            "house"
        case .search:
            "magnifyingglass"
        case .newPost:
            "plus"
        case .activity:
            "heart"
        case .profile:
            "person"
        }
    }
    
    @ViewBuilder
    var label: some View {
        Label(title, systemImage: icon)
    }
    
    @ViewBuilder
    var destination: some View {
        switch self {
        case .home:
            FeedView()
        case .search:
            SearchView()
        case .newPost:
            NewPostCoordinator()
        case .activity:
            ActivityView()
        case .profile:
            CurrentUserProfileCoordinator()
        }
    }
}
