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
import Navajo_Swift

struct CredentialSignupScreen : View {
    
    //TODO -> Verify email
    //TODO -> Double Notification Showing up? Due to Async?
    //TODO -> Get DOB and push collection to firestore
    @Environment(\.colorScheme) var colorScheme : ColorScheme;
    @State private var firstName : String = ""
    @State private var lastName : String = ""
    @State private var emailAddress: String = ""
    @State private var dateOfBirth: Date = Date()
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var isEditing = false
    @State private var loggedIn = false
    @State var dpIdentifier = 1
    let bannerQueue = NotificationBannerQueue(maxBannersOnScreenSimultaneously: 1)
    var dateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -101, to: Date())!
        let max = Calendar.current.date(byAdding: .year, value: -13, to: Date())!
        return min...max
    }
    
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
            VStack {
                HStack {
                    Spacer().frame(width: 10)
                    Text("Date of Birth").bold()
                    Spacer()
                }
                HStack {
                    Spacer().frame(width: 10)
                    DatePicker("Date of Birth", selection: $dateOfBirth, in: dateRange, displayedComponents: [.date])
                        .datePickerStyle(WheelDatePickerStyle())
                        .labelsHidden()
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                        .id(dpIdentifier)
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
                async { await doAppSignUp(firstName: firstName, lastName: lastName, email: emailAddress, password: password)}
                isPasswordStrongEnough(password: $password.wrappedValue)
                doPasswordsMatch(password: $password.wrappedValue, confPassword: $confirmPassword.wrappedValue)
            }, label: {
                HStack {
                    Image(systemName: "arrow.right.square")
                    Text("Create Account")
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
                    NavigationLink(destination: VerifyEmailAddressView(firstName: $firstName, lastName: $lastName, emailAddress: $emailAddress), isActive: $loggedIn){
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
    
    func doAppSignUp(firstName: String, lastName: String, email: String, password: String) async {
        do {
            try await Auth.auth().createUser(withEmail: email, password: password)
            await displaySuccessBannerWithMessage(message: "Signed Up!", queue: bannerQueue)
            loggedIn = true
        } catch {
            switch AuthErrorCode(rawValue: (error as NSError).code) {
                case .operationNotAllowed:
                    await displayFailureBannerWithMessage(message: "Email and Password support is not enabled in the app!", queue: bannerQueue)
                    loggedIn = false
                case .emailAlreadyInUse:
                    await displayFailureBannerWithMessage(message: "The given email address is already in use. Maybe you meant to sign in?", queue: bannerQueue)
                    loggedIn = false
                case .invalidEmail:
                    await displayFailureBannerWithMessage(message: "Your email address is in the wrong format!", queue: bannerQueue)
                    loggedIn = false
                case .weakPassword:
                    //don't show since rule validation done separately
                    loggedIn = false
                default:
                    await displayFailureBannerWithMessage(message: "An unknown error occurred!", queue: bannerQueue)
                    loggedIn = false
            }
            
        }
    }
    
    @MainActor func doPasswordsMatch(password: String, confPassword: String) {
        loggedIn = !password.isEmpty && !confPassword.isEmpty && password == confPassword
    }
    
    @MainActor func isPasswordStrongEnough(password: String) {
        if(password.count == 0){
            //empty password
            displayFailureBannerWithMessage(message: "Your password can't be empty!", queue: bannerQueue)
            loggedIn = false
        }
        let minLength = 6
        let maxLength = 20
        let lengthRule = LengthRule(min: 6, max: 20)
        let uppercaseRule = RequiredCharacterRule(preset: .uppercaseCharacter)
        let lowercaseRule = RequiredCharacterRule(preset: .lowercaseCharacter)
        let symbolRule = RequiredCharacterRule(preset: .symbolCharacter)
        let digitRule = RequiredCharacterRule(preset: .decimalDigitCharacter)
        
        let validator = PasswordValidator(rules: [lengthRule, uppercaseRule, lowercaseRule, symbolRule, digitRule])
        
        if let failingRules = validator.validate(password){
            let resMap = failingRules.map({return $0.localizedErrorDescription})
            let firstResult = resMap.first
            if(firstResult == "Must be within range \(minLength) - \(maxLength)"){
                //password length not valid
                displayFailureBannerWithMessage(message: "Your password must have between 6 and 20 characters!", queue: bannerQueue)
                loggedIn = false
            } else if(firstResult == "Must include uppercase characters"){
                //password doesn't have uppercase characters
                displayFailureBannerWithMessage(message: "Your password must have at least one uppercase character!", queue: bannerQueue)
                loggedIn = false
            } else if(firstResult == "Must include lowercase characters"){
                //password doesn't have lowercase characters
                displayFailureBannerWithMessage(message: "Your password must have at least one lowercase character!", queue: bannerQueue)
                loggedIn = false
            } else if(firstResult == "Must include symbol characters"){
                //password doesn't have symbols
                displayFailureBannerWithMessage(message: "Your password must have at least one symbol!", queue: bannerQueue)
                loggedIn = false
            } else if(firstResult == "Must include decimal digit characters"){
                //password doesn't have numbers
                displayFailureBannerWithMessage(message: "Your password must have at least one number!", queue: bannerQueue)
                loggedIn = false
            } else {
                print("PASS ERR: \(firstResult!)") //map always has at least one element bc of if let
                displayFailureBannerWithMessage(message: "Unknown Password Error!", queue: bannerQueue)
                loggedIn = false
            }
        } else {
            print("PASSWORD SUCESS")
            loggedIn = true
        }
    }
}
