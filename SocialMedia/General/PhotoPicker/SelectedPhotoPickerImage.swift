//
//  SelectedPhotoPickerImage.swift
//  SocialMedia
//

import SwiftUI

struct SelectedPhotoPickerImage: View {
    let imageState: ImageData.ImageState
    var size: ImageSize = .large
    
    var body: some View {
        Group {
            switch imageState {
            case .success(let image):
                Image(uiImage: image)
                    .resizable()
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
