//
//  ActivityFilterView.swift
//  SocialMedia
//

import SwiftUI

struct ActivityFilterView: View {
    @Binding var currentFilter: ActivityFilter
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ActivityFilter.allCases) { filter in
                        activityFilterItem(for: filter, proxy: proxy)
                            .id(filter)
                    }
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
            }
            .background(.bar)
        }
    }
    
    @ViewBuilder
    private func activityFilterItem(for filter: ActivityFilter, proxy: ScrollViewProxy) -> some View {
        let selected = filter == currentFilter
        Button(action: {
            currentFilter = filter
            withAnimation {
                proxy.scrollTo(filter, anchor: .center)
            }
        }) {
            Text(filter.title)
                .foregroundStyle(selected ? Color.groupedBackground : Color.primary)
                .font(.subheadline)
                .fontWeight(.semibold)
                .frame(width: 100)
                .padding(10)
#if !os(macOS)
                .background(
                    (selected ? Color.primary : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                )
#else
                .background(
                    (selected ? Color.primary : Color.secondary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                )
#endif
            
        }
        .contentShape(.rect)
        .buttonStyle(.borderless)
    }
}

#Preview {
    struct Example: View {
        @State var selection: ActivityFilter = .all
        
        var body: some View {
            ActivityFilterView(currentFilter: $selection)
        }
    }
    return Example()
}
