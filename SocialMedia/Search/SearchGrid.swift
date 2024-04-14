//
//  SearchGrid.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI
import SocialMediaNetwork

struct SearchGrid: View {
    var router: any Router
    var users: [User]
    var width: Double
    
#if os(iOS)
    @Environment(\.horizontalSizeClass) private var sizeClass
#endif
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var useReducedThumbnailSize: Bool {
#if os(iOS)
        if sizeClass == .compact {
            return true
        }
#endif
        if dynamicTypeSize >= .xxxLarge {
            return true
        }
        
#if os(iOS)
        if width <= 390 {
            return true
        }
#elseif os(macOS)
        if width <= 520 {
            return true
        }
#endif
        
        return false
    }
    
    var cellSize: Double {
        useReducedThumbnailSize ? 100 : 150
    }
    
    var thumbnailSize: Double {
#if os(iOS)
        return useReducedThumbnailSize ? 60 : 100
#else
        return useReducedThumbnailSize ? 40 : 80
#endif
    }
    
    var gridItems: [GridItem] {
        [GridItem(.adaptive(minimum: cellSize), spacing: 20, alignment: .top)]
    }
    
    var body: some View {
        LazyVGrid(columns: gridItems, spacing: 20) {
            ForEach(users, id: \.self) { user in
                VStack {
                    NavigationButton {
                        router.push(user)
                    } label: {
                        SearchGridItem(user: user, thumbnailSize: thumbnailSize)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    SearchGrid(router: SearchViewRouter(), users: [Preview.user, Preview.user2], width: 390)
}
