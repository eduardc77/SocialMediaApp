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
    
    @EnvironmentObject private var router: SearchViewRouter
    
    var tableImageSize: Double {
#if os(macOS)
        return 30
#else
        return 60
#endif
    }
    
    var body: some View {
        Group {
            switch layout {
            case .grid:
                grid
            case .list:
                table
            }
        }
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
    }
    
    var grid: some View {
        GeometryReader { geometryProxy in
            ScrollView {
                SearchGrid(router: router, users: model.filteredUsers, width: geometryProxy.size.width, followedIndex: model.followedIndex, isLoading: model.isLoading) { user in
                    Task {
                        try await model.toggleFollow(for: user)
                    }
                }
            }
        }
    }
    
    var table: some View {
        Table(model.filteredUsers, selection: $selection) {
            TableColumn("Name") { user in
                NavigationLink {
                    SearchRow(model: SearchViewModel(), user: user, thumbnailSize: tableImageSize)
                } action: {
                    router.push(user)
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
