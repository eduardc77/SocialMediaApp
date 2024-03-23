//
//  AboutView.swift
//  SocialMedia
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        Form {
            ForEach(AboutSocialMedia.about, id: \.self) { item in
                Section {
                    DisclosureGroup {
                        Text(item.answer)
                    } label: {
                        Text(item.question)
                    }
                }
            }
        }
        .navigationBar(title: "About")
        .background(Color.groupedBackground)
    }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
