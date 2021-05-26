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
import NotificationBannerSwift

var loginState = false
var loginMessage = ""
var bannerDisplayed = false
var transferredViewToLogin = false
var emptyFields = false
var successfulLogin = false


struct CredentialLoginScreen : View {
    
    @Environment(\.colorScheme) var colorScheme : ColorScheme
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var isEditing = false
    @State private var loginState = false
    
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
            Spacer()
        }.padding()
        HStack {
            Spacer().frame(width: 30)
            TextField("Email Address", text: $emailAddress)
            { isEditing in
                self.isEditing = isEditing
            } onCommit: {
                if(!emailAddress.isEmpty){
                    if(!EmailValidator.validate(email: emailAddress))
                    {
                        let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "Your email address is in the wrong format!", style: .danger)
                        banner.bannerQueue.dismissAllForced()
                        banner.haptic = .medium
                    }
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
            Spacer()
        }.padding()
        HStack {
            Spacer().frame(width: 30)
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .keyboardType(.alphabet)
            Spacer()
        }
        
        //        if(emailAddress.isEmpty){
        //            let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "Your email address cannot be empty!", style: .danger)
        //            banner.haptic = .medium
        //            banner.show()
        //            emptyFields = true
        //        } else if(password.isEmpty){
        //            let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "Your password cannot be empty!", style: .danger)
        //            banner.haptic = .medium
        //            banner.show()
        //            emptyFields = true
        //        } else {
        //            emptyFields = false
        //        }
        
        Button(action: {
            self.loginState = doAppLogin(email: emailAddress, password: password)
        }, label: {
            HStack {
                Image(systemName: "arrow.right.square")
                Text("Login")
                    .bold()
                    .font(.system(size: 17))
            }
            .frame(minWidth: 0, idealWidth: 360, maxWidth: 360, minHeight: 0, idealHeight: 45, maxHeight: 45, alignment: .center)
            .padding(.vertical, 0)
            .padding(.horizontal, 0)
            .background(self.colorScheme == .dark ? Color.white : Color.black)
            .foregroundColor(self.colorScheme == .dark ? Color.black : Color.white)
            .cornerRadius(8)
        })
        
        Spacer().frame(height: 300)
            .background(
                    NavigationLink(destination: Home(),
                                   isActive: $loginState){
                        //nothing here
                    }
            )
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
    public func
    gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                      shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}

func doAppLogin(email: String, password: String) -> Bool {
    let bqueue = NotificationBannerQueue.init(maxBannersOnScreenSimultaneously: 1)
    handleLogin(email: email, password: password)
    while(UserDefaults.standard.bool(forKey: "asyncSignIn") == true){
        //still in sign in flow, this is scuffed
        print("waiting...")
    }
    if(loginState == true){
        //logged in successfully
        let banner =
            FloatingNotificationBanner(title: "Success!", subtitle: "Logged In!", style: .success)
        banner.bannerQueue.dismissAllForced()
        banner.haptic = .medium
        banner.show(queue: bqueue)
        return true
    } else {
        //didn't log in successfully, what happened?
        if(loginMessage == "NotEnabled"){
            let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "Email and Password support is not enabled in the app!", style: .danger)
            banner.bannerQueue.dismissAllForced()
            banner.haptic = .medium
            banner.show(queue: bqueue)
        } else if(loginMessage == "UserDisabled"){
            let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "Your Account has been disabled. Contact us through help!", style: .danger)
            banner.bannerQueue.dismissAllForced()
            banner.haptic = .medium
            banner.show(queue: bqueue)
        } else if(loginMessage == "WrongPassword"){
            let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "Incorrect Password", style: .danger)
            banner.bannerQueue.dismissAllForced()
            banner.haptic = .medium
            banner.show(queue: bqueue)
        } else if(loginMessage == "MalformedEmail"){
            let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "Your email address is in the wrong format!", style: .danger)
            banner.bannerQueue.dismissAllForced()
            banner.haptic = .medium
            banner.show(queue: bqueue)
        } else if(loginMessage == "UnknownError"){
            let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "An unknown error occurred.", style: .danger)
            banner.bannerQueue.dismissAllForced()
            banner.haptic = .medium
            banner.show(queue: bqueue)
        }
        return false
    }
}

func handleLogin(email: String, password: String){
    UserDefaults.standard.setValue(true, forKey: "asyncSignIn")
    let bqueue = NotificationBannerQueue.init(maxBannersOnScreenSimultaneously: 1)
    Auth.auth().signIn(withEmail: email, password: password, completion: {
        (authResult, error)  in
        if let err = error as NSError? {
            switch AuthErrorCode(rawValue: err.code){
                case .operationNotAllowed:
                    loginState = false
                    loginMessage = "NotEnabled"
                    if(!bannerDisplayed){
                        let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "Email and Password support is not enabled in the app!", style: .danger)
                        banner.bannerQueue.dismissAllForced()
                        banner.haptic = .medium
                        banner.show(queue: bqueue)
                        bannerDisplayed = true
                    }
                case .userDisabled:
                    loginState = false
                    loginMessage = "UserDisabled"
                    if(!bannerDisplayed){
                        let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "Your Account has been disabled. Contact us through help!", style: .danger)
                        banner.bannerQueue.dismissAllForced()
                        banner.haptic = .medium
                        banner.show(queue: bqueue)
                        bannerDisplayed = true
                    }
                case .wrongPassword:
                    loginState = false
                    loginMessage = "WrongPassword"
                    if(!bannerDisplayed){
                        let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "Incorrect Password", style: .danger)
                        banner.bannerQueue.dismissAllForced()
                        banner.haptic = .medium
                        banner.show(queue: bqueue)
                        bannerDisplayed = true
                    }
                case .invalidEmail:
                    //shouldn't happen bc of emailvalidator pod
                    loginState = false
                    loginMessage = "MalformedEmail"
                    if(!bannerDisplayed){
                        let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "Your email address is in the wrong format!", style: .danger)
                        banner.bannerQueue.dismissAllForced()
                        banner.haptic = .medium
                        banner.show(queue: bqueue)
                        bannerDisplayed = true
                    }
                default:
                    loginState = false
                    loginMessage = "UnknownError"
                    if(!bannerDisplayed){
                        let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "An unknown error occurred.", style: .danger)
                        banner.bannerQueue.dismissAllForced()
                        banner.haptic = .medium
                        banner.show(queue: bqueue)
                        bannerDisplayed = true
                    }
            }
        } else {
            loginState = true
            loginMessage = "Success"
            if(!bannerDisplayed){
                let banner =
                    FloatingNotificationBanner(title: "Success!", subtitle: "Logged In!", style: .success)
                banner.bannerQueue.dismissAllForced()
                banner.haptic = .medium
                banner.show(queue: bqueue)
                bannerDisplayed = true
                transferredViewToLogin = true
                print("pre")
                Home().transition(.slide).animation(.easeIn)
                print("post")
            }
        }
    })
    UserDefaults.standard.setValue(false, forKey: "asyncSignIn")
}
