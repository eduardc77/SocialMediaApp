//
//  TabItemModifier.swift
//  SocialMedia
//

import SwiftUI

///
public extension View {

    /// A view modifier that must be applied to top level tab contents when using `ContainerTabBar` with
    /// 3 primary or secondary tab styles.
    /// - Parameters:
    ///   - tab: The tab that the recieving view corresponds to.
    ///   - label: The tab selector label configuration option.
    /// - Returns: The modified reciever with the tab item registered and configured.
    func tabItem<Tab>(tab: Tab, label: ContainerTabBar<Tab>.Label) -> some View where Tab: Hashable {
        modifier(
            TabItemModifier<Tab>(
                tab: tab,
                label: { tab, context, tapped in
                    AnyView(
                        Group {
                            switch label {
                            case .primary(let title, let icon, let config, let deselectedConfig):
                                PrimaryTab(
                                    tab: tab,
                                    context: context,
                                    tapped: tapped,
                                    title: title,
                                    icon: icon.map { AnyView($0) },
                                    config: config,
                                    deselectedConfig: deselectedConfig
                                )
                            case .secondary(let title, let config, let deselectedConfig):
                                SecondaryTab(
                                    tab: tab,
                                    context: context,
                                    tapped: tapped,
                                    title: title,
                                    config: config,
                                    deselectedConfig: deselectedConfig
                                )
                            }
                        }
                    )
                }
            )
        )
    }

    /// A view modifier that must be applied to top level tab contents when using `ContainerTabBar` with custom tab selector labels.
    ///
    /// - Parameters:
    ///   - tab: The tab that the recieving view corresponds to.
    ///   - label: A view builder that supplies the tab bar label.
    /// - Returns: The modified reciever with the tab item registered and configured.
    ///
    /// Custom labels should have greedy width and height using `.frame(maxWidth: .infinity, maxHeight: .infinity)`. The tab bar layout
    /// will automatically detmerine their intrinsic content sizes and set their frames based on the available space. All labels will be given the same height,
    /// determined by the maximum intrinsic height across all labels.
    func tabItem<Tab, Label>(
        tab: Tab,
        @ViewBuilder label: @escaping (
            _ tab: Tab,
            _ context: TabsHeaderContext<Tab>,
            _ tapped: @escaping () -> Void
        ) -> Label
    ) -> some View where Tab: Hashable, Label: View {
        modifier(TabItemModifier<Tab>(tab: tab, label: { AnyView(label($0, $1, $2)) }))
    }

    /// A view modifier that must be applied to top level tab contents when supplying a custom tab bar.
    /// - Parameter tab: The tab that the recieving view corresponds to.
    /// - Returns: The modified reciever with the tab item registered and configured.
    func tabItem<Tab>(tab: Tab) -> some View where Tab: Hashable {
        modifier(TabItemModifier<Tab>(tab: tab, label: { _, _, _ in AnyView(EmptyView()) }))
    }
}

public struct TabItemModifier<Tab>: ViewModifier where Tab: Hashable {

    // MARK: - API

    init(
        tab: Tab,
        @ViewBuilder label: @escaping ContainerTabBar<Tab>.CustomLabel
    ) {
        self.tab = tab
        self.label = label
    }

    let tab: Tab
    @ViewBuilder let label: ContainerTabBar<Tab>.CustomLabel

    // MARK: - Constants

    /// This view is a for registering all of the tabs
    @MainActor
    private struct TabRegisteringView: View where Tab: Hashable {

        init(tab: Tab, label: @escaping ContainerTabBar<Tab>.CustomLabel, tabBarModel: TabBarModel<Tab>, headerModel: HeaderModel<Tab>) {
            tabBarModel.register(tab: tab, label: label)
            headerModel.tabsRegistered()
        }

        var body: some View {
            EmptyView()
        }
    }

    // MARK: - Variables

    @EnvironmentObject private var headerModel: HeaderModel<Tab>
    @EnvironmentObject private var tabBarModel: TabBarModel<Tab>
    @State private var foo = 0

    // MARK: - Body

    public func body(content: Content) -> some View {
        content
            .background {
                TabRegisteringView(tab: tab, label: label, tabBarModel: tabBarModel, headerModel: headerModel)
            }
            .id(tab)
    }
}
