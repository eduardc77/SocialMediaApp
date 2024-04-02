//
//  SearchView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct SearchView: View {
    @StateObject private var model = SearchViewModel()
    @State private var selection = Set<User.ID>()
    @State private var layout = BrowserLayout.grid
    
    var tableImageSize: Double {
#if os(macOS)
        return 30
#else
        return 60
#endif
    }
    
    var body: some View {
        NavigationStack {
            Group {
                switch layout {
                case .grid:
                    grid
                case .list:
                    table
                }
            }
#if os(iOS)
            .toolbarRole(.browser)
#endif
            .toolbar {
                ToolbarItemGroup {
                    toolbarItems
                }
            }
            .background(Color.groupedBackground)
            .navigationTitle(AppScreen.search.title)
            .searchable(text: $model.searchText)
            .searchSuggestions {
                if model.searchText.isEmpty {
                    searchSuggestions
                }
            }
            .navigationDestination(for: User.self, destination: { user in
                ProfileView(user: user)
            })
        }
    }
    
    var grid: some View {
        GeometryReader { geometryProxy in
            ScrollView {
                SearchGrid(users: model.filteredUsers, width: geometryProxy.size.width)
            }
        }
    }
    
    var table: some View {
        Table(model.filteredUsers, selection: $selection) {
            TableColumn("Name") { user in
                NavigationLink(value: user) {
                    SearchRow(model: SearchViewModel(), user: user, thumbnailSize: tableImageSize)
                }
            }
        }
    }
    
    @ViewBuilder
    var toolbarItems: some View {
        Menu {
            Picker("Layout", selection: $layout) {
                ForEach(BrowserLayout.allCases) { option in
                    Label(option.title, systemImage: option.imageName)
                        .tag(option)
                }
            }
            .pickerStyle(.inline)
            
            Picker("Sort", selection: $model.sort) {
                Label("Name", systemImage: "textformat")
                    .tag(UserSortOrder.name)
                Label("Popularity", systemImage: "trophy")
                    .tag(UserSortOrder.popularity)
                Label("Engagement", systemImage: "fork.knife")
                    .tag(UserSortOrder.engagement)
            }
            .pickerStyle(.inline)
            
        } label: {
            Label("Layout Options", systemImage: layout.imageName)
                .labelStyle(.iconOnly)
        }
    }
    
    var searchSuggestions: some View {
        ForEach(model.mostPopularUsers.prefix(10), id: \.self) { user in
            Text("**\(user.fullName)**")
                .searchCompletion(user.fullName)
        }
        
    }
}

enum BrowserLayout: String, Identifiable, CaseIterable {
    case grid
    case list
    
    var id: String {
        rawValue
    }
    
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
