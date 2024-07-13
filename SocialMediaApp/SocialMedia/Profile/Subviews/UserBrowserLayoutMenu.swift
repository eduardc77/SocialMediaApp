//
//  UserBrowserLayoutMenu.swift
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

enum UserSortOrder: Hashable {
    case name
    case popularity
    case engagement
}

struct UserBrowserLayoutMenu: View {
    @Binding var layout: BrowserLayout
    @Binding var sort: UserSortOrder
    
    public var body: some View {
        Menu {
            Picker("Layout", selection: $layout) {
                ForEach(BrowserLayout.allCases) { option in
                    Label(option.title, systemImage: option.imageName)
                        .tag(option)
                }
            }
            .pickerStyle(.inline)
            
            Picker("Sort", selection: $sort) {
                Label("Name", systemImage: "textformat")
                    .tag(UserSortOrder.name)
                Label("Popularity", systemImage: "trophy")
                    .tag(UserSortOrder.popularity)
                Label("Engagement", systemImage: "person.crop.circle.badge.checkmark")
                    .tag(UserSortOrder.engagement)
            }
            .pickerStyle(.inline)
        } label: {
            Label("Layout Options", systemImage: layout.imageName)
                .labelStyle(.iconOnly)
        }
    }
}
