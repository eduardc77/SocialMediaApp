//
//  PostDetailsView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct PostDetailsView: View {
    @StateObject var model: PostDetailsViewModel

    init(post: Post) {
       _model = StateObject(wrappedValue: PostDetailsViewModel(post: post))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack(spacing: 10) {
                    CircularProfileImageView(profileImageURL: model.post.user?.profileImageURL, size: .small)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(model.post.user?.fullName ?? "")
                            .foregroundStyle(Color.primary)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        Text(model.post.user?.username ?? "")
                            .font(.caption)
                            .foregroundStyle(Color.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    
                    Text(model.post.timestamp.timestampString())
                        .font(.caption)
                        .foregroundStyle(Color.secondary)
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundStyle(Color.primary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text(model.post.caption)
                        .font(.subheadline)
                    
                    ContentButtonsView(model: ContentButtonsViewModel(contentType: .post(model.post)))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            
            Divider()
            
            ContentGrid(contentGridType: .replies(model.replies), pageCount: .constant(0), isLoading: .constant(false), itemsPerPage: 10, fetchNewPage: {
                
            })
        }
        .background(Color.groupedBackground)
        .navigationTitle("Post Details")
    }
}

struct PostDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailsView(post: preview.post)
    }
}