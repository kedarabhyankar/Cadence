//
//  CredentialSignupScreen.swift
//  Cadence
//
//  Created by Kedar Abhyankar on 5/26/21.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import NotificationBannerSwift
import EmailValidator

struct CredentialSignupScreen : View {
    
    @Environment(\.colorScheme) var colorScheme : ColorScheme;
    @State private var firstName : String = ""
    @State private var emailAddress: String = ""
    @State private var password: String = ""
    @State private var isEditing = false
    @State private var loggedIn = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body : some View {
        VStack {
            HStack {
                Spacer().frame(width: 10)
                Text("Sign up with Email").font(.title)
                Spacer().frame(width: 10)
                Image(systemName: "envelope").resizable().aspectRatio(contentMode: .fill).frame(width: 20, height: 20)
                Spacer()
            }
            HStack {
                Spacer().frame(width: 10)
                Text("First Name").bold()
                Spacer()
            }
            HStack {
                Spacer().frame(width: 10)
                TextField("First Name", text: $firstName)
                { isEditing in
                    self.isEditing = isEditing
                } onCommit: {
                    if(firstName.isEmpty){
                        //first name is empty
                        let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "You can't have an empty first name!", style: .danger)
                        banner.haptic = .medium
                        banner.show()
                    }
                    else if(firstName.rangeOfCharacter(from: .decimalDigits) != nil){
                        //contains numbers in name
                        let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "You can't have numbers in your name!", style: .danger)
                        banner.haptic = .medium
                        banner.show()
                    } else if(firstName.rangeOfCharacter(from: .symbols) != nil){
                        //contains symbols
                        let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "You can't have symbols in your name!", style: .danger)
                        banner.haptic = .medium
                        banner.show()
                    }
                }
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
        }
    }
}
