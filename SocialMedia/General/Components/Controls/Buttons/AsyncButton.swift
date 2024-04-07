
import SwiftUI

public struct AsyncButton<Label: View>: View {
    public var role: ButtonRole? = nil
    public var action: () async -> Void
    @ViewBuilder public let label: () -> Label
    
    @MainActor
    @State private var isRunning = false
    
    public var body: some View {
        Button(role: role) {
            isRunning = true
            Task {
                await action()
                isRunning = false
            }
        } label: {
            Group {
                if isRunning {
                    ProgressView()
                } else {
                    label()
                        .font(.headline)
                }
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .disabled(isRunning)
    }
}

public extension AsyncButton where Label == Text {
    init(
        _ titleKey: LocalizedStringKey,
        role: ButtonRole? = nil,
        action: @escaping () async -> Void
    ) {
        self.init(role: role, action: action) { Text(titleKey) }
    }
}

#Preview {
    AsyncButton("Async Task") {
        try? await Task.sleep(nanoseconds: 6_000_000_000)
    }
    .padding()
}
