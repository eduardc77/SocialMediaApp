//
//  ProfilePostFilter.swift
//  SocialMedia
//

import Foundation
import SocialMediaUI

enum ProfilePostFilter: String, Identifiable, CaseIterable, TopFilter {
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
