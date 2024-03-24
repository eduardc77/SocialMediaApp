//
//  CurrentUserProfileCoordinator.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct CurrentUserProfileCoordinator: View {
    private var didNavigate: Bool = false
    
    init(didNavigate: Bool = false) {
        self.didNavigate = didNavigate
    }
    
    var body: some View {
        Group {
            if didNavigate {
                CurrentUserProfileView(didNavigate: didNavigate)
            } else {
                NavigationStack {
                    CurrentUserProfileView(didNavigate: didNavigate)
                        .navigationDestination(for: User.self, destination: { user in
                            if user.isCurrentUser {
                                CurrentUserProfileCoordinator(didNavigate: true)
                            } else {
                                ProfileView(user: user)
                            }
                        })
                        .navigationDestination(for: Post.self, destination: { post in
                            PostDetailsView(post: post)
                        })
                        .navigationDestination(for: PostCategory.self, destination: { category in
                            PostCategoryDetailView(category: category)
                        })
                }
            }
        }
    }
}

struct CurrentUserProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CurrentUserProfileCoordinator()
    }
}
