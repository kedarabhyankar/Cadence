//
//  CredentialLoginScreen.swift
//  Cadence
//
//  Created by Kedar Abhyankar on 5/25/21.
//

import Foundation
import SwiftUI
import EmailValidator

struct CredentialLoginScreen : View {
    
    @State private var emailAddress: String = ""
    @State private var isEditing = false
    @State private var invalidEmail = false
    var body : some View {
        Text("Sign in with Email")
        VStack{
            Text("Email Address")
            if(invalidEmail){
                Text("Invalid Email Address!").foregroundColor(Color.red)
            }
            TextField(
                "Email Address",
                text: $emailAddress
            ) { isEditing in
                self.isEditing = isEditing
            } onCommit: {
                let isEmailValid = EmailValidator.validate(email: emailAddress)
                if(!isEmailValid){
                    invalidEmail = true
                }
            }
        }
    }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = windows.first else { return }
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}
