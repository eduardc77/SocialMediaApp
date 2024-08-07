//
//  TabsContainer.swift
//  SocialMedia
//

import SwiftUI

public typealias TabsHeaderContext = HeaderContext

/// `TabsContainer` is the primary Tabs container view, consisting of a top header for the tab bar and other elements and a bottom area for tab content.
/// With out-of-the box
/// support for both primary and secondary tab styles.
///
/// The content of a tab typically is typically a scroll view containing custom content, which must be constructed using the lightweight `ScrollView`
/// wrapper `TabsScroll`. Swiping left and right on tab contents pages between tabs. Each content view must be identified and configured
/// using the `tabItem()` view modifier (conceptually similar to a combination of the `tag()` and `tagitem()` view
/// modifiers used with a standard `TabView`).
///
/// Header elements consist of an optional title view, the tab bar below it, and an optional background view spanning the header and top safe area.
/// When tab content is scrolled, the library automatically offsets the header to track scrolling, but sticks at the top when the tab bar reaches the top safe area.
/// The header elements are collectively referred to as the "sticky header" throughout the library.
///
/// The `headerStyle()` view modifier can be applied to one or more sticky header elements to achieve sophisticated scroll effects, such
/// as fade, shrink and parallax. The effects are driven by a variety of dynamic metrics, through the stream of `TabsHeaderContext` values
/// provided to each header element's view builder. You may implement your own header styles or use the context in other ways to achieve a variety of
/// unique effects.
///
/// To use sticky headers without tabs, use the `StickyHeader` view instead of `TabsContainer`.
public struct TabsContainer<HeaderTitle, HeaderTabBar, HeaderBackground, Content, Tab>: View
    where HeaderTitle: View, HeaderTabBar: View, HeaderBackground: View, Content: View, Tab: Hashable {

    // MARK: - API
    
    /// Constructs a container tabs component with a header title, tab bar and tab contents (no background).
    ///
    /// - Parameters:
    ///   - selectedTab: The external tab selection binding.
    ///   - headerTitle: The header title view builder.
    ///   - headerTabBar: The header tab bar. `ContainerTabBar` is typically used, but any custom view may be provideded.
    ///   - content: a content view builder, who's top level elements are assumed to be individual tab contents.
    ///
    /// Top-level content elements are typically `TabsScroll` views. `TabsScroll` is a lightweight wrapper, around
    /// `ScrollView` and is required to enable scroll effects. Top level content elements must apply the `tabItem()` view modifier
    /// in order to identify and configure each tab (conceptually similar to a combination of the `tag()` and `tagitem()` view
    /// modifiers used with a standard `TabView`).
    public init(
        selectedTab: Binding<Tab>,
        @ViewBuilder headerTitle: @escaping (TabsHeaderContext<Tab>) -> HeaderTitle,
        @ViewBuilder headerTabBar: @escaping (TabsHeaderContext<Tab>) -> HeaderTabBar,
        @ViewBuilder content: @escaping () -> Content
    ) where HeaderBackground == EmptyView {
        self.init(
            selectedTab: selectedTab,
            headerTitle: headerTitle,
            headerTabBar: headerTabBar,
            headerBackground: { _ in EmptyView() },
            content: content
        )
    }

    /// Constructs a container tabs component with a tab bar and tab contents (no title or background).
    ///
    /// - Parameters:
    ///   - selectedTab: The external tab selection binding.
    ///   - headerTitle: The header title view builder.
    ///   - headerTabBar: The header tab bar. `ContainerTabBar` is typically used, but any custom view may be provideded.
    ///   - content: a content view builder, who's top level elements are assumed to be individual tab contents.
    ///
    /// Top-level content elements are typically `TabsScroll` views. `TabsScroll` is a lightweight wrapper, around
    /// `ScrollView` and is required to enable scroll effects. Top level content elements must apply the `tabItem()` view modifier
    /// in order to identify and configure each tab (conceptually similar to a combination of the `tag()` and `tagitem()` view
    /// modifiers used with a standard `TabView`).
    public init(
        selectedTab: Binding<Tab>,
        @ViewBuilder headerTabBar: @escaping (TabsHeaderContext<Tab>) -> HeaderTabBar,
        @ViewBuilder content: @escaping () -> Content
    ) where HeaderTitle == EmptyView, HeaderBackground == EmptyView {
        self.init(
            selectedTab: selectedTab,
            headerTitle:  { _ in EmptyView() },
            headerTabBar: headerTabBar,
            headerBackground: { _ in EmptyView() },
            content: content
        )
    }

    /// Constructs a container tabs component with all elements: header title, tab bar, header background and tab contents.
    ///
    /// - Parameters:
    ///   - selectedTab: The external tab selection binding.
    ///   - headerTitle: The header title view builder.
    ///   - headerTabBar: The header tab bar. `ContainerTabBar` is typically used, but any custom view may be provideded.
    ///   - headerBackground: The header background view builder, typically a `Color`, `Gradient` or scalable `Image`.
    ///   - content: a content view builder, who's top level elements are assumed to be individual tab contents.
    ///
    /// Top-level content elements are typically `TabsScroll` views. `TabsScroll` is a lightweight wrapper, around
    /// `ScrollView` and is required to enable scroll effects. Top level content elements must apply the `tabItem()` view modifier
    /// in order to identify and configure each tab (conceptually similar to a combination of the `tag()` and `tagitem()` view
    /// modifiers used with a standard `TabView`).
    public init(
        selectedTab: Binding<Tab>,
        @ViewBuilder headerTitle: @escaping (TabsHeaderContext<Tab>) -> HeaderTitle,
        @ViewBuilder headerTabBar: @escaping (TabsHeaderContext<Tab>) -> HeaderTabBar,
        @ViewBuilder headerBackground: @escaping (TabsHeaderContext<Tab>) -> HeaderBackground,
        @ViewBuilder content: @escaping () -> Content
    ) {
        _selectedTab = selectedTab
        self.header = { context in
            HeaderView(
                context: context,
                title: headerTitle,
                tabBar: headerTabBar,
                background: headerBackground
            )
        }
        self.content = content
        _headerModel = StateObject(wrappedValue: HeaderModel(selectedTab: selectedTab.wrappedValue))
    }

    @Binding private var selectedTab: Tab
    @State private var selectedTabScroll: Tab?
    @ViewBuilder private let header: (TabsHeaderContext<Tab>) -> HeaderView<HeaderTitle, HeaderTabBar, HeaderBackground, Tab>
    @ViewBuilder private let content: () -> Content
    @StateObject private var headerModel: HeaderModel<Tab>
    @StateObject private var tabBarModel = TabBarModel<Tab>()
    
    public var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        content()
                            .scrollClipDisabled()
                            .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                            .safeAreaPadding(proxy.safeAreaInsets)
                            // Padding the top safe area by the minimum header height makes scrolling
                            // calculations work out better. For example, scrolling an item to `.top`
                            // results in a fully collapsed header with the item touching the header
                            // as one would expect.
                            .safeAreaPadding(.top, headerModel.state.headerContext.minTotalHeight)
                    }
                    .scrollTargetLayout()
                }
                .scrollPosition(id: $selectedTabScroll, anchor: .center)
                .scrollTargetBehavior(.paging)
                .scrollClipDisabled()
                .scrollIndicators(.never)
                .scrollBounceBehavior(.basedOnSize)
                .ignoresSafeArea()
                .onChange(of: proxy.size, initial: true) {
                    headerModel.sizeChanged(proxy.size)
                }
                header(headerModel.state.headerContext)
                    .background {
                            if !headerModel.state.tabsRegistered {
                                /// This is a somewhat elaborate workaround for using a horizontal paged `ScrollView` instead of a `TabView`.
                                /// The `TabView` had some insurmountable inconsistency issues when used in different context, such as
                                /// within a `NavigationStack`. The issue with `ScrollView` is that it is using a `LazyHStack`
                                /// and, due to the laziness, tabs that are off-screen do not get registered. Whent he same content
                                /// is placed in a `TabView`, all of the tabs get registered. So what we're doing here is briefly
                                /// including a `TabView` with the tab content and then removing it after the tabs get registered.
                                /// Making the frame zero height ensures that nothing actually gets rendered.
                                TabView {
                                    content()
                                }
#if !os(macOS)
                                .tabViewStyle(.page(indexDisplayMode: .never))
#endif
                                .frame(height: 0)
                            }
                    }
            }
            .onChange(of: proxy.safeAreaInsets, initial: true) {
                headerModel.safeAreaChanged(proxy.safeAreaInsets)
            }
        }
        .animation(.default, value: selectedTab)
        .environmentObject(headerModel)
        .environmentObject(tabBarModel)
        .onPreferenceChange(TitleHeightPreferenceKey.self, perform: headerModel.titleHeightChanged(_:))
        .onPreferenceChange(TabBarHeightPreferenceKey.self, perform: headerModel.tabBarHeightChanged(_:))
        .onPreferenceChange(MinTitleHeightPreferenceKey.self, perform: headerModel.minTitleHeightChanged(_:))
        .onChange(of: selectedTab, initial: true) {
            headerModel.selected(tab: selectedTab)
        }
        .onChange(of: selectedTabScroll) {
            guard let selectedTab = selectedTabScroll else { return }
            headerModel.selected(tab: selectedTab)
        }
        .onChange(of: headerModel.state.headerContext.selectedTab, initial: true) {
            selectedTab = headerModel.state.headerContext.selectedTab
            selectedTabScroll = selectedTab
        }
    }
}
