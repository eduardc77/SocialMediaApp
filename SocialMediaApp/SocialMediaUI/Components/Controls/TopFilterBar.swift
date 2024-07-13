
import SwiftUI

public protocol TopFilter: Hashable, CaseIterable, Identifiable {
    var title: String { get }
}

public struct TopFilterBar<T: TopFilter>: View {
    @Binding private var currentFilter: T
    private var onSelection: (() -> Void)? = nil
    
    @Namespace private var animation
    
    public init(currentFilter: Binding<T>, onSelection: (() -> Void)? = nil) {
        self._currentFilter = currentFilter
        self.onSelection = onSelection
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                ForEach(Array(T.allCases)) { filter in
                    feedFilterItem(for: filter)
                        .id(filter)
                        .frame(maxWidth: .infinity)
                }
            }
            Divider()
        }
        .onChange(of: currentFilter) { _, newValue in
            onSelection?()
        }
    }
    
    @ViewBuilder
    public func feedFilterItem(for filter: any TopFilter) -> some View {
        Button {
            guard let filter = filter as? T else { return }
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                onSelection?()
                currentFilter = filter
            }
        } label: {
            Text(filter.title)
                .font(.footnote.weight(.semibold))
                .padding(.bottom, 8)
                .foregroundStyle(currentFilter.hashValue == filter.hashValue ? Color.primary : Color.secondary)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .bottom) {
                    if currentFilter.hashValue == filter.hashValue {
                        Rectangle()
                            .fill(.primary)
                            .frame(height: 1.5)
                            .matchedGeometryEffect(id: "TopFilterBar", in: animation)
                            .padding(.horizontal)
                        
                    }
                }
                .animation(.default, value: currentFilter)
        }
    }
}

#Preview {
    enum ExampleFilter: String, TopFilter {
        case first, second
        
        var id: ExampleFilter { self }
        
        var title: String { rawValue.capitalized }
    }
    
    struct Example: View {
        @State var selection: ExampleFilter = .first
        
        var body: some View {
            TopFilterBar(currentFilter: $selection)
        }
    }
    return Example()
}
