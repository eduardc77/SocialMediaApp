//
//  SelectedPhotoPickerImage.swift
//  SocialMedia
//

import SwiftUI

public struct SelectedPhotoPickerImage: View {
    private let imageState: ImageData.ImageState
    private var size: ImageSize
    private var contentMode: ContentMode
    
    public init(imageState: ImageData.ImageState, size: ImageSize = .large, contentMode: ContentMode = .fit) {
        self.imageState = imageState
        self.size = size
        self.contentMode = contentMode
    }
    
    public var body: some View {
        Group {
            switch imageState {
            case .success(let imageData):
#if os(iOS)
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                }
#elseif os(macOS)
                if let uiImage = NSImage(data: imageData) {
                    Image(nsImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: contentMode)
                }
#endif
            case .loading:
                ProgressView()
            case .empty:
                EmptyView()
            case .failure:
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
        }
        .frame(maxWidth: size.value.width, maxHeight: size.value.height)
    }
}
