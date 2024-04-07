//
//  UserRelationType.swift
//  SocialMedia
//

import Foundation

enum UserRelationType: String, Identifiable, CaseIterable {
    case followers
    case following
    
    var id: UserRelationType { self }
    
    var title: String { rawValue.capitalized }
}
