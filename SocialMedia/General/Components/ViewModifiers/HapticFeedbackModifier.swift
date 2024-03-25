//
//  HapticFeedbackModifier.swift
//  SocialMedia
//

import SwiftUI

#if canImport(UIKit)
struct HapticFeedbackModifier<T: Equatable>: ViewModifier {
    private let generator: UIImpactFeedbackGenerator
    private let intensity: CGFloat
    private let trigger: T
    
    init(feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle, intensity: CGFloat, trigger: T) {
        generator = UIImpactFeedbackGenerator(style: feedbackStyle)
        self.intensity = intensity
        self.trigger = trigger
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: trigger) { _, _ in
                generator.prepare()
                generator.impactOccurred(intensity: intensity)
            }
    }
}

extension View {
    func hapticFeedback<T: Equatable>(feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle = .medium, intensity: CGFloat = 0.8, trigger: T) -> some View {
        modifier(HapticFeedbackModifier(feedbackStyle: feedbackStyle, intensity: intensity, trigger: trigger))
    }
}
#endif
