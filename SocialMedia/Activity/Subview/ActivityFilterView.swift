//
//  ActivityFilterView.swift
//  SocialMedia
//

import SwiftUI


struct ActivityFilterView: View {
    @Binding var selectedFilter: ActivityFilter
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(ActivityFilter.allCases) { filter in
                        activityFilterItem(for: filter, proxy: proxy)
                            .id(filter)
                    }
                }
                .padding(.horizontal)
                .background(Color.groupedBackground)
            }
        }
    }
    
    @ViewBuilder
    func activityFilterItem(for filter: ActivityFilter, proxy: ScrollViewProxy) -> some View {
       Button(action: {
           withAnimation(.interactiveSpring(response: 0.3, dampingFraction: 0.8, blendDuration: 0.8)) {
               selectedFilter = filter
           }
           withAnimation {
              proxy.scrollTo(filter, anchor: .center)
           }
       }) {
           Text(filter.title)
               .foregroundStyle(filter == selectedFilter ? Color.secondaryGroupedBackground : Color.primary)
               .font(.subheadline)
               .fontWeight(.semibold)
               .frame(width: 100)
               .padding(.vertical, 8)
               
               .overlay {
                   RoundedRectangle(cornerRadius: 8)
                       .stroke(Color.secondary, lineWidth: 1)
               }
               .background(filter == selectedFilter ? Color.primary : Color.groupedBackground)
               .clipShape(RoundedRectangle(cornerRadius: 8))
       }
    }

}

#Preview {
    struct Example: View {
        @State var selection: ActivityFilter = .all
        
        var body: some View {
            ActivityFilterView(selectedFilter: $selection)
        }
    }
    return Example()
}
