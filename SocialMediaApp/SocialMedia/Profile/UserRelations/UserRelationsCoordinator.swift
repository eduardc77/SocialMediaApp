//
//  UserRelationsCoordinator.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserRelationsCoordinator: View {
    var user: User
    @State private var router = ViewRouter()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            UserRelationsTabsContainer(router: router, user: user)
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
        }
    }
}
