//
//  FeedFilter.swift
//  SocialMedia
//

import SocialMediaUI

enum FeedFilter: String, Identifiable, Hashable, CaseIterable, TopFilter {
    case forYou
    case following
    
    var id: FeedFilter { self }
    
    var title: String {
        switch self {
        case .forYou:
            return "For You"
        case .following:
            return self.rawValue.capitalized
        }
    }
}
