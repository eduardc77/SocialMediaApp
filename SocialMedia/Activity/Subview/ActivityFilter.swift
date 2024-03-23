//
//  ActivityFilter.swift
//  SocialMedia
//

enum ActivityFilter: Int, CaseIterable, Identifiable, Codable {
    case all
    case follows
    case replies
    case likes

    var title: String {
        switch self {
        case .all: return "All"
        case .follows: return "Follows"
        case .replies: return "Replies"
        case .likes: return "Likes"
        }
    }
    
    var id: Int { return self.rawValue }
}
