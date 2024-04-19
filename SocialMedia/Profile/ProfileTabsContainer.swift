//
//  ProfileTabsContainer.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

struct ProfileTabsContainer: View {
    var router: any Router
    var user: User
    var didNavigate: Bool
    
    @State private var selectedTab: ProfilePostFilter = .posts
    
    @Environment(\.horizontalSizeClass) private var sizeClass
 
    @State private var offset: CGFloat = .zero
    @State private var headerHeight: CGFloat = 0
    private let padding: CGFloat = 16

    private var isCompact: Bool {
        if sizeClass == .compact {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(ProfilePostFilter.allCases) { tab in
                            
                            OffsetReadableTabContentScrollView(tabType: tab.id, selection: selectedTab, onChangeOffset: { offset in
                                updateOffset(offset, safeAreaInsetsTop: geometry.safeAreaInsets.top) }) {
                                    ProfileTabsContentView(
                                        router: router,
                                        user: user,
                                        tab: tab,
                                        contentUnavailable: user.privateProfile && !(user.isFollowed)
                                    )
                                    .offset(y: -offset)
                                    .padding(.bottom, headerHeight + padding)
                                }
                                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                .refreshable {
                                    Task {
                                        
                                    }
                                }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: Binding($selectedTab))
                .scrollIndicators(.never)
                .scrollBounceBehavior(.always)
                .padding(.top, headerHeight + offset)
                
                VStack(alignment: .center, spacing: padding) {
                    Group {
                        if user.isCurrentUser {
                            CurrentUserProfileHeader(didNavigate: didNavigate, hideToolbarMenuButton: offset == -headerHeight)
                        } else {
                            UserProfileHeader(user: user)
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity)
                    .opacity(offset == -headerHeight ? 0 : 1)
                   
                    TopFilterBar(currentFilter: $selectedTab)
                }
                .background(
                    GeometryReader { topFilterGeometry in
                        Color.clear.onAppear {
                            headerHeight = topFilterGeometry.size.height
                        }
                    }
                )
                .background(.bar)
                .offset(y: offset)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .background(Color.groupedBackground)
    }
    
    private func updateOffset(_ newOffset: CGFloat, safeAreaInsetsTop: CGFloat) {
        if newOffset <= -headerHeight + safeAreaInsetsTop {
            offset = -headerHeight + safeAreaInsetsTop
        } else if newOffset >= 0.0 {
            offset = 0
        } else {
            offset = newOffset
        }
    }
}

#Preview {
    CurrentUserProfileHeader()
}



struct OffsetReadableVerticalScrollView<Content: View>: View {
    private struct CoordinateSpaceName: Hashable {}
    
    private let showsIndicators: Bool
    private let onChangeOffset: (CGFloat) -> Void
    private let content: () -> Content
    
    public init(
        showsIndicators: Bool = true,
        onChangeOffset: @escaping (CGFloat) -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.showsIndicators = showsIndicators
        self.onChangeOffset = onChangeOffset
        self.content = content
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicators) {
            ZStack(alignment: .top) {
                GeometryReader { geometryProxy in
                    Color.clear.preference(
                        key: ScrollViewOffsetYPreferenceKey.self,
                        value: geometryProxy.frame(in: .named(CoordinateSpaceName())).minY
                    )
                }
                .frame(width: 1, height: 1)
                content()
            }
        }
        .coordinateSpace(name: CoordinateSpaceName())
        .onPreferenceChange(ScrollViewOffsetYPreferenceKey.self) { offset in
            onChangeOffset(offset)
        }
    }
}

struct ScrollViewOffsetYPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

struct OffsetReadableTabContentScrollView<TabType: Hashable, Content: View>: View {
    let tabType: TabType
    var selection: TabType
    let onChangeOffset: (CGFloat) -> Void
    let content: () -> Content
    
    @State private var currentOffset: CGFloat = .zero
    
    public var body: some View {
        OffsetReadableVerticalScrollView(
            onChangeOffset: { offset in
                currentOffset = offset
                
                                onChangeOffset(offset)

            },
            content: content
        )
        .onChange(of: selection) { oldValue, newValue in
            if oldValue != newValue {
                onChangeOffset(currentOffset)
            }
        }
    }
}

public extension BinaryFloatingPoint {
    func clamped01() -> Self {
        return self.clamped(min: 0, max: 1)
    }
}
public extension Comparable {
    func clamped(min minValue: Self, max maxValue: Self) -> Self {
        return min(max(self, minValue), maxValue)
    }
}
