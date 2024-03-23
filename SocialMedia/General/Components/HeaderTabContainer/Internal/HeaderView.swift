//
//  HeaderView.swift
//  SocialMedia
//

import SwiftUI

struct HeaderView<Title, TabBar, Background, Tab>: View where Title: View, TabBar: View, Background: View, Tab: Hashable {

    init(
        context: HeaderContext<Tab>,
        @ViewBuilder title: @escaping (HeaderContext<Tab>) -> Title,
        @ViewBuilder tabBar: @escaping (HeaderContext<Tab>) -> TabBar,
        @ViewBuilder background: @escaping (HeaderContext<Tab>) -> Background
    ) {
        self.context = context
        self.title = title
        self.tabBar = tabBar
        self.background = background
    }

    private let context: HeaderContext<Tab>
    @ViewBuilder private let title: (HeaderContext<Tab>) -> Title
    @ViewBuilder private let tabBar: (HeaderContext<Tab>) -> TabBar
    @ViewBuilder private let background: (HeaderContext<Tab>) -> Background
    @EnvironmentObject private var headerModel: HeaderModel<Tab>
    @Namespace private var animationNamespace
    
    var body: some View {
        VStack(spacing: 0) {
            makeTitleView()
                .frame(height: context.rubberBandingTitleHeight)
            makeTabBarView()
        }
        .frame(maxWidth: .infinity)
        .background(alignment: .bottom) {
            background(context)
                .ignoresSafeArea(edges: .top)
                .frame(height: context.rubberBandingBackgroundHeight)
            // Clip for image backgrounds that use aspect fill
                .clipped()
        }
        .offset(CGSize(width: 0, height: -max(headerModel.state.headerContext.offset, 0)))
        .animation(.default, value: context.selectedTab)
        .onChange(of: animationNamespace, initial: true) {
            headerModel.animationNamespaceChanged(animationNamespace)
        }
    }
    
    @ViewBuilder private func makeTitleView() -> some View {
        title(context)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: TitleHeightPreferenceKey.self,
                            value: proxy.size.height
                        )
                }
            }
    }
    
    @ViewBuilder private func makeTabBarView() -> some View {
        tabBar(context)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .preference(
                            key: TabBarHeightPreferenceKey.self,
                            value: proxy.size.height
                        )
                }
            }
    }
}
