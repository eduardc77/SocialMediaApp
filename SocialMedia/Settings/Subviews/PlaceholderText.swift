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

#Preview {
    NavigationStack {
        PlaceholderText(title: .termsOfUse)
    }
}
