//
//  BrowserLayout.swift
//  SocialMedia
//

import SwiftUI

enum BrowserLayout: String, Identifiable, CaseIterable {
    case grid
    case list
    
    var id: BrowserLayout { self }
    
    var title: LocalizedStringKey {
        switch self {
        case .grid: return "Icons"
        case .list: return "List"
        }
    }
    
    var imageName: String {
        switch self {
        case .grid: return "square.grid.2x2"
        case .list: return "list.bullet"
        }
    }
}
