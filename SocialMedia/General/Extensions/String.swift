//
//  String.swift
//  SocialMedia
//

import SwiftUI

public extension String {
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

public extension String {
    var validEmail: Bool {
        NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
    }
}
