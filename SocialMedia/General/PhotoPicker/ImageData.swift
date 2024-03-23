//
//  ImageState.swift
//  SocialMedia
//

import SwiftUI
import PhotosUI

@MainActor
class ImageData: ObservableObject {
    
    enum ImageState {
        case empty
        case loading
        case success(UIImage)
        case failure(Error)
    }

    @Published var image: Image?
    @Published var imageState: ImageState = .empty
    @Published var newImageSet: Bool = false
    
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                Task {
                    await loadTransferable(from: imageSelection)
                }
            } else {
                imageState = .empty
            }
        }
    }
    
    func loadTransferable(from imageSelection: PhotosPickerItem) async {
        guard imageSelection == self.imageSelection else {
            print("Failed to get the selected item.")
            return
        }
        imageState = .loading
        
        do {
            if let data = try await imageSelection.loadTransferable(type: Data.self) {
                guard let uiImage = UIImage(data: data) else { return }
                imageState = .success(uiImage)
                image = Image(uiImage: uiImage)
                newImageSet = true
            } else {
                imageState = .empty
            }
        } catch {
            imageState = .failure(error)
        }
    }
}
