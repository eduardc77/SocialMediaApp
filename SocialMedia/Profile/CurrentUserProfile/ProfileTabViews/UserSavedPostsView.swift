//
//  UserSavedPostsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserSavedPostsView: View {
    @StateObject var model: UserSavedPostsViewModel
    
    init(user: User) {
        self._model = StateObject(wrappedValue: UserSavedPostsViewModel(user: user))
    }
    
    var body: some View {
        PostGrid(postGridType: .posts(model.posts), isLoading: $model.isLoading, itemsPerPage: model.itemsPerPage, fetchNewPage: {
            try await model.loadMorePosts()
        })
        .onFirstAppear {
            Task { try await model.loadMorePosts() }
        }
    }
}
