//
//  CredentialLoginScreen.swift
//  Cadence
//
//  Created by Kedar Abhyankar on 5/25/21.
//

import Foundation
import SwiftUI
import EmailValidator
import FirebaseAuth

struct CredentialLoginScreen : View {
    
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var isEditing = false
    @State private var invalidEmail = false
    @State private var invalidPassword = false
    
    var body : some View {
        HStack {
            //            VStack {
            //                Spacer()
            //            }
            Text("Sign in with Email").font(.title)
            Spacer()
        }.padding()
        HStack {
            Text("Email Address").bold()
            if(invalidEmail){
                Text("Invalid Email Address!").foregroundColor(Color.red)
            }
            Spacer()
        }.padding()
        HStack {
            Spacer().frame(width: 30)
            TextField("Email Address", text: $emailAddress)
            { isEditing in
                self.isEditing = isEditing
            } onCommit: {
                if(!emailAddress.isEmpty){
                    let isEmailValid = EmailValidator.validate(email: emailAddress)
                    if(!isEmailValid){
                        invalidEmail = true
                    }
                } else {
                    invalidEmail = false
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .keyboardType(.emailAddress)
            Spacer()
        }
        HStack {
            Text("Password").bold()
            if(invalidPassword){
                Text("Incorrect Password!").foregroundColor(Color.red)
            }
            Spacer()
        }.padding()
        HStack {
            Spacer().frame(width: 30)
            SecureField("Password", text: $password)
            {
                let loginRes = handleLogin(email: emailAddress, password: password)
                let loginState = loginRes.state
                let loginMessage = loginRes.message
                if(loginState == true){
                    //logged in successfully
                } else {
                    //didn't log in successfully, what happened?
                    
                }
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Spacer()
        }
        Spacer().frame(height: 200)
        //        Text("Sign in with Email").font(.title)
        //        VStack{
        //            HStack{
        //                Text("Email Address").frame(alignment: .leading)
        //                if(invalidEmail){
        //                    Text("Invalid Email Address!").foregroundColor(Color.red)
        //                }
        //            }
        //            TextField(
        //                "Email Address",
        //                text: $emailAddress
        //            ) { isEditing in
        //                self.isEditing = isEditing
        //            } onCommit: {
        //                let isEmailValid = EmailValidator.validate(email: emailAddress)
        //                if(!isEmailValid){
        //                    invalidEmail = true
        //                }
        //            }
        //            Spacer().frame(minWidth: 0, idealWidth: 0, maxWidth: 0, minHeight: 100, idealHeight: 100, maxHeight: 100, alignment: .center)
    }
}
//}

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

func handleLogin(email: String, password: String) -> (state: Bool, message: String) {
    var state = false
    var message = ""
    Auth.auth().signIn(withEmail: email, password: password){ (authResult, error) in
        if let err = error as NSError? {
            switch AuthErrorCode(rawValue: err.code){
                case .operationNotAllowed:
                    state = false
                    message = "NotEnabled"
                case .userDisabled:
                    state = false
                    message = "UserDisabled"
                case .wrongPassword:
                    state = false
                    message = "WrongPassword"
                case .invalidEmail:
                    //shouldn't happen bc of emailvalidator pod
                    state = false
                    message = "MalformedEmail"
                default:
                    state = false
                    message = "UnknownError"
            }
        } else {
            state = true
            message = "Success"
        }
    }
    return (state, message)
}
