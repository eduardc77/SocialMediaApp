//
//  PrimaryTab.swift
//  SocialMedia
//

import SwiftUI

/// While these views may be constructed directly, typically, they are only directly referenced in the `containerTabItem()` view modifier configuration
/// parameters and subsequently constructed by the system.
public struct PrimaryTab<Tab>: View where Tab: Hashable {
    
    /// Optional configuration parameters for selected and deselected tab selectors.
    public struct Config {
        public var font: Font?
        public var titleStyle: (any ShapeStyle)?
        public var underlineStyle: (any ShapeStyle)?
        public var underlineThickness: CGFloat
        public var underlineShape: (any View & Shape)?
        public var backgroundStyle: (any ShapeStyle)?
        public var padding: EdgeInsets
        public var contentPadding: EdgeInsets
        public var contentSpacing: CGFloat
        
        public init(
            font: Font? = .system(size: 14, weight: .semibold),
            titleStyle: (any ShapeStyle)? = nil,
            underlineStyle: (any ShapeStyle)? = nil,
            underlineThickness: CGFloat = 1.5,
            underlineShape: (any View & Shape)? = Rectangle(),
            backgroundStyle: (any ShapeStyle)? = nil,
            padding: EdgeInsets = EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10),
            contentPadding: EdgeInsets = EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0),
            contentSpacing: CGFloat = 0
        ) {
            self.font = font
            self.titleStyle = titleStyle
            self.underlineStyle = underlineStyle
            self.underlineThickness = underlineThickness
            self.underlineShape = underlineShape
            self.backgroundStyle = backgroundStyle
            self.padding = padding
            self.contentPadding = contentPadding
            self.contentSpacing = contentSpacing
        }
    }
    
    public init<Icon>(
        tab: Tab,
        context: ContainerTabsHeaderContext<Tab>,
        tapped: @escaping () -> Void,
        title: String? = nil,
        icon: Icon,
        config: Config,
        deselectedConfig: Config?
    ) where Icon: View {
        self.tab = tab
        self.context = context
        self.tapped = tapped
        self.title = title
        self.icon = AnyView(icon)
        self.config = config
        self.deselectedConfig = deselectedConfig ?? config.makeDeselectedConfig()
    }
    
    public init(
        tab: Tab,
        context: ContainerTabsHeaderContext<Tab>,
        tapped: @escaping () -> Void,
        title: String? = nil,
        config: Config,
        deselectedConfig: Config?
    ) {
        self.tab = tab
        self.context = context
        self.tapped = tapped
        self.title = title
        self.icon = nil
        self.config = config
        self.deselectedConfig = deselectedConfig ?? config.makeDeselectedConfig()
    }

    @Environment(\.font) private var font: Font?
    private let tab: Tab
    private let context: ContainerTabsHeaderContext<Tab>
    private let tapped: () -> Void
    private let title: String?
    private let icon: AnyView?
    private let config: Config
    private let deselectedConfig: Config
    @Namespace private var initialNamespace
    
    private var activeConfig: Config {
        switch tab == context.selectedTab {
        case true: config
        case false: deselectedConfig
        }
    }

    private var titleStyle: AnyShapeStyle {
        activeConfig.titleStyle.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.primary)
    }
    
    private var underlineStyle: AnyShapeStyle {
        activeConfig.underlineStyle.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.tint)
    }
    
    private var underlineShape: AnyShape? {
        activeConfig.underlineShape.map { AnyShape($0) }
    }

    public var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                Spacer()
                Button(action: tapped) {
                    VStack(spacing: activeConfig.contentSpacing) {
                        if let icon {
                            icon
                                .font(.system(size: 26))
                                .foregroundStyle(titleStyle)
                        }
                        if let title {
                            Text(title)
                                .font(activeConfig.font ?? font)
                                .foregroundStyle(titleStyle)
                        }
                    }
                    .padding(activeConfig.contentPadding)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(alignment: .bottom) {
                    if let underlineShape {
                        underlineShape
                            .fill(underlineStyle)
                            .frame(maxWidth: .infinity, maxHeight: activeConfig.underlineThickness * 2)
                            .offset(y: activeConfig.underlineThickness)
                            .clipped()
                            .transition(.noTransition)
                            .matchedGeometryEffect(
                                id: "underline",
                                in: context.animationNamespace ?? initialNamespace
                            )
                    }
                }
            }
            .padding(activeConfig.padding)
            Divider()
                .padding(.horizontal, -500)
        }
        .transaction(value: context.selectedTab) { transform in
            transform.animation = .snappy(duration: 0.35, extraBounce: 0.07)
        }
    }
}

public extension PrimaryTab.Config {
    func makeDeselectedConfig() -> Self {
        var config = self
        switch config.titleStyle {
        case let textStyle?:
            config.titleStyle = textStyle.opacity(0.2)
        case .none:
            config.titleStyle = .secondary
        }
        config.underlineShape = nil
        return config
    }
}

extension AnyTransition {
    static var noTransition: AnyTransition {
        .asymmetric(insertion: .scale(scale: 1), removal: .scale(scale: 0.999999))
    }
}

#Preview {
    let context = ContainerTabsHeaderContext(selectedTab: 0)
    
    return VStack() {
        PrimaryTab<Int>(
            tab: 0,
            context: context,
            tapped: { print("tapped" )},
            title: "Tab Title",
            config: .init(),
            deselectedConfig: nil
        )
        .background(Color.black.opacity(0.05))
        PrimaryTab<Int>(
            tab: 0,
            context: context,
            tapped: { print("tapped" )},
            title: nil,
            icon: Image(systemName: "medal"),
            config: .init(),
            deselectedConfig: nil
        )
        .background(Color.black.opacity(0.05))
        PrimaryTab<Int>(
            tab: 1,
            context: context,
            tapped: { print("tapped" )},
            title: "Tab Title",
            icon: Image(systemName: "medal"),
            config: .init(),
            deselectedConfig: nil
        )
        .background(Color.black.opacity(0.05))
    }
    .padding()
}
