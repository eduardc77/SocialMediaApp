//
//  ForYouFeedViewModel.swift
//  SocialMedia
//

import Observation
import SocialMediaNetwork
import Firebase

@Observable final class ForYouFeedViewModel: FeedViewModel {
    var contentUnavailableText = "Be the first to add a post or check back later."
    
    func loadMorePosts() async {
        guard !noMoreItemsToFetch else {
            return
        }
        loading = true

        do {
            let (newPosts, lastPostDocument) = try await PostService.fetchForYouPosts(countLimit: itemsPerPage, descending: true, lastDocument: lastPostDocument)
            
            guard !newPosts.isEmpty else {
                self.noMoreItemsToFetch = true
                self.loading = false
                self.lastPostDocument = nil
                return
            }
            
            try await withThrowingTaskGroup(of: Post.self) { [weak self] group in
                guard let self = self else {
                    self?.loading = false
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
                
                self.loading = false
            }
        } catch {
            print("Error fetching for you posts: \(error)")
        }
    }
    
    func refresh() async {
        reset()
        await loadMorePosts()
    }
}
