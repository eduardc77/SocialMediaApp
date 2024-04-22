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
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.body)
                    } label: {
                        Text(item.question)
                            .font(.title3)
                            .fontWeight(.medium)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .frame(alignment: .leading)
        .navigationTitle("About")
        .background(Color.groupedBackground)
    }
}

#Preview {
    AboutView()
}
