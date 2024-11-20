//
//  PostDetailsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

@MainActor
struct PostDetailsView: View {
    private var router: Router
    @State private var model: PostDetailsViewModel
    
    @Environment(ModalScreenRouter.self) private var modalRouter
    
    init(router: Router, postType: PostType) {
        self.router = router
        model = PostDetailsViewModel(postType: postType)
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
                        
                        Text("@\(model.user?.username ?? "")")
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
                    Text(model.post?.caption ?? model.reply?.caption ?? "")
                        .font(.subheadline)
                    
                    switch model.postType {
                    case .post:
                        if let post = model.post {
                            if let imageURLString = post.imageUrl, let postImageURL = URL(string: imageURLString) {
                                
                                AsyncImageView(url: postImageURL, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .allowsHitTesting(false)
                            }
                            
                            PostButtonGroupView(postType: .post(post), onReplyTapped: { postType in
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
                            
                            PostButtonGroupView(postType: .reply(reply), onReplyTapped: { postType in
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
                     loading: $model.loading,
                     endReached: model.noMoreItemsToFetch,
                     itemsPerPage: model.itemsPerPage,
                     contentUnavailableText: model.contentUnavailableText,
                     loadNewPage: model.loadMoreReplies)
        }
        .background(Color.groupedBackground)
        .navigationTitle("Post Details")
#if !os(macOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .task {
            await model.loadMoreReplies()
            if model.post != nil {
                model.addListenerForReplyUpdates()
            } else if let reply = model.reply {
                model.addListenerForReplyUpdates(depthLevel: reply.depthLevel + 1)
            }
        }
        .refreshable {
            await model.refresh()
        }
    }
}

#Preview {
    PostDetailsView(router: ViewRouter(), postType: PostType.post(Preview.post))
        .environment(ModalScreenRouter())
}
