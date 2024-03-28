//
//  UserLikedPostsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct UserLikedPostsView: View {
    @StateObject var model: UserLikedPostsViewModel
    
    init(user: User) {
        self._model = StateObject(wrappedValue: UserLikedPostsViewModel(user: user))
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
