//
//  ActivityFilter.swift
//  SocialMedia
//

enum ActivityFilter: String, CaseIterable, Identifiable {
    case all
    case follow
    case reply
    case like
    
    var id: ActivityFilter { self }
    
    var title: String {
        switch self {
        case .all: return "All"
        case .follow: return "Follows"
        case .reply: return "Replies"
        case .like: return "Likes"
        }
    }
}
