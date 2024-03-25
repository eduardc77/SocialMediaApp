//
//  PostButton.swift
//  SocialMedia
//

import SwiftUI

struct PostButton: View {
    var count: Int
    let buttonType: PostButtonType
    var isActive: Bool = false
    
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                Label(buttonType.title, systemImage: buttonType.icon)
                    .symbolVariant(isActive ? .fill : .none)
                    .labelStyle(.iconOnly)
                if count > 0, buttonType != .save {
                    Text("\(count)")
                        .fontWeight(.medium)
                        .contentTransition(.numericText(countsDown: isActive ? false : true))
                        .animation(.default, value: count)
                }
            }
            .font(.footnote)
            .padding(.top, 6)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .foregroundStyle(!isActive ? Color.secondary : buttonType.color)
        }
        .buttonStyle(.plain)
#if os(iOS)
        .hapticFeedback(trigger: count)
#endif
    }
}

#Preview {
    PostButton(count: 2,
               buttonType: .like,
               isActive: true,
               action: {})
}

enum PostButtonType: CaseIterable {
    case like
    case reply
    case repost
    case save
}

extension PostButtonType {
    
    var title: String {
        switch self {
            case .like:
                return "Like"
            case .reply:
                return "Reply"
            case .repost:
                return "Repost"
            case .save:
                return "Save"
        }
    }
    
    var icon: String {
        switch self {
            case .like:
                return "heart"
            case .reply:
                return "message"
            case .repost:
                return "arrow.2.squarepath"
            case .save:
                return "bookmark"
        }
    }
    
    var iconFilled: String {
        icon + ".fill"
    }
}

extension PostButtonType {
    var color: Color {
        switch self {
            case .like:
                return .red
            case .reply:
                return .blue
            case .repost:
                return .green
            case .save:
                return .orange
        }
    }
}
