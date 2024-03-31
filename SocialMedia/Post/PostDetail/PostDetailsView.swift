//
//  PostDetailsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct PostDetailsView: View {
    @StateObject var model: PostDetailsViewModel
    
    init(postType: PostType) {
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
                            
                            PostButtonGroupView(model: PostButtonGroupViewModel(postType: .post(post)))
                        }
                    case .reply:
                        if let reply = model.reply {
                            if let imageURLString = model.reply?.imageUrl, let postImageURL = URL(string: imageURLString) {
                                AsyncImageView(url: postImageURL, contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .allowsHitTesting(false)
                            }
                            
                            PostButtonGroupView(model: PostButtonGroupViewModel(postType: .reply(reply)))
                        }
                    }
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            
            Divider()
            
            ForEach(Array(model.replies.enumerated()), id: \.element) { index, reply in
                ZStack {
                    NavigationLink(value: PostType.reply(reply)) {
                        Color.secondaryGroupedBackground.clipShape(.containerRelative)
                    }
                    .buttonStyle(.plain)
                    
                    PostGridItem(postType: .reply(reply), profileImageSize: .small)
                }
                .contentShape(.containerRelative)
                .containerShape(.rect(cornerRadius: 8))
            }
        }
        .background(Color.groupedBackground)
        .navigationTitle("Post Details")
        
        .onFirstAppear {
            Task {
                try await model.loadMoreReplies()
            }
        }
        
    }
}

struct PostDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailsView(postType: PostType.post(preview.post))
        PostDetailsView(postType: PostType.reply(preview.reply))
    }
}
