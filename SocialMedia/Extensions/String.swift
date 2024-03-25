//
//  String.swift
//  SocialMedia
//

import SwiftUI

extension String {
#if os(iOS)
   func sizeUsingFont(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
#elseif os(macOS)
    func sizeUsingFont(usingFont font: NSFont) -> CGSize {
         let fontAttributes = [NSAttributedString.Key.font: font]
         return self.size(withAttributes: fontAttributes)
     }
#endif
}
