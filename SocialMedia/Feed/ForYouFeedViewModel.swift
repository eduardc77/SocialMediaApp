//
//  ForYouFeedViewModel.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork
import Firebase

final class ForYouFeedViewModel: FeedViewModel {
    var contentUnavailableText = "Be the first to add a post or check back later."
    
    func loadMorePosts() async throws {
        guard !noMoreItemsToFetch else {
            return
        }
        isLoading = true
        
        let (newPosts, lastPostDocument) = try await PostService.fetchForYouPosts(countLimit: itemsPerPage, descending: true, lastDocument: lastPostDocument)
        
        guard !newPosts.isEmpty else {
            self.noMoreItemsToFetch = true
            self.isLoading = false
            self.lastPostDocument = nil
            return
        }
        
        do {
            try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
                guard let self = self else {
                    self?.isLoading = false
                    return
                }
                var userDataPosts = [Post]()
                
                for post in newPosts {
                    group.addTask { try await self.fetchPostUserData(post: post) }
                }
                for try await post in group {
                    userDataPosts.append(post)
                }
                
                if let lastPostDocument {
                    self.lastPostDocument = lastPostDocument
                    self.noMoreItemsToFetch = false
                } else {
                    self.noMoreItemsToFetch = true
                    self.lastPostDocument = nil
                }
                self.posts.append(contentsOf: userDataPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
                
                self.isLoading = false
            }
        } catch {
            print("Error fetching for you posts: \(error)")
        }
    }
    
    func refresh() async throws {
        reset()
        try await loadMorePosts()
    }
}
