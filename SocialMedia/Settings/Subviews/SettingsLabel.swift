//
//  SettingsLabel.swift
//  SocialMedia
//

import SwiftUI

struct SettingsLabel: View {
    let settingsOption: SettingsOption
    
    var body: some View {
        Label(settingsOption.rawValue.capitalized, systemImage: settingsOption.icon)
    }
}

struct SettingsLabel_Previews: PreviewProvider {
    static var previews: some View {
        SettingsLabel(settingsOption: .appColor)
    }
}
