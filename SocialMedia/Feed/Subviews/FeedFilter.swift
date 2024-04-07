//
//  FeedFilter.swift
//  SocialMedia
//

enum FeedFilter: String, Identifiable, CaseIterable {
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
