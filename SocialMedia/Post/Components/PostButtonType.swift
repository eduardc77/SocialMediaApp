//
//  PostButtonType.swift
//  SocialMedia
//

import SwiftUI

enum PostButtonType: Identifiable, CaseIterable {
    case like
    case reply
    case repost
    case save
    
    var id: PostButtonType { self }
}

extension PostButtonType {
    
    var title: String {
        switch self {
            case .like:
                return "Like"
            case .reply:
                return "Reply"
            case .repost:
                return "Repost"
            case .save:
                return "Save"
        }
    }
    
    var icon: String {
        switch self {
            case .like:
                return "heart"
            case .reply:
                return "message"
            case .repost:
                return "arrow.2.squarepath"
            case .save:
                return "bookmark"
        }
    }
    
    var iconFilled: String {
        icon + ".fill"
    }
}

extension PostButtonType {
    var color: Color {
        switch self {
            case .like:
                return .red
            case .reply:
                return .blue
            case .repost:
                return .green
            case .save:
                return .orange
        }
    }
}
