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

enum UserSort: String {
    case name
    case popularity
    case engagement
    
    var title: String { rawValue.capitalized }
    
    var imageName: String {
        switch self {
        case .name:
            return "textformat"
        case .popularity:
            return "arrow.up.and.person.rectangle.portrait"
        case .engagement:
            return "person.crop.circle.badge.checkmark"
        }
    }
}

struct UserBrowserLayoutMenu: View {
    @Binding var layout: BrowserLayout
    @Binding var sort: UserSort
    
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
                Label(UserSort.name.title, systemImage: UserSort.name.imageName)
                    .tag(UserSort.name)
                Label(UserSort.popularity.title, systemImage: UserSort.popularity.imageName)
                    .tag(UserSort.popularity)
                Label(UserSort.engagement.title, systemImage: UserSort.engagement.imageName)
                    .tag(UserSort.engagement)
            }
            .pickerStyle(.inline)
        } label: {
            Label("Layout and Sorting Options", systemImage: layout.imageName)
                .labelStyle(.iconOnly)
        }
    }
}
