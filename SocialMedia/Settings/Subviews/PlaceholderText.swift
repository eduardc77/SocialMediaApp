//
//  PlaceholderText.swift
//  SocialMedia
//

import SwiftUI

struct PlaceholderText: View {
    let title: SettingsOption
    
    var body: some View {
        ScrollView {
            Text(AboutSocialMedia.lorem)
                .padding()
        }
        .navigationBar(title: title.rawValue.capitalized)
    }
}

struct LoremText_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PlaceholderText(title: .termsOfUse)
        }
    }
}
