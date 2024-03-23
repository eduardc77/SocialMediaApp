//
//  ContentGridItem.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

enum ContentType {
    case post(Post)
    case reply(PostReply)
}

struct ContentGridItem: View {
    let contentType: ContentType
    var profileImageSize: ImageSize = .small
    
    @State private var userSelectedPostAction: UserPostActionSheetOptions?
    @State private var selectedPostAction: PostActionSheetOptions?
    
    private var user: User? {
        switch contentType {
            case .post(let post):
                return post.user
            case .reply(let postReply):
                return postReply.replyUser
        }
    }
    
    private var post: Post? {
        switch contentType {
            case .post(let post):
                return post
            case .reply(_):
                return nil
        }
    }
    
    private var caption: String {
        switch contentType {
            case .post(let post):
                return post.caption
            case .reply(let postReply):
                return postReply.replyText
        }
    }

    private var timestampString: String {
        switch contentType {
            case .post(let post):
                return post.timestamp.timestampString()
            case .reply(let postReply):
                return postReply.timestamp.timestampString()
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                profileView(user: user)
                Spacer()
                ellipsisView
            }
            Text(caption)
                .font(.callout)
                .lineLimit(10)
                .allowsHitTesting(false)
            
            if let imageURLString = post?.imageUrl, let postImageURL = URL(string: imageURLString) {
                AsyncImageView(url: postImageURL, size: .custom(height: 300))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .allowsHitTesting(false)
            }
            
            VStack(alignment: .trailing, spacing: 10) {
                if case .post(let post) = contentType {
                    categoryView(category: post.category)
                }
                VStack(spacing: 2) {
                    Divider()
                    ContentButtonsView(model: ContentButtonsViewModel(contentType: contentType))
                }
            }
        }
        .padding([.horizontal, .top], 10)
        .redacted(reason: user == nil ? .placeholder : [])
    }
}
    // MARK: - Subviews

private extension ContentGridItem {
    func profileView(user: User?) -> some View {
        NavigationLink(value: user) {
            HStack(alignment: .top) {
                CircularProfileImageView(profileImageURL: user?.profileImageURL, size: profileImageSize)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(user?.fullName ?? "")
                        .foregroundStyle(Color.primary)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    Text("@\(user?.username ?? "Placeholder Text") • \(timestampString)")
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
    
    func categoryView(category: PostCategory) -> some View {
        NavigationLink(value: category) {
            Label {
                Text(category.rawValue.capitalized)
                    .foregroundStyle(Color.secondary)
            } icon: {
                Text(category.icon)
            }
            .padding(6)
            .font(.caption)
            .background(in: RoundedRectangle(cornerRadius: 5, style: .continuous))
            .backgroundStyle(.regularMaterial)
        }
    }
    
    var ellipsisView: some View {
        Menu {
            switch contentType {
                case .post(let post):
                    if post.user?.isCurrentUser ?? false {
                        UserPostActionSheetView(post: post, onDeleteHandler: {
                            Task {
                                try await ContentButtonsViewModel.deletePost(post)
                            }
                        }, selectedAction: $userSelectedPostAction)
                    } else {
                        PostActionSheetView(post: post, onDeleteHandler: {
                            
                        }, selectedAction: $selectedPostAction)
                    }
                    
                case .reply:
                    EmptyView()
            }

        } label: {
            Label("Menu", systemImage: "ellipsis")
                .labelStyle(.iconOnly)
                .font(.headline)
                .foregroundStyle(Color.secondary)
                .padding(10)
                .contentShape(.rect)
        }
    }
}


struct FeedCell_Previews: PreviewProvider {
    static var previews: some View {
        ContentGridItem(contentType: .post(preview.post))
    }
}
