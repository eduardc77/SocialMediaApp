//
//  ReplyGridItem.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork
import SocialMediaUI

struct ReplyGridItem: View {
    let router: any Router
    let reply: Reply
    let hasConnectionLine: Bool = true
    let onReplyTapped: (PostType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let post = reply.post, let user = reply.post?.user {
                HStack(alignment: .top) {
                    NavigationButton {
                        router.push(user)
                    } label: {
                        VStack {
                            CircularProfileImageView(profileImageURL: reply.post?.user?.profileImageURL)
                            
                            if hasConnectionLine {
                                Rectangle()
                                    .fill(Color.secondary)
                                    .frame(maxWidth: 2, maxHeight: .infinity)
                                    .padding(.bottom, -10)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(post.user?.username ?? "")
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            
                            Text(post.caption)
                                .lineLimit(10)
                        }
                        .font(.footnote)
                        
                        PostButtonGroupView(model: PostButtonGroupViewModel(postType: .post(post)), onReplyTapped: onReplyTapped)
                        
                        Divider()
                    }
                }
            }
            
            
            
            if let user = reply.user {
                HStack(alignment: .top) {
                    NavigationButton {
                        router.push(user)
                    } label: {
                        CircularProfileImageView(profileImageURL: reply.user?.profileImageURL)
                    }
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(reply.user?.username ?? "")
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Text(reply.caption)
                                .lineLimit(10)
                        }
                        PostButtonGroupView(model: PostButtonGroupViewModel(postType: .reply(reply)), onReplyTapped: onReplyTapped)
                        
                    }
                    .font(.footnote)
                    
                }
            }
        }
        .padding(.top, 10)
        .padding(.leading, 10)
    }
}

#Preview {
    ReplyGridItem(router: ProfileViewRouter(), reply: Preview.reply, onReplyTapped: {_ in })
}
