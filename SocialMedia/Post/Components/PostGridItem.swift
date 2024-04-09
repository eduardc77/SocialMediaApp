//
//  PostGridItem.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

enum PostType: Hashable {
    case post(Post)
    case reply(Reply)
}

struct PostGridItem: View {
    var router: any Router
    let postType: PostType
    var profileImageSize: ImageSize = .small
    
    var onReplyTapped: (PostType) -> Void
    
    @State private var userSelectedPostAction: UserPostActionSheetOptions?
    @State private var selectedPostAction: PostActionSheetOptions?
    
    private var user: User? {
        switch postType {
        case .post(let post):
            return post.user
        case .reply(let reply):
            return reply.user
        }
    }
    
    private var post: Post? {
        switch postType {
        case .post(let post):
            return post
        case .reply(_):
            return nil
        }
    }
    
    private var caption: String {
        switch postType {
        case .post(let post):
            return post.caption
        case .reply(let reply):
            return reply.replyText
        }
    }
    
    private var timestampString: String {
        switch postType {
        case .post(let post):
            return post.timestamp.timestampString()
        case .reply(let reply):
            return reply.timestamp.timestampString()
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
                AsyncImageView(url: postImageURL, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .allowsHitTesting(false)
            }
            
            VStack(alignment: .trailing, spacing: 10) {
                if case .post(let post) = postType {
                    categoryView(category: post.category)
                }
                VStack(spacing: 2) {
                    Divider()
                    PostButtonGroupView(model: PostButtonGroupViewModel(postType: postType), onReplyTapped: onReplyTapped)
                }
            }
        }
#if !os(macOS)
        .padding([.horizontal, .top], 10)
#else
        .padding([.horizontal, .top])
#endif
        .redacted(reason: user == nil ? .placeholder : [])
    }
}
// MARK: - Subviews

private extension PostGridItem {
    func profileView(user: User?) -> some View {
        NavigationButton {
            router.push(user)
        } label: {
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
        NavigationButton {
            router.push(category)
        } label: {
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
            switch postType {
            case .post(let post):
                if post.user?.isCurrentUser ?? false {
                    UserPostActionSheetView(post: post, onDeleteHandler: {
                        Task {
                            try await PostButtonGroupViewModel.deletePost(post)
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
#if os(macOS)
        .frame(maxWidth: 30)
        .menuIndicator(.hidden)
        .menuStyle(.borderlessButton)
#endif
    }
}


#Preview {
    PostGridItem(router: FeedViewRouter(), postType: .post(Preview.post), onReplyTapped: {_ in })
}
