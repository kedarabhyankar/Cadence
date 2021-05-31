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
    
    //TODO -> Verify data in screen, push to firebase if valid and button pressed
    //Toggle from Light to Dark causes scene change
    //Email recommendation? Why isn't it working? DONE
    @Environment(\.colorScheme) var colorScheme : ColorScheme;
    @State private var firstName : String = ""
    @State private var lastName : String = ""
    @State private var emailAddress: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isEditing = false
    @State private var loggedIn = false
    @State private var keyboardHeight: CGFloat = 0
    static let baseURL = URL(string: "https://kedarabhyankar.me")
    
    var body : some View {
        ScrollView{
            VStack {
                HStack {
                    Spacer().frame(width: 10)
                    Text("Sign up with Email").font(.title)
                    Spacer().frame(width: 10)
                    Image(systemName: "envelope").resizable().aspectRatio(contentMode: .fill).frame(width: 20, height: 20)
                    Spacer()
                }
            }
            VStack {
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
                            let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "You can't have numbers in your first name!", style: .danger)
                            banner.haptic = .medium
                            banner.show()
                        } else if(firstName.rangeOfCharacter(from: .symbols) != nil){
                            //contains symbols
                            let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "You can't have symbols in your first name!", style: .danger)
                            banner.haptic = .medium
                            banner.show()
                        } else {
                            firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .keyboardType(.namePhonePad)
                    .textContentType(.givenName)
                }
            }
            VStack {
                HStack {
                    Spacer().frame(width: 10)
                    Text("Last Name").bold()
                    Spacer()
                }
                HStack {
                    Spacer().frame(width: 10)
                    TextField("Last Name", text: $lastName)
                    { isEditing in
                        self.isEditing = isEditing
                    } onCommit: {
                        if(lastName.isEmpty){
                            //first name is empty
                            let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "You can't have an empty last name!", style: .danger)
                            banner.haptic = .medium
                            banner.show()
                        }
                        else if(lastName.rangeOfCharacter(from: .decimalDigits) != nil){
                            //contains numbers in name
                            let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "You can't have numbers in your last name!", style: .danger)
                            banner.haptic = .medium
                            banner.show()
                        } else if(lastName.rangeOfCharacter(from: .symbols) != nil){
                            //contains symbols
                            let banner = FloatingNotificationBanner(title: "Failure!", subtitle: "You can't have symbols in your last name!", style: .danger)
                            banner.haptic = .medium
                            banner.show()
                        }
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
                    .disableAutocorrection(true)
                    .keyboardType(.namePhonePad)
                    .textContentType(.familyName)
                }
            }
            //            HStack {
            //                Spacer().frame(width: 10)
            //                Text("Password").bold()
            //                Spacer()
            //            }
            //            HStack {
            //                Spacer().frame(width: 10)
            //                SecureField("Password", text: $password)
            //                    .textFieldStyle(RoundedBorderTextFieldStyle())
            //                    .autocapitalization(.none)
            //                    .disableAutocorrection(true)
            //                    .keyboardType(.alphabet)
            //                Spacer()
            //            }
            VStack {
                HStack {
                    Spacer().frame(width: 10)
                    Text("Date of Birth").bold()
                    Spacer()
                }
                HStack {
                    Spacer().frame(width: 10)
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: [.date])
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                }
            }
            
            VStack {
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
                    .textContentType(.emailAddress)
                    Spacer()
                }
            }
            
            VStack {
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
                        .textContentType(.newPassword)
                    Spacer()
                }
            }
            
            VStack {
                HStack {
                    Spacer().frame(width: 10)
                    Text("Confirm Password").bold()
                    Spacer()
                }
                HStack {
                    Spacer().frame(width:10)
                    SecureField("Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .keyboardType(.alphabet)
                        .textContentType(.newPassword)
                    Spacer()
                }
            }
            Button(action: {
                loggedIn = doAppSignUp(firstName: firstName, lastName: lastName, email: emailAddress, password: password)
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
    
    func doAppSignUp(firstName: String, lastName: String, email: String, password: String) -> Bool{
        return true;
    }
}
