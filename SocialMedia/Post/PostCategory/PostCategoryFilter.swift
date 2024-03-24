//
//  PostCategoryFilter.swift
//  SocialMedia
//

import SwiftUI

struct PostCategoryFilter: View {
    @Binding private var currentFilter: CategoryExploreFilter
    var action: (CategoryExploreFilter) -> Void
    @Namespace var animation
    
    init(filter: Binding<CategoryExploreFilter>, action: @escaping (CategoryExploreFilter) -> Void) {
        _currentFilter = filter
        self.action = action
    }
    
    var body: some View {
        HStack {
            ForEach(CategoryExploreFilter.allCases, id: \.self) { filter in
                Button {
                    withAnimation {
                        currentFilter = filter
                        action(filter)
                    }
                } label: {
                    Text(filter.rawValue.capitalized)
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .foregroundColor(currentFilter == filter ? .tertiaryGroupedBackground : .secondary)
                        .frame(maxWidth: .infinity)
                        .background {
                            if currentFilter == filter {
                                RoundedRectangle(cornerRadius: 8)
                                    .matchedGeometryEffect(id: "CategoryFilter", in: animation)
                            }
                        }
                }
            }
        }
        .padding(4)
        .background(Color.secondaryGroupedBackground, in: .rect(cornerRadius: 8))
        .padding(.horizontal)
        .animation(.default, value: currentFilter)
        .onChange(of: currentFilter) { _, newValue in
            withAnimation {
                action(newValue)
            }
            
        }
    }
}

struct CategoryFilter_Previews: PreviewProvider {
    static var previews: some View {
        PostCategoryFilter(filter: .constant(.hot), action: { _ in })
    }
}
