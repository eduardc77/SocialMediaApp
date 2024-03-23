//
//  ProfilePostFilter.swift
//  SocialMedia
//

import Foundation

enum ProfilePostFilter: String, Hashable, CaseIterable, Identifiable {
    case posts
    case replies
    case liked
    case saved
    
    var id: String { rawValue }
    
    var title: String {rawValue.capitalized }
    
    var noContentFilterVerb: String {
        switch self {
        case .liked, .saved:
            return rawValue
        default:
            return "posted"
        }
    }
}
