//
//  ReplyView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct ReplyView: View {
    @StateObject private var model: ReplyViewModel
    @Environment(\.dismiss) private var dismiss
    
    private var rowSpacing: CGFloat = 16
    
    init(postType: PostType) {
        _model = StateObject(wrappedValue: ReplyViewModel(postType: postType))
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Divider()
                VStack(alignment: .leading, spacing: rowSpacing) {
                    HStack(alignment: .top) {
                        VStack {
                            switch model.postType {
                            case .post(let post):
                                CircularProfileImageView(profileImageURL: post.user?.profileImageURL)
                            case .reply(let reply):
                                CircularProfileImageView(profileImageURL: reply.user?.profileImageURL)
                            }

                            Rectangle()
                                .fill(Color.secondary)
                                .frame(maxWidth: 2, minHeight: rowSpacing, maxHeight: .infinity)
                                .padding(.bottom, -rowSpacing / 2)
                        }
                        
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 4) {
                                switch model.postType {
                                case .post(let post):
                                    Text(post.user?.username ?? "")
                                        .fontWeight(.semibold)
                                    Text(post.caption)
                                        .multilineTextAlignment(.leading)
                                    
                                case .reply(let reply):
                                    Text(reply.user?.username ?? "")
                                        .fontWeight(.semibold)
                                    Text(reply.replyText)
                                        .multilineTextAlignment(.leading)
                                }
                            }
                            .font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    HStack(alignment: .top) {
                        CircularProfileImageView(profileImageURL: model.currentUser?.profileImageURL)
                        
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 4) {
                                switch model.postType {
                                case .post(let post):
                                    Text(model.currentUser?.username ?? "")
                                        .fontWeight(.semibold)
                                case .reply(let reply):
                                    Text(model.currentUser?.username ?? "")
                                        .fontWeight(.semibold)
                                }

                                TextField("Add your reply...", text: $model.replyText, axis: .vertical)
                                    .tint(Color.primary)
                                    .padding(2)
                                    .multilineTextAlignment(.leading)
#if DEBUG
                                    .autocorrectionDisabled()
#endif
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
                            try await model.uploadReply(with: model.replyText)
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

#Preview {
    VStack {
        ReplyView(postType: .post(Preview.post))
        ReplyView(postType: .reply(Preview.reply))
    }
}
