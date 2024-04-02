//
//  ReplyRow.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct ReplyRow: View {
    let reply: Reply
    @State private var showReplySheet = false

    var body: some View {
        if let post = reply.post {
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack {
                        CircularProfileImageView(profileImageURL: reply.post?.user?.profileImageURL)
                        
                        Rectangle()
                            .fill(Color.secondary)
                            .frame(maxWidth: 2, maxHeight: .infinity)
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
                        
                        PostButtonGroupView(model: PostButtonGroupViewModel(postType: .post(post)))
                            .frame(height: 20)
                        
                        Spacer()
                    }
                }
                HStack(alignment: .top) {
                    CircularProfileImageView(profileImageURL: reply.user?.profileImageURL)
                    
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(reply.user?.username ?? "")
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            Text(reply.replyText)
                                .lineLimit(10)
                        }
                        PostButtonGroupView(model: PostButtonGroupViewModel(postType: .reply(reply)))
                            .frame(height: 20)
                        
                        Spacer()
                    }
                    .font(.footnote)
                }
                
                Divider()
            }

        }
    }
}

struct ReplyRow_Previews: PreviewProvider {
    static var previews: some View {
        ReplyRow(reply: preview.reply)
    }
}
