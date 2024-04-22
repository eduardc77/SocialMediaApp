//
//  ProfileTabsViewModel.swift
//  SocialMedia
//

import Combine
import SocialMediaNetwork
import Firebase

@MainActor
final class ProfileTabsViewModel: ObservableObject {
    let user: SocialMediaNetwork.User
    
    init(user: SocialMediaNetwork.User) {
        self.user = user
    }
    
    func contentUnavailableText(filter: ProfilePostFilter) -> String {
        let name = user.isCurrentUser ? "You" : user.username
        let nextWord = user.isCurrentUser ? "haven't" : "hasn't"
        let contentType = filter == .replies ? "replies" : "posts"
        
        return "\(name) \(nextWord) \(filter.noContentFilterVerb) any \(contentType) yet."
    }
}
