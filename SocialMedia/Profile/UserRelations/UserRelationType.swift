//
//  UserRelationType.swift
//  SocialMedia
//

import SocialMediaUI

enum UserRelationType: String, TopFilter {
    case followers
    case following
    
    var id: UserRelationType { self }
    
    var title: String { rawValue.capitalized }
}
