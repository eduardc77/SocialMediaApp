//
//  ImageState.swift
//  SocialMedia
//

import SwiftUI
import PhotosUI

@MainActor
public class ImageData: ObservableObject {
    @Published var image: Image?
    @Published public var imageState: ImageState = .empty
    @Published public var newImageSet: Bool = false
    
    @Published public var imageSelection: PhotosPickerItem? = nil {
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
    
    public enum ImageState {
        case empty
        case loading
        case success(Data)
        case failure(Error)
    }
    
    public init() {}

    func loadTransferable(from imageSelection: PhotosPickerItem) async {
        guard imageSelection == self.imageSelection else {
            print("DEBUG: Failed to get the selected item.")
            return
        }
        imageState = .loading
        
        do {
            if let data = try await imageSelection.loadTransferable(type: Data.self) {
                imageState = .success(data)
#if os(iOS)
                guard let imageData = UIImage(data: data)?.jpegData(compressionQuality: 0.35), let uiImage = UIImage(data: imageData) else { return }
                image = Image(uiImage: uiImage)
#elseif os(macOS)
                guard let imageData = NSImage(data: data)?.jpegData(compressionQuality: 0.35), let nsImage = NSImage(data: imageData) else { return }
                image = Image(nsImage: nsImage)
#endif
                newImageSet = true
            } else {
                imageState = .empty
            }
        } catch {
            imageState = .failure(error)
        }
    }
}

#if os(macOS)
extension NSImage {
    func jpegData(compressionQuality: Double) -> Data? {
        guard let tiff = tiffRepresentation else { return nil }
        guard let imageRep = NSBitmapImageRep(data: tiff) else { return nil }

        let options: [NSBitmapImageRep.PropertyKey: Any] = [
            .compressionFactor: compressionQuality
        ]

        return imageRep.representation(using: .jpeg, properties: options)
    }
}
#endif
