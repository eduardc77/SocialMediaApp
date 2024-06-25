
import SwiftUI

/// A view that asynchronously loads and displays an image.
public struct AsyncImageView<Content: View>: View where Content: View {
    
    /// This view uses the shared URLSession instance to load an image from the specified URL.
    private let url: URL
    
    /// Default is none which leaves the size nil to maintain the current size of the image.
    /// Using custom you can omit either width or height leaving it nil for the auto sizing.
    private let size: ImageSize
    
    /// The placeholder view displayed when the image is loading or has failed to load .
    private let placeholder: () -> Content?
    
    /// The ratio of width to height to use for the resulting view. Use nil to maintain the current aspect ratio in the resulting view.
    private var aspectRatio: CGFloat?
    
    /// A flag that indicates whether this view fits or fills the parent context.
    private let contentMode: ContentMode
    
    /// The scale to use for the image. The default is 1.
    private let scale: CGFloat
    
    /// The transaction to use when the phase changes. Use a transaction to pass an animation between views in a view hierarchy.
    private let transaction: Transaction
    
    public init(url: URL,
                size: ImageSize = .none,
                @ViewBuilder placeholder: @escaping () -> Content? = { Rectangle().fill(.gray.opacity(0.5)) },
                aspectRatio: CGFloat? = nil,
                contentMode: ContentMode = .fill,
                scale: CGFloat = 1,
                transaction: Transaction = Transaction()
    ) {
        self.url = url
        self.size = size
        self.placeholder = placeholder
        self.contentMode = contentMode
        
        self.scale = scale
        self.transaction = transaction
    }
    
    public var body: some View {
        CachedAsyncImage(
            url: url
        ) { phase in
            switch phase {
            case .empty:
                placeholderView
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(aspectRatio, contentMode: contentMode)
                    .frame(maxWidth: size.value.width, maxHeight: size.value.height)
            case .failure:
                placeholderView
            @unknown default:
                fatalError()
            }
        }
    }
    
    private var placeholderView: some View {
        placeholder()
            .aspectRatio(aspectRatio, contentMode: contentMode)
            .frame(maxWidth: size.value.width, maxHeight: size.value.height)
            .shimmering()
    }
}

#Preview {
    AsyncImageView(url: URL(string: "https://docs-assets.developer.apple.com/published/9c4143a9a48a080f153278c9732c03e7/Image-1~dark@2x.png")!, size: .medium)
}
