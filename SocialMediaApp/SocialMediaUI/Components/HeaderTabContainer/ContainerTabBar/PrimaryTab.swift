//
//  PrimaryTab.swift
//  SocialMedia
//

import SwiftUI

/// While these views may be constructed directly, typically, they are only directly referenced in the `tabItem()` view modifier configuration
/// parameters and subsequently constructed by the system.
public struct PrimaryTab<Tab>: View where Tab: Hashable {
    
    /// Optional configuration parameters for selected and deselected tab selectors.
    public struct Config {
        public var font: Font?
        public var titleStyle: (any ShapeStyle)?
        public var underlineStyle: (any ShapeStyle)?
        public var underlineThickness: CGFloat
        public var underlineShape: (any View & Shape)?
        public var bottomRuleStyle: (any ShapeStyle)?
        public var bottomRuleThickness: CGFloat
        public var backgroundStyle: (any ShapeStyle)?
        public var padding: EdgeInsets
        public var contentPadding: EdgeInsets
        public var contentSpacing: CGFloat

        public init(
            font: Font? = .footnote.weight(.semibold),
            titleStyle: (any ShapeStyle)? = nil,
            underlineStyle: (any ShapeStyle)? = nil,
            underlineThickness: CGFloat = 1,
            underlineShape: (any View & Shape)? = Rectangle(),
            bottomRuleStyle: (any ShapeStyle)? = nil,
            bottomRuleThickness: CGFloat = 1,
            backgroundStyle: (any ShapeStyle)? = nil,
            padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
            contentPadding: EdgeInsets = EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0),
            contentSpacing: CGFloat = 3
        ) {
            self.font = font
            self.titleStyle = titleStyle
            self.underlineStyle = underlineStyle
            self.underlineThickness = underlineThickness
            self.underlineShape = underlineShape
            self.bottomRuleStyle = bottomRuleStyle
            self.bottomRuleThickness = bottomRuleThickness
            self.backgroundStyle = backgroundStyle
            self.padding = padding
            self.contentPadding = contentPadding
            self.contentSpacing = contentSpacing
        }
    }

    public init<Icon>(
        tab: Tab,
        context: TabsHeaderContext<Tab>,
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
        context: TabsHeaderContext<Tab>,
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

    // MARK: - Variables

    @Environment(\.font) private var font: Font?
    private let tab: Tab
    private let context: TabsHeaderContext<Tab>
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

    private var bottomRuleStyle: AnyShapeStyle {
        activeConfig.bottomRuleStyle.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.secondary.opacity(0.35))
    }

    private var titleStyle: AnyShapeStyle {
        activeConfig.titleStyle.map { AnyShapeStyle($0) } ?? AnyShapeStyle(.tint)
    }

    private var underlineStyle: AnyShapeStyle {
        activeConfig.underlineStyle.map { AnyShapeStyle($0) } ?? titleStyle
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
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(activeConfig.contentPadding)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.borderless)
                .background(alignment: .bottom) {
                    if let underlineShape {
                        underlineShape
                            .fill(underlineStyle)
                            .frame(height: activeConfig.underlineThickness)
                            .transition(.noTransition)
                            .matchedGeometryEffect(
                                id: "underline",
                                in: context.animationNamespace ?? initialNamespace
                            )
                    }
                }
            }
            .padding(activeConfig.padding)
            Rectangle().fill(bottomRuleStyle)
                .frame(height: activeConfig.bottomRuleThickness)
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

#Preview {
    let context = TabsHeaderContext(selectedTab: 0)

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
