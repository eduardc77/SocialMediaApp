//
//  SettingsLabel.swift
//  SocialMedia
//

import SwiftUI

struct SettingsLabel: View {
    let settingsOption: SettingsOption
    
    var body: some View {
        Label(settingsOption.rawValue.capitalized, systemImage: settingsOption.icon)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

#Preview {
    SettingsLabel(settingsOption: .appColor)
}
