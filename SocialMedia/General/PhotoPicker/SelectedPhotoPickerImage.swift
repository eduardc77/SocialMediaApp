//
//  SelectedPhotoPickerImage.swift
//  SocialMedia
//

import SwiftUI

struct SelectedPhotoPickerImage: View {
    let imageState: ImageData.ImageState
    var size: ImageSize = .large
    var contentMode: ContentMode = .fit
    
    var body: some View {
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
