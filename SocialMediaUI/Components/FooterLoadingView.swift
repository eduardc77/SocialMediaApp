
import SwiftUI

public struct FooterLoadingView: View {
    private let hidden: Bool
    private let loading: Bool
    private let onTask: () async -> Void
    
    public init(hidden: Bool, loading: Bool = true, onTask: @escaping () async -> Void) {
        self.hidden = hidden
        self.loading = loading
        self.onTask = onTask
    }
    
    public var body: some View {
        if !hidden {
            VStack(alignment: .center) {
                if loading {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            }
            .frame(maxWidth: .infinity)
            .task {
                await onTask()
            }
        }
    }
}
