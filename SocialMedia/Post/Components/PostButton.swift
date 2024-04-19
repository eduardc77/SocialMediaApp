//
//  PostButton.swift
//  SocialMedia
//

import SwiftUI

struct PostButton: View {
    var count: Int
    var active: Bool
    let buttonType: PostButtonType
    var action: () -> Void
    
    @State private var tapped: Bool = false
    @State private var countsDown: Bool = false
    @State private var tempCount: Int = 0
    
    var body: some View {
        Button {
            tapped.toggle()
            action()
        } label: {
            HStack {
                Label(buttonType.title, systemImage: buttonType.icon)
                    .labelStyle(.iconOnly)
                    .symbolVariant(active ? .fill : .none)
                    .contentTransition(tapped ? .symbolEffect(active ? .replace.upUp : .replace.downUp) : .identity)
                
                if tempCount > 0, buttonType != .save {
                    Text("\(tempCount)")
                        .contentTransition(.numericText(countsDown: countsDown))
                }
            }
            .font(.footnote)
            .fontWeight(.medium)
            .padding(.top, 6)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity)
            .foregroundStyle(!active ? Color.secondary : buttonType.color)
        }
        .buttonStyle(.borderless)
#if os(iOS)
        .hapticFeedback(trigger: tapped)
#endif
        .onChange(of: count) { oldValue, newValue in
            guard oldValue != newValue else { return }
            countsDown = newValue < oldValue
            guard tempCount != newValue else { return }
            withAnimation {
                tempCount = newValue
            }
            
        }
        .onFirstAppear {
            guard tempCount != count else { return }
            withAnimation(.none) {
                tempCount = count
            }
           
        }
    }
}

#Preview {
    PostButton(count: 2,
               active: false,
               buttonType: .like,
               action: {})
}
