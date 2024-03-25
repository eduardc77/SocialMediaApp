//
//  PostReplyView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct PostReplyView: View {
    @StateObject private var model: PostReplyViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var rowSpacing: CGFloat = 16
    
    init(post: Post) {
        _model = StateObject(wrappedValue: PostReplyViewModel(post: post))
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Divider()
                VStack(alignment: .leading, spacing: rowSpacing) {
                    HStack(alignment: .top) {
                        VStack {
                            CircularProfileImageView(profileImageURL: model.post.user?.profileImageURL, size: .small)
                            
                            Rectangle()
                                .fill(Color.secondary)
                                .frame(maxWidth: 2, minHeight: rowSpacing, maxHeight: .infinity)
                                .padding(.bottom, -rowSpacing / 2)
                        }
                        
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(model.post.user?.username ?? "")
                                    .fontWeight(.semibold)
                                
                                Text(model.post.caption)
                                    .multilineTextAlignment(.leading)
                            }
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        CircularProfileImageView(profileImageURL: model.currentUser?.profileImageURL, size: .small)
                        
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(model.post.user?.username ?? "")
                                    .fontWeight(.semibold)
                                
                                TextField("Add your reply...", text: $model.replyText, axis: .vertical)
                                    .autocorrectionDisabled()
                                    .tint(.primary)
                                    .padding(2)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        .font(.footnote)
                    }
                }
                .padding()
                
                Spacer().layoutPriority(1)
            }
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#else
            .frame(minWidth: 440, maxWidth: .infinity, minHeight: 220, maxHeight: .infinity)
#endif
            .navigationTitle("Reply")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .foregroundStyle(Color.primary)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        Task {
                            try await model.uploadPostReply(toPost: model.post, replyText: model.replyText)
                            dismiss()
                        }
                    }
                    .opacity(model.replyText.isEmpty ? 0.5 : 1.0)
                    .disabled(model.replyText.isEmpty)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.primary)
                }
            }
        }
    }
}

struct PostReplyView_Previews: PreviewProvider {
    static var previews: some View {
        PostReplyView(post: preview.post)
    }
}
