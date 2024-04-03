/*
 See the LICENSE.txt file for this sample’s licensing information.
 
 Abstract:
 The grid view used in the DonutGallery.
 */

import SwiftUI
import SocialMediaNetwork

struct SearchGrid: View {
    var router: any Router
    var users: [User]
    var width: Double
    
    var followedIndex: Int = 0
    var isLoading: Bool = false
    var followAction: ((User) -> Void)?
    
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
            ForEach(Array(users.enumerated()), id: \.offset) { index, user in
                VStack {
                    NavigationLink {
                        SearchGridItem(user: user, thumbnailSize: thumbnailSize)
                    } action: {
                        router.push(user)
                    }
                    if let followAction = followAction {
                        Button {
                            withAnimation {
                                followAction(user)
                            }
                        } label: {
                            Text(user.isFollowed ? "Following" : "Follow")
                                .font(.subheadline)
                        }
                        .buttonStyle(.borderedProminent)
                        .overlay {
                            if followedIndex == index && isLoading {
                                ProgressView()
                            }
                        }
                        .disabled(followedIndex == index && isLoading)
                    }
                }
            }
        }
        .padding()
    }
}

//struct DonutGalleryGrid_Previews: PreviewProvider {
//    struct Preview: View {
//        @State private var donuts = Donut.all
//
//        var body: some View {
//            GeometryReader { geometryProxy in
//                ScrollView {
//                    DonutGalleryGrid(donuts: donuts, width: geometryProxy.size.width)
//                }
//            }
//        }
//    }
//
//    static var previews: some View {
//        Preview()
//    }
//}



//struct UserListView: View {
//    @ObservedObject var model: SearchViewModel
//
//    var body: some View {
//        ScrollView {
//            LazyVStack {
//                ForEach(model.filteredUsers) { user in
//                    NavigationLink(value: user) {
//                        UserRow(model: model, user: user)
//                            .padding(.leading)
//                    }
//                }
//            }
//            .navigationTitle("Search")
//            .padding(.top)
//        }
//#if os(iOS)
//        .searchable(text: $model.searchText, placement: .navigationBarDrawer)
//#elseif os(macOS)
//        .searchable(text: $model.searchText, placement: .automatic)
//#endif
//        .background(Color.groupedBackground)
//    }
//}
//
//struct UserListView_Previews: PreviewProvider {
//    static var previews: some View {
//        UserListView(model: SearchViewModel())
//    }
//}
