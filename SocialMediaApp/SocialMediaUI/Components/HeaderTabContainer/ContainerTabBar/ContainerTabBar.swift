//
//  ContainerTabBar.swift
//  SocialMedia
//

import SwiftUI

public typealias TabsContainerHeaderContext = HeaderContext

/// A scrollable tab bar implementation. The tab bar can be configured to size tab selectors
/// equally or proportionally. Tab selectors are configured by applying the `containerTabItem()` view modifier to the top-level tab content views.
/// The `containerTabItem()` modifier is conceptually similar to a combination of the `tab()` and `tabItem()` view modifiers used with
/// a standard `TabView`. In addition to primary and secondary styles,  `containerTabItem()` supports fully custom tab selectors.
/// If space permits, tabs selectors will fill the entire width of the tab bar. Otherwise, the tab bar will scroll horizontally.
public struct ContainerTabBar<Tab>: View where Tab: Hashable {

    public enum Label {
        
        /// Supply a title, icon or both. Provide selected and/or deselected configs to customize further.
        case primary(
            String? = nil,
            icon: (any View)? = nil,
            config: PrimaryTab<Tab>.Config = .init(),
            deselectedConfig: PrimaryTab<Tab>.Config? = nil
        )
        
        /// Provide selected and/or deselected configs to customize further.
        case secondary(
            String,
            config: SecondaryTab<Tab>.Config = .init(),
            deselectedConfig: SecondaryTab<Tab>.Config? = nil
        )
    }
    
    /// Options for tab selector width sizing. If space permits, tabs selectors will fill the entire width of the tab bar. Otherwise, the tab bar will scroll horizontally.
    public enum Sizing {
        
        /// Size all tab selectors equally. If space permits, tabs selectors will fill the entire width of the tab bar. Otherwise, the tab bar will scroll horizontally.
        case equalWidth
        
        /// Size all tab selectors proportionally. If space permits, tabs selectors will fill the entire width of the container. Otherwise, the tab bar will scroll horizontally.
        case proportionalWidth
    }
    
    /// A closure for providing a custom tab selector labels. Custom labels should have greedy width and height
    /// using `.frame(maxWidth: .infinity, maxHeight: .infinity)`. The tab bar layout will automatically determine their intrinsic content sizes
    /// and set their frames based on the `Sizing` option and available space. All labels will be given the same height, determined by the maximum
    /// intrinsic height across all labels.
    public typealias CustomLabel = (
        _ tab: Tab,
        _ context: TabsHeaderContext<Tab>,
        _ tapped: @escaping () -> Void
    ) -> AnyView
    
    /// Constructs a tab bar component.
    /// - Parameters:
    ///   - selectedTab: The external tab selection binding.
    ///   - sizing: The tab selector sizing option.
    ///   - spacing: The amount of horizontal spacing to use between tab labels. Primary and Secondary tabs should use the default spacing of 0 to
    ///     form a continuous line across the bottom of the tab bar.
    ///   - fillAvailableSpace: Applicable when tab labels don't inherently fill the width of the tab bar. When `true` (the default), the label widths are
    ///     expanded proportinally to fill the tab bar. When `false`, the labels are not expanded and centered horizontally within the tab bar.
    ///   - context: The current context value.
    public init(
        selectedTab: Binding<Tab>,
        sizing: Sizing = .proportionalWidth,
        spacing: CGFloat = 0,
        fillAvailableSpace: Bool = true,
        context: TabsHeaderContext<Tab>
    ) {
        _selectedTab = selectedTab
        _selectedTabScroll = State(initialValue: selectedTab.wrappedValue)
        self.sizing = sizing
        self.context = context
        self.spacing = spacing
        self.fillAvailableSpace = fillAvailableSpace
    }

    // MARK: - Variables

    @Binding private var selectedTab: Tab
    @State private var selectedTabScroll: Tab?
    private let sizing: Sizing
    @EnvironmentObject private var tabBarModel: TabBarModel<Tab>
    @EnvironmentObject private var headerModel: HeaderModel<Tab>
    @State private var height: CGFloat = 0
    private let context: TabsHeaderContext<Tab>
    private let spacing: CGFloat
    private let fillAvailableSpace: Bool

    // MARK: - Body

    public var body: some View {
        GeometryReader { proxy in
            ScrollView(.horizontal) {
                TabBarLayout(
                    fittingWidth: proxy.size.width,
                    sizing: sizing,
                    spacing: spacing,
                    fillAvailableSpace: fillAvailableSpace
                ) {
                    ForEach(tabBarModel.tabs, id: \.self) { tab in
                        tabBarModel.labels[tab]?(
                            tab,
                            headerModel.state.headerContext,
                            {
                                headerModel.selected(tab: tab)
                            }
                        )
                        .id(tab)
                    }
                }
                .scrollTargetLayout()
                .frame(minWidth: proxy.size.width)
                .background {
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: TabBarHeightPreferenceKey.self, value: proxy.size.height)
                    }
                }
            }
            .scrollPosition(id: $selectedTabScroll, anchor: .center)
            .scrollIndicators(.never)
            .scrollBounceBehavior(.basedOnSize)
        }
        .frame(height: height)
        .onPreferenceChange(TabBarHeightPreferenceKey.self) { height in
            self.height = height
        }
        .onChange(of: selectedTab) {
            selectedTabScroll = selectedTab
        }
    }
}

struct ContainerTabBarPreviewView: View {

    init(tabCount: Int, sizing: ContainerTabBar<Int>.Sizing) {
        self.init(tabs: Array(0..<tabCount).map { ContainerTabBar<Int>.Label.secondary("Tab Number \($0)") }, sizing: sizing)
    }
    
    init(tabs: [ContainerTabBar<Int>.Label], sizing: ContainerTabBar<Int>.Sizing) {
        self.tabs = tabs
        self.sizing = sizing
    }

    private let tabs: [ContainerTabBar<Int>.Label]
    private let sizing: ContainerTabBar<Int>.Sizing
    @State private var selectedTab: Int = 0

    var body: some View {
        TabsContainer(
            selectedTab: $selectedTab,
            headerTabBar: { context in
                ContainerTabBar(selectedTab: $selectedTab, sizing: sizing, context: context)
            },
            content: {
                ForEach(Array(tabs.enumerated()), id: \.offset) { (offset, tab) in
                    Text("Content for tab \(offset)")
                        .tabItem(tab: offset, label: tab)
                }
            }
        )
    }
}
