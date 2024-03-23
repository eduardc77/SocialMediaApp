//
//  ActivityRowView.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaNetwork

struct ActivityRowView: View {
    let model: Activity
    
    private var activityMessage: String {
        switch model.type {
        case .like:
            return model.post?.caption ?? ""
        case .follow:
            return "Followed you"
        case .reply:
            return "Replied to one of your posts"
        }
    }
    
    private var isFollowed: Bool {
        return model.user?.isFollowed ?? false
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 16) {
                NavigationLink(value: model.user) {
                    ZStack(alignment: .bottomTrailing) {
                        CircularProfileImageView(profileImageURL: model.user?.profileImageURL, size: .medium)
                        ActivityBadgeView(type: model.type)
                            .offset(x: 8, y: 4)
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(model.user?.username ?? "")
                            .bold()
                            .foregroundStyle(Color.primary)
                        
                        Text(model.timestamp.timestampString())
                            .foregroundStyle(Color.secondary)
                    }
                    
                    Text(activityMessage)
                        .foregroundStyle(Color.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .font(.footnote)
                
                Spacer()
                
                if model.type == .follow {
                    Button {
                        
                    } label: {
                        Text(isFollowed ? "Following" : "Follow")
                            .foregroundStyle(isFollowed ? Color.secondary : Color.primary)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .frame(width: 100, height: 32)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.secondary, lineWidth: 1)
                            }
                    }
                }

            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
                .padding(.leading, 80)
        }
    }
}

struct ActivityRowView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityRowView(model: preview.activityModel)
    }
}
