//
//  SearchView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

@MainActor
struct SearchView: View {
    @State private var model = SearchViewModel()
    @State private var selection = Set<User.ID>()
    @State private var layout = BrowserLayout.grid
    
    @Environment(ViewRouter.self) private var router
    
    var tableImageSize: Double {
#if os(macOS)
        return 30
#else
        return 50
#endif
    }
    
    var body: some View {
        Group {
            if model.loading {
                ProgressView()
                
            } else if model.filteredUsers.isEmpty, !model.searchText.isEmpty {
                ContentUnavailableView(
                    model.contentUnavailableTitle,
                    systemImage: "magnifyingglass",
                    description: Text(model.contentUnavailableText)
                )
            } else if model.filteredUsers.isEmpty, model.searchText.isEmpty {
                ContentUnavailableView(
                    "No Content",
                    systemImage: "person.fill.questionmark.rtl",
                    description: Text("There are currently no other users in the app. Invite your friends or check back later.")
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
        .navigationTitle(AppScreen.search.title)
        .toolbar {
            ToolbarItemGroup {
                UserBrowserLayoutMenu(layout: $layout, sort: $model.sort)
            }
        }
        .task {
            await model.fetchUsers()
        }
        .searchable(text: $model.searchText)
        .searchSuggestions {
            if model.searchText.isEmpty {
                searchSuggestions
            }
        }
        .refreshable {
            await model.refresh()
        }
    }
    
    var grid: some View {
        GeometryReader { geometryProxy in
            ScrollView {
                SearchGrid(router: router, users: model.filteredUsers, width: geometryProxy.size.width)
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

    var searchSuggestions: some View {
        ForEach(model.mostPopularUsers.prefix(10)) { user in
            Text("**\(user.fullName)**")
                .searchCompletion(user.fullName)
        }
    }
}
