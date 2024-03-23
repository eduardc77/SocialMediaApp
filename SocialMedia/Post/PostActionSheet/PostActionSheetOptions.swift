//
//  PostActionSheetOptions.swift
//  SocialMedia
//

import Foundation

enum UserPostActionSheetOptions {
    case delete
    
    var title: String {
        switch self {
        case .delete:
            return "Delete"
        }
    }
    
    var iconName: String {
        switch self {
        case .delete:
            return "trash"
        }
    }
}

enum PostActionSheetOptions {
    case unfollow
    case mute
    case hide
    case report
    case block
    
    var title: String {
        switch self {
        case .unfollow:
            return "Unfollow"
        case .mute:
            return "Mute"
        case .hide:
            return "Hide"
        case .report:
            return "Report"
        case .block:
            return "Block"
        }
    }
    
    var iconName: String {
        switch self {
        case .unfollow:
            return "person.crop.circle.badge.xmark"
        case .mute:
            return "speaker.slash"
        case .hide:
            return "eye.slash"
        case .report:
            return "exclamationmark.bubble"
        case .block:
            return "hand.raised.slash"
        }
    }
}
