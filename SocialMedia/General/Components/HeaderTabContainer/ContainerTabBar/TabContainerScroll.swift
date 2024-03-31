//
//  TabContainerScroll.swift
//  SocialMedia
//

import SwiftUI

/// A lightweight scroll view wrapper that required for sticky header scroll effects. For most intents and purposes, you should use
/// `ContainerTabsScroll` as you would a vertically-oriented `ScrollView`, with typical content being a `VStack` or `LazyVStack`.
///
/// `ContainerTabs` adjusts the scroll position when switching tabs to ensure continuity when switching tabs after collapsing or expanding the header.
/// However, joint manipulation of scroll position is supported, provided that you supply the scroll item and unit point bindings. However, when
/// using joint manipulation, you must supply a `reservedItem` identifier for `ContainerTabs` to use internally on its own hidden view. This approach was
/// adopted because precise manipulation of scroll position requires knowing the height the view associated with the scroll item and using our own internal
/// view for that seemed the easiest solution.
///
/// Never apply the `scrollPosition()` view modifier to this view because it is already being applied internally. You are free to apply
/// `scrollTargetLayout()` to your content as needed.
public struct TabContainerScroll<Content, Tab, Item>: View where Content: View, Tab: Hashable, Item: Hashable {

    /// Constructs a scroll for the given tab.
    ///
    /// - Parameters:
    ///   - tab: The tab that this scroll belongs to.
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    ///
    /// Never apply the `scrollPosition()` view modifier to this view because it is already being applied internally. You are free to apply
    /// `scrollTargetLayout()` to your content as needed.
    public init(
        tab: Tab,
        refreshableAction: (() async throws -> Void)? = nil,
        @ViewBuilder content: @escaping (_ context: ContainerTabsScrollContext<Tab>) -> Content
    ) where Item == ScrollItem {
        self.init(
            tab: tab,
            reservedItem: .item,
            scrollItem: .constant(nil),
            scrollUnitPoint: .constant(.top),
            refreshableAction: refreshableAction,
            content: content
        )
    }
    
    /// Constructs a scroll for the given tab with external bindings for join manipulation of the scroll position.
    ///
    /// - Parameters:
    ///   - tab: The tab that this scroll belongs to.
    ///   - reservedItem: A reserved item identifier used internally.
    ///   - scrollItem: The binding to the scroll item identifier.
    ///   - scrollUnitPoint: The binding to the scroll unit point.
    ///   - content: The scroll content view builder, typically a `VStack` or `LazyVStack`.
    ///
    ////// `ContainerTabs` adjusts the scroll position when switching tabs to ensure continuity when switching tabs after collapsing or expanding the header.
    /// However, joint manipulation of scroll position is supported, provided that you supply the scroll item and unit point bindings. However, when
    /// using joint manipulation, you must supply a `reservedItem` identifier for `ContainerTabs` to use internally on its own hidden view. This approach was
    /// adopted because precise manipulation of scroll position requires knowing the height the view associated with the scroll item and using our own internal
    /// view for that seemed the easiest solution.
    
    /// Never apply the `scrollPosition()` view modifier to this view because it is already being applied internally. You are free to apply
    /// `scrollTargetLayout()` to your content as needed.
    public init(
        tab: Tab,
        reservedItem: Item,
        scrollItem: Binding<Item?>,
        scrollUnitPoint: Binding<UnitPoint>,
        refreshableAction: (() async throws -> Void)? = nil,
        @ViewBuilder content: @escaping (_ context: ContainerTabsScrollContext<Tab>) -> Content
    ) {
        self.tab = tab
        self.reservedItem = reservedItem
        _scrollItem = scrollItem
        _scrollUnitPoint = scrollUnitPoint
        _scrollModel = StateObject(
            wrappedValue: ScrollModel(
                tab: tab,
                reservedItem: reservedItem
            )
        )
        self.refreshableAction = refreshableAction
        self.content = content
    }

    private let tab: Tab
    private let reservedItem: Item?
    @State private var coordinateSpaceName = UUID()
    @Binding private var scrollItem: Item?
    @Binding private var scrollUnitPoint: UnitPoint
    @StateObject private var scrollModel: ScrollModel<Item, Tab>
    @ViewBuilder private var content: (_ context: ContainerTabsScrollContext<Tab>) -> Content
    @EnvironmentObject private var headerModel: HeaderModel<Tab>
    
    var refreshableAction: (() async throws -> Void)? = nil
    
    // MARK: - Body
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Color.clear
                    .frame(height: headerModel.state.headerContext.maxOffset)
                    .background {
                        GeometryReader { proxy in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: proxy.frame(in: .named(coordinateSpaceName)).origin.y
                            )
                        }
                    }
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { offset in
                        scrollModel.contentOffsetChanged(offset)
                    }
                ZStack(alignment: .top) {
                    Color.clear
                        .frame(height: 0.1)
                        .id(reservedItem)
                    content(
                        ContainerTabsScrollContext<Tab>(
                            headerContext: headerModel.state.headerContext,
                            safeHeight: headerModel.state.safeHeight
                        )
                    )
                }
            }
        }
      
        .refreshable {
            Task {
                try await refreshableAction?()
            }
        }
        .coordinateSpace(name: coordinateSpaceName)
        .scrollPosition(id: $scrollModel.scrollItem, anchor: scrollModel.scrollUnitPoint)
        .transaction(value: scrollModel.scrollItem) { transaction in
            // Sometimes this happens in an animation context, but this prevents animation
            transaction.animation = nil
        }
        .onFirstAppear {
            // It is important not to attempt to adjust the scroll position until after the view has appeared
            // and this task seems to accomplish that.
            Task {
                scrollModel.appeared(headerModel: headerModel)
            }
        }
        .onChange(of: headerModel.state.headerContext.selectedTab, initial: true) {
            scrollModel.selectedTabChanged()
        }
        .onChange(of: scrollItem, initial: true) {
            scrollModel.scrollItemChanged(scrollItem)
        }
        .onChange(of: scrollUnitPoint, initial: true) {
            scrollModel.scrollUnitPointChanged(scrollUnitPoint)
        }
        .onChange(of: headerModel.state.headerContext.height) {
            scrollModel.headerHeightChanged()
        }
        .onChange(of: headerModel.state.headerContext.safeArea.top) {
            scrollModel.headerHeightChanged()
        }
        .onDisappear() {
            scrollModel.disappeared()
        }
    }
}

public enum ScrollItem: Hashable {
    case item
}
