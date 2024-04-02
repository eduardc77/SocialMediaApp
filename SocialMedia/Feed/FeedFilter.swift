//
//  FeedFilter.swift
//  SocialMedia
//

enum FeedFilter: String, CaseIterable, Hashable {
    case forYou
    case following
    
    var title: String {
        switch self {
        case .forYou:
            return "For You"
        case .following:
            return self.rawValue.capitalized
        }
    }
}
