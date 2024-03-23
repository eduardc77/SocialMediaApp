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
            }
            
            Section {
                TextField("Email", text: $email, prompt: Text("Email (Optional)"), axis: .vertical)
                    .focused($focusedField, equals: .email)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
            }
            
            Section {
                TextField("Message", text: $message, prompt: Text("Write your message..."), axis: .vertical)
                    .focused($focusedField, equals: .message)
                    .lineLimit(10, reservesSpace: true)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.sentences)
            }
        }
        .onTapGesture {
            focusedField = nil
        }
        .navigationBar(title: "Feedback")
        .background(Color.groupedBackground)
        
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    email = ""
                    message = ""
                } label: {
                    Image(systemName: SettingsOption.feedback.icon + ".fill")
                }
            }
        }
    }
    
    private enum FeedbackField {
        case email
        case message
    }
}

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedbackView()
        }
    }
}