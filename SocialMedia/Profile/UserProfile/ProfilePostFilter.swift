//
//  ProfilePostFilter.swift
//  SocialMedia
//

import Foundation

enum ProfilePostFilter: String, Hashable, CaseIterable {
    case posts
    case replies
    case liked
    case saved
    
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
