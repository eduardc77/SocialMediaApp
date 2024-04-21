//
//  ProfilePostFilter.swift
//  SocialMedia
//

import Foundation

enum ProfilePostFilter: String, Identifiable, CaseIterable {
    case posts
    case replies
    case liked
    case saved
    
    var id: ProfilePostFilter { self }
    
    var title: String { rawValue.capitalized }
    
    var noContentFilterVerb: String {
        switch self {
        case .liked, .saved:
            return rawValue
        default:
            return "posted"
        }
    }
}
