//
//  VerifyEmailAddressView.swift
//  Cadence
//
//  Created by Kedar Abhyankar on 6/5/21.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import NotificationBannerSwift

struct VerifyEmailAddressView : View {
    
    @Binding var firstName : String
    @Binding var lastName : String
    @Binding var emailAddress : String
    @State var emailVerified = false
    let invalidEmailBanner = NotificationBanner(title: "The email you entered was invalid.", subtitle: "Something seems to be wrong with the email address you entered...", style: .danger)
    let unknownErrorBanner = NotificationBanner(title: "Something went wrong!", subtitle: "An unknown error occurred.", style: .danger)
    let successBanner = NotificationBanner(title: "Successfully verified your email!", subtitle: "Thanks for verifying your email. Let's continue.", style: .danger)
    let bannerQueue = NotificationBannerQueue(maxBannersOnScreenSimultaneously: 1)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    
    var body : some View {
        VStack {
            HStack {
                Spacer().frame(width: 10)
                Text("Verify your Email Address").font(.title)
                Spacer().frame(width: 10)
                Image(systemName: "checkmark.seal").resizable().aspectRatio(contentMode: .fill).frame(width: 20, height: 20)
                Spacer()
            }
            Text("You've registered for an account with Cadence - we would like to just verify your email now. Check your inbox for \(emailAddress), for a verification email from us.")
                .font(.system(size: 15))
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .onReceive(timer){
                    refreshCycle in
                    didUserVerifyEmail()
                }
            NavigationLink(destination: Home(), isActive: $emailVerified){
                EmptyView()
            }
        }.onAppear {
            sendVerificationEmail()
        }
    }
    
    func didUserVerifyEmail()  {
        Auth.auth().currentUser?.reload() { (error) in
            if error != nil{
                self.unknownErrorBanner.show(queue: bannerQueue)
                return
            } else {
                emailVerified = Auth.auth().currentUser!.isEmailVerified
                if(self.emailVerified){
                    self.successBanner.show(queue: bannerQueue)
                }
            }
        }
    }
    
    func sendVerificationEmail(){
        Auth.auth().languageCode = "en"
        Auth.auth().currentUser?.sendEmailVerification(){
            (error) in
            if(error != nil){
                let e = AuthErrorCode(rawValue: error!._code)
                switch(e){
                    case .invalidEmail:
                        self.invalidEmailBanner.show(queue: bannerQueue)
                        break
                    default:
                        self.unknownErrorBanner.show(queue: bannerQueue)
                        break
                }
                return
            }
        }
    }
}
