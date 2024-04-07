
import SwiftUI

public struct CTAButton: View {
    let title: String
    let foregroundColor: Color
    let backgroundColor: Color?
    let lineWidth: CGFloat
    let action: () -> Void
    
    public init(title: String, foregroundColor: Color = .white, backgroundColor: Color? = nil, lineWidth: CGFloat = 1.25, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.lineWidth = lineWidth
    }
    
    public var body: some View {
        Button {
            action()
            
        } label: {
            HStack(spacing: 8) {
                Text(title)
                Image(systemName: "arrow.right.circle")
                    .imageScale(.large)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(backgroundColor.clipShape(Capsule()))
            .background(Capsule().strokeBorder(foregroundColor, lineWidth: lineWidth))
        }
        .foregroundStyle(foregroundColor)
    }
}

#Preview {
    CTAButton(title: "Start", action: {}).preferredColorScheme(.dark).previewLayout(.sizeThatFits)
}
