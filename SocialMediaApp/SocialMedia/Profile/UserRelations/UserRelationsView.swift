//
//  UserRelationsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

@MainActor
struct UserRelationsView: View {
    var router: Router
    @State private var model: UserRelationsViewModel
    
    @State private var selection = Set<User.ID>()
    @State private var layout = BrowserLayout.grid
    
    var tableImageSize: Double {
#if os(macOS)
        return 30
#else
        return 50
#endif
    }
    
    init(router: Router, user: User) {
        self.router = router
        model = UserRelationsViewModel(user: user)
    }
    
    var body: some View {
        Group {
            if model.loading {
                ProgressView()
                
            } else if model.sortedAndFilteredUsers.isEmpty, !model.searchText.isEmpty {
                ContentUnavailableView(
                    model.contentUnavailableTitle,
                    systemImage: "magnifyingglass",
                    description: Text(model.contentUnavailableText)
                )
            } else if model.sortedAndFilteredUsers.isEmpty, model.searchText.isEmpty {
                ContentUnavailableView(
                    "No Content",
                    systemImage: "person.fill.questionmark.rtl",
                    description: Text(model.filterSelection == .followers ? "You have no followers yet." : "You aren't following anyone yet.")
                )
            } else {
                switch layout {
                case .grid:
                    grid
                case .list:
                    table
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
#if os(macOS)
        .frame(minWidth: 440, maxWidth: .infinity, minHeight: 220, maxHeight: .infinity, alignment: .top)
#endif
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                UserBrowserLayoutMenu(layout: $layout, sort: $model.sort)
            }
        }
        .task {
            await model.loadUserRelations()
        }
        .searchable(text: $model.searchText)
        .searchSuggestions {
            if model.searchText.isEmpty {
                searchSuggestions
            }
        }
        .safeAreaInset(edge: .top, content: {
            TopFilterBar(currentFilter: $model.filterSelection)
                .background(.bar)
        })
        .refreshable {
            await model.loadUserRelations()
        }
    }
}

private extension UserRelationsView {
    
    var grid: some View {
        GeometryReader { geometryProxy in
            ScrollView {
                SearchGrid(router: router, users: model.sortedAndFilteredUsers, width: geometryProxy.size.width)
            }
        }
    }
    
    var table: some View {
        Table(model.sortedAndFilteredUsers, selection: $selection) {
            TableColumn("Name") { user in
                NavigationButton {
                    router.push(UserDestination.profile(user: user))
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

#Preview {
    UserRelationsView(router: ViewRouter(), user: Preview.user)
}
