//
//  PlaceholderText.swift
//  SocialMedia
//

import SwiftUI
import SocialMediaUI

struct PlaceholderText: View {
    let title: SettingsOption
    
    var body: some View {
        ScrollView {
            Text(AboutSocialMedia.lorem)
                .padding()
        }
        .navigationTitle(title.rawValue.capitalized)
    }
}

#Preview {
    NavigationStack {
        PlaceholderText(title: .termsOfUse)
    }
}
