//
//  UserPostsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserPostsView: View {
    @StateObject var model: UserPostsViewModel
    
    init(user: User) {
        self._model = StateObject(wrappedValue: UserPostsViewModel(user: user))
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
