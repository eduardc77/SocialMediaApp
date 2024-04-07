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
        return 50
#endif
    }
    
    var body: some View {
        Group {
            if model.isLoading { 
                ProgressView()
                
            } else if model.filteredUsers.isEmpty {
                
                ContentUnavailableView(
                    model.contentUnavailableTitle,
                    systemImage: "magnifyingglass",
                    description: Text(model.contentUnavailableText)
                )
            } else {
                Group {
                    switch layout {
                    case .grid:
                        grid
                    case .list:
                        table
                    }
                }
            }
        }
        .background(Color.groupedBackground)
        .navigationTitle(AppScreen.search.title)
        .toolbar {
            ToolbarItemGroup {
                toolbarItems
            }
        }
        .task {
            do {
                try await model.fetchUsers()
            } catch {
                print("DEBUG: Failed to fetch users in Search View.")
            }
        }
        .searchable(text: $model.searchText)
        .searchSuggestions {
            if model.searchText.isEmpty {
                searchSuggestions
            }
        }
        .refreshable {
            Task {
                try await model.refresh()
            }
        }
    }
    
    var grid: some View {
        GeometryReader { geometryProxy in
            ScrollView {
                SearchGrid(router: router, users: model.filteredUsers, width: geometryProxy.size.width, followedIndex: model.followedIndex, isLoading: model.isLoading)
            }
        }
    }
    
    var table: some View {
        Table(model.filteredUsers, selection: $selection) {
            TableColumn("Name") { user in
                NavigationButton {
                    router.push(user)
                } label: {
                    SearchRow(user: user, thumbnailSize: tableImageSize)
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
        ForEach(model.mostPopularUsers.prefix(10)) { user in
            Text("**\(user.fullName)**")
                .searchCompletion(user.fullName)
        }
    }
}

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
