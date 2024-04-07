//
//  FeedFilterView.swift
//  SocialMedia
//

import SwiftUI

struct FeedFilterView: View {
    @Binding var currentFilter: FeedFilter
    @Namespace var animation
    
    var body: some View {
        ZStack(alignment: .bottom) {
            HStack {
                ForEach(FeedFilter.allCases) { filter in
                    feedFilterItem(for: filter)
                        .id(filter)
                        .frame(maxWidth: .infinity)
                }
            }
            Divider()
        }
        .background(.bar)
    }
    
    @ViewBuilder
    func feedFilterItem(for filter: FeedFilter) -> some View {
        Button {
            withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
                currentFilter = filter
            }
        } label: {
            Text(filter.title)
                .font(.footnote.weight(.semibold))
                .padding(.bottom, 8)
                .foregroundStyle(currentFilter == filter ? Color.primary : Color.secondary)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .bottom) {
                    if currentFilter == filter {
                        Rectangle()
                            .fill(.primary)
                            .frame(height: 1.5)
                            .matchedGeometryEffect(id: "FeedFilter", in: animation)
                            .padding(.horizontal)
                    }
                }
        }
    }
}
