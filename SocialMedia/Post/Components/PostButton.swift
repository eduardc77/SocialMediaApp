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
                    .labelStyle(.iconOnly)
                    .symbolVariant(isActive ? .fill : .none)
                    
                if count > 0, buttonType != .save {
                    Text("\(count)")
                        .fontWeight(.medium)
                        .contentTransition(.numericText())
                }
            }
            .font(.footnote)
            .padding(.top, 6)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .foregroundStyle(!isActive ? Color.secondary : buttonType.color)
        }
        .buttonStyle(.borderless)
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
