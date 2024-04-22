//
//  FeedbackView.swift
//  SocialMedia
//

import SwiftUI

struct FeedbackView: View {
    @State private var email = ""
    @State private var message = ""
    
    @FocusState private var focusedField: FeedbackField?
    
    var body: some View {
        Form {
            Section {
                EmptyView()
            } footer: {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Help Improve SocialMedia app")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("You can share your inquire, suggestion, complaint, or other.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Section {
                TextField("Email", text: $email, prompt: Text("Email (Optional)"), axis: .vertical)
                    .focused($focusedField, equals: .email)
#if os(iOS)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
#endif
                
#if DEBUG
                    .autocorrectionDisabled()
#endif
            }
            
            Section {
                TextField("Message", text: $message, prompt: Text("Write your message..."), axis: .vertical)
                    .focused($focusedField, equals: .message)
                    .lineLimit(10, reservesSpace: true)
#if DEBUG
                    .autocorrectionDisabled()
#endif
#if os(iOS)
                    .textInputAutocapitalization(.sentences)
#endif
            }
        }
        .formStyle(.grouped)
        .onTapGesture {
            focusedField = nil
        }
        .navigationTitle("Feedback")
        .background(Color.groupedBackground)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    email = ""
                    message = ""
                } label: {
                    Image(systemName: SettingsOption.feedback.icon)
                }
            }
        }
    }
    
    private enum FeedbackField {
        case email
        case message
    }
}

#Preview {
    NavigationStack {
        FeedbackView()
    }
}
