//
//  UserRelationsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

struct UserRelationsView: View {
    var router: any Router
    @ObservedObject var model: UserRelationsViewModel
    
    @Binding var selection: Set<User.ID>
    @Binding var layout: BrowserLayout

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
}

#Preview {
    struct Example: View {
        @State private var selection = Set<User.ID>()
        @State private var layout = BrowserLayout.grid
        
        var body: some View {
            UserRelationsView(router: ProfileViewRouter(), model: UserRelationsViewModel(user: Preview.user), selection: $selection, layout: $layout)
        }
    }
    return Example()
}
