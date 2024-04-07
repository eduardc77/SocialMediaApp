//
//  FollowingFeedViewModel.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork
import Firebase

final class FollowingFeedViewModel: FeedViewModel {
    
    var contentUnavailableText = "Follow more accounts to see posts."
    
    func loadMorePosts() async throws {
        guard !noMoreItemsToFetch else { return }
        isLoading = true
        
        let (newPostIDs, lastDocument) = try await PostService.fetchUserFollowingPosts(countLimit: itemsPerPage, descending: true, lastDocument: lastPostDocument)
        
        guard !newPostIDs.isEmpty else {
            self.noMoreItemsToFetch = true
            self.isLoading = false
            self.lastPostDocument = nil
            return
        }
        
        do {
            try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
                guard let self = self else { return }
                var followingPosts = [Post]()
                
                guard !newPostIDs.isEmpty else {
                    self.noMoreItemsToFetch = true
                    self.isLoading = false
                    return
                }
                for postID in newPostIDs {
                    group.addTask { try await PostService.fetchPost(postID: postID) }
                }
                for try await post in group {
                    followingPosts.append(try await fetchPostUserData(post: post))
                }
                if let lastDocument {
                    self.lastPostDocument = lastDocument
                    self.noMoreItemsToFetch = false
                } else {
                    self.noMoreItemsToFetch = true
                }
                
                self.posts.append(contentsOf: followingPosts.sorted(by: { $0.timestamp.dateValue() > $1.timestamp.dateValue() }))
                self.isLoading = false
            }
        } catch {
            print("Error fetching following posts: \(error)")
        }
    }
    
    func refresh() async throws {
        reset()
        try await loadMorePosts()
    }
}
