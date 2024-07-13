//
//  UserRelationsTabsContainer.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

@MainActor
struct UserRelationsTabsContainer: View {
    private var router: Router
    @State private var model: UserRelationsViewModel
    @State private var selection = Set<User.ID>()
    @State private var layout = BrowserLayout.grid
    
    @Environment(\.dismiss) private var dismiss
    
    init(router: Router, user: User) {
        self.router = router
        model = UserRelationsViewModel(user: user)
    }
    
    var body: some View {
        VStack {
            TopFilterBar(currentFilter: $model.filterSelection)
            relationsTabView
        }
#if os(macOS)
        .frame(minWidth: 440, maxWidth: .infinity, minHeight: 220, maxHeight: .infinity)
#endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
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
        .refreshable {
            await model.loadUserRelations()
        }
    }
}

// MARK: - Subviews

private extension UserRelationsTabsContainer {
    
    var relationsTabView: some View {
        TabView(selection: $model.filterSelection) {
            UserRelationsView(router: router, model: model, selection: $selection, layout: $layout)
                .tag(UserRelationType.followers)
            UserRelationsView(router: router, model: model, selection: $selection, layout: $layout)
                .tag(UserRelationType.following)
        }
#if os(iOS)
        .tabViewStyle(.page(indexDisplayMode: .never))
#endif
    }
    
    var searchSuggestions: some View {
        ForEach(model.mostPopularUsers.prefix(10)) { user in
            Text("**\(user.fullName)**")
                .searchCompletion(user.fullName)
        }
    }
}

#Preview {
    NavigationView {
        PostCategoryDetailView(router: ViewRouter(), category: .affirmations)
            .environment(ModalScreenRouter())
    }
}
