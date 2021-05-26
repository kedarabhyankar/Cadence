//
//  ContentView.swift
//  Cadence
//
//  Created by Kedar Abhyankar on 5/22/21.
//

import SwiftUI
import AuthenticationServices

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme : ColorScheme;
    
    var body: some View {
        let title = Text("Cadence")
            .font(.custom("Avenir Next", size: 60))
            .bold()
            .kerning(5.0)
            .foregroundColor(self.colorScheme == .dark ? .blue : .purple).padding()
        let button = SignInWithAppleButton(.signIn, onRequest: configure, onCompletion: handle)
            .signInWithAppleButtonStyle(self.colorScheme == .dark ? .white : .black)
            .frame(height:45)
            .padding()
        if(colorScheme == .dark){
            title.foregroundColor(.blue)
            button.signInWithAppleButtonStyle(.white)
        } else {
            title.foregroundColor(.purple)
            button.signInWithAppleButtonStyle(.black)
        }
    }
    
    func configure(_ req: ASAuthorizationAppleIDRequest){
        req.requestedScopes = [.fullName, .email]
        
    }
    
    func handle(_ res: Result<ASAuthorization, Error>){
        switch res {
            case .success(let auth):
                switch auth.credential {
                    case let appleIDCredentials as ASAuthorizationAppleIDCredential:
                        if let user = User(cred: appleIDCredentials){
                            let userData = try? JSONEncoder().encode(user);
                            UserDefaults.standard.setValue(userData, forKey: user.userID);
                            
                        }
                    default:
                        print(auth.credential as! String + " err")
                }
            case .failure(let err):
                print(err);
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 12 Pro")
    }
}

