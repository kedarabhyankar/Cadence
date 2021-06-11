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

struct CredentialLoginScreen : View {
    
    @Environment(\.colorScheme) var colorScheme : ColorScheme
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var isEditing = false
    @State private var loggedIn = false
    
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
                async { await handleLogin(email: emailAddress, password: password) }
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
                    NavigationLink(destination: Home(), isActive: $loggedIn){
                    EmptyView()
                })
        }
    }
    
    @MainActor func displayFailureBannerWithMessage(message: String, queue : NotificationBannerQueue){
        let banner = FloatingNotificationBanner(title: "Failure!", subtitle: message, style: .danger)
        banner.bannerQueue.dismissAllForced()
        banner.haptic = .medium
        banner.show(queue: queue)
    }
    
    @MainActor func displaySuccessBannerWithMessage(message: String, queue: NotificationBannerQueue){
        let banner = FloatingNotificationBanner(title: "Success!", subtitle: message, style: .success)
        banner.bannerQueue.dismissAllForced()
        banner.haptic = .medium
        banner.show(queue: queue)
    }
    
    func handleLogin(email: String, password: String) async {
        let bannerQueue = NotificationBannerQueue.init(maxBannersOnScreenSimultaneously: 1)
        do {
            try await Auth.auth().signIn(withEmail: email, password: password)
            await displaySuccessBannerWithMessage(message: "Logged in!", queue: bannerQueue)
            loggedIn = true
        } catch {
            switch AuthErrorCode(rawValue: (error as NSError).code){
                case .operationNotAllowed:
                    await displayFailureBannerWithMessage(message: "Email and Password support is not enabled in the app!", queue: bannerQueue)
                    loggedIn = false
                case .userDisabled:
                    await displayFailureBannerWithMessage(message: "Your Account has been disabled. Contact us through help!", queue: bannerQueue)
                    loggedIn = false
                case .wrongPassword:
                    await displayFailureBannerWithMessage(message: "Incorrect Password", queue: bannerQueue)
                    loggedIn = false
                case .invalidEmail:
                    await displayFailureBannerWithMessage(message: "Your email address is in the wrong format!", queue: bannerQueue)
                    loggedIn = false
                default:
                    await displayFailureBannerWithMessage(message: "An unknown error occurred.", queue: bannerQueue)
                    loggedIn = false
            }
        }
    }
}
