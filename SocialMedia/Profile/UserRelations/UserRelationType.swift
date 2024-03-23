//
//  UserRelationType.swift
//  SocialMedia
//

import Foundation

enum UserRelationType: Int, CaseIterable, Identifiable {
    case followers
    case following
    
    var title: String {
        switch self {
        case .followers: return "Followers"
        case .following: return "Following"
        }
    }
    
    var id: Int { return self.rawValue }
}
