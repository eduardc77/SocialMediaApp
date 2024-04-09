//
//  PostDetailsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

struct PostDetailsView: View {
    var router: any Router
    @StateObject var model: PostDetailsViewModel
    
    @EnvironmentObject private var modalRouter: ModalScreenRouter
    
    init(router: any Router, postType: PostType) {
        self.router = router
        _model = StateObject(wrappedValue: PostDetailsViewModel(postType: postType))
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    CircularProfileImageView(profileImageURL: model.user?.profileImageURL)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(model.user?.fullName ?? "")
                            .foregroundStyle(Color.primary)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        Text(model.user?.username ?? "")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    
                    Text(model.post?.timestamp.timestampString() ?? model.reply?.timestamp.timestampString() ?? "")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color.primary)
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(model.post?.caption ?? model.reply?.replyText ?? "")
                        .font(.subheadline)
                    
                    switch model.postType {
                    case .post:
                        if let post = model.post {
                            if let imageURLString = post.imageUrl, let postImageURL = URL(string: imageURLString) {
                                AsyncImageView(url: postImageURL, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .allowsHitTesting(false)
                            }
                            
                            PostButtonGroupView(model: PostButtonGroupViewModel(postType: .post(post)), onReplyTapped: { postType in
                                modalRouter.presentSheet(destination: PostSheetDestination.reply(postType: postType))
                            })
                        }
                    case .reply:
                        if let reply = model.reply {
                            if let imageURLString = model.reply?.imageUrl, let postImageURL = URL(string: imageURLString) {
                                AsyncImageView(url: postImageURL, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .allowsHitTesting(false)
                            }
                            
                            PostButtonGroupView(model: PostButtonGroupViewModel(postType: .reply(reply)), onReplyTapped: { postType in
                                modalRouter.presentSheet(destination: PostSheetDestination.reply(postType: postType))
                            })
                        }
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            
            Divider()
            
            PostGrid(router: router, postGridType: .replies(model.replies),
                     isLoading: $model.isLoading,
                     itemsPerPage: model.itemsPerPage,
                     contentUnavailableText: model.contentUnavailableText,
                     loadNewPage: model.loadMoreReplies)
        }
        .background(Color.groupedBackground)
        .navigationTitle("Post Details")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .onAppear {
            Task {
                try await model.loadMoreReplies()
                if model.post != nil {
                    model.addListenerForReplyUpdates()
                } else if let reply = model.reply {
                    model.addListenerForReplyUpdates(depthLevel: reply.depthLevel + 1)
                }
            }
        }
        .refreshable {
            Task {
                try await model.refresh()
            }
        }
    }
}

#Preview {
    PostDetailsView(router: FeedViewRouter(), postType: PostType.post(Preview.post))
}
