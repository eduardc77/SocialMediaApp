//
//  UserRelationsTabsContainer.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

struct UserRelationsTabsContainer: View {
    var router: any Router
    @StateObject private var model: UserRelationsViewModel
    @State private var selection = Set<User.ID>()
    @State private var layout = BrowserLayout.grid

    @Environment(\.dismiss) private var dismiss

    init(router: any Router, user: User) {
        self.router = router
        self._model = StateObject(wrappedValue: UserRelationsViewModel(user: user))
    }
    
    var body: some View {
        VStack {
            TopFilterBar(currentFilter: $model.filterSelection)
            relationsTabView
        }
#if os(macOS)
        .frame(minWidth: 440, maxWidth: .infinity, minHeight: 220, maxHeight: .infinity)
#endif
        .background(Color.groupedBackground)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
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
        }
        .task {
            do {
                try await model.loadUserRelations()
            } catch {
                print("DEBUG: Failed to fetch user relations.")
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
                try await model.loadUserRelations()
            }
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
        PostCategoryDetailView(router: FeedViewRouter(), category: .affirmations)
    }
}
