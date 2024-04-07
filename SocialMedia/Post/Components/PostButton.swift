//
//  PostButton.swift
//  SocialMedia
//

import SwiftUI

struct PostButton: View {
    var count: Int
    var isActive: Bool
    let buttonType: PostButtonType
    
    var action: () -> Void
    
    @State private var tapped: Bool = false
    @State private var countsDown: Bool = false
    
    var body: some View {
        Button {
            tapped.toggle()
            action()
        } label: {
            HStack {
                Label(buttonType.title, systemImage: buttonType.icon)
                    .labelStyle(.iconOnly)
                    .symbolVariant(isActive ? .fill : .none)
                if count > 0, buttonType != .save {
                    Text("\(count)") 
                        .contentTransition(.numericText(countsDown: countsDown))
                        .animation(.default, value: count)
                }
            }
            .font(.footnote)
            .fontWeight(.medium)
            .padding(.top, 6)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .foregroundStyle(!isActive ? Color.secondary : buttonType.color)
        }
        .buttonStyle(.borderless)
#if os(iOS)
        .hapticFeedback(trigger: tapped)
#endif
        
        .onChange(of: count) { oldValue, newValue in
            guard oldValue != newValue else { return }
            countsDown = newValue < oldValue
        }
    }
}

#Preview {
    PostButton(count: 2,
               isActive: false,
               buttonType: .like,
               action: {})
}
