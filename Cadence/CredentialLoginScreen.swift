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
import Combine

var loginState = false
var loginMessage = ""
var bannerDisplayed = false
var transferredViewToLogin = false
var emptyFields = false
var successfulLogin = false

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

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

extension Publishers {
    // 1.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
    }
}

struct CredentialLoginScreen : View {
    
    @Environment(\.colorScheme) var colorScheme : ColorScheme
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var isEditing = false
    @State private var loggedIn = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body : some View {
        VStack{
//            Spacer().frame(height: 50)
            HStack {
                Spacer().frame(width: 10)
                Text("Sign in with Email").font(.title)
                Spacer().frame(width: 10)
                Image(systemName: "envelope").resizable().aspectRatio(contentMode: .fill).frame(width: 20, height: 20)
                Spacer()
            }
            HStack {
                Spacer().frame(width: 10)
                Text("Email Address").bold()
                Spacer()
            }
            HStack {
                Spacer().frame(width: 10)
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
                Spacer().frame(width: 10)
                Text("Password").bold()
                Spacer()
            }
            HStack {
                Spacer().frame(width: 10)
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .keyboardType(.alphabet)
                Spacer()
            }
            Button(action: {
                loggedIn = doAppLogin(email: emailAddress, password: password)
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
            .background(
                NavigationLink(destination: Home(),
                               isActive: $loggedIn){
                    EmptyView()
                }
            )
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
                    loggedIn = true
                }
            }
        })
        UserDefaults.standard.setValue(false, forKey: "asyncSignIn")
    }
}
