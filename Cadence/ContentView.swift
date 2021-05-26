//
//  ContentView.swift
//  Cadence
//
//  Created by Kedar Abhyankar on 5/22/21.
//

import SwiftUI
import AuthenticationServices
import FirebaseFirestore

struct ContentView: View {
    
    @Environment(\.colorScheme) var colorScheme : ColorScheme;
    @State var showLoginView : Bool = false
    
    var body: some View {
        NavigationView {

        VStack {
            Image(systemName: "music.quarternote.3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:200, height:200)
            let title = Text("Cadence")
                .font(.custom("Avenir Next", size: 60))
                .bold()
                .kerning(5.0)
                .foregroundColor(self.colorScheme == .dark ? .blue : .purple).padding()
                VStack (spacing: 0){
                    let siwabutton = SignInWithAppleButton(.signIn, onRequest: configureSIWA, onCompletion: handleSIWA)
                        .signInWithAppleButtonStyle(self.colorScheme == .dark ? .white : .black)
                        .frame(height:45)
                        .padding()
                    
                    if(colorScheme == .dark){
                        title.foregroundColor(.blue)
                        siwabutton.signInWithAppleButtonStyle(.white)
                    } else {
                        title.foregroundColor(.purple)
                        siwabutton.signInWithAppleButtonStyle(.black)
                    }
                    NavigationLink(destination: CredentialLoginScreen()){
                            HStack {
                                Image(systemName: "mail")
                                Text("Sign in with Email")
                                    .bold()
                                    .font(.system(size: 17))
                            }
                            .frame(minWidth: 0, idealWidth: 360, maxWidth: 360, minHeight: 0, idealHeight: 45, maxHeight: 45, alignment: .center)
                            .padding(.vertical, 0)
                            .padding(.horizontal, 0)
                            .background(self.colorScheme == .dark ? Color.white : Color.black)
                            .foregroundColor(self.colorScheme == .dark ? Color.black : Color.white)
                            .cornerRadius(8)
                        }
                    }
                }
            }
        }
    
    func configureSIWA(_ req: ASAuthorizationAppleIDRequest){
        req.requestedScopes = [.fullName, .email]
    }
    
    func handleSIWA(_ res: Result<ASAuthorization, Error>){
        let db = Firestore.firestore()
        switch res {
            case .success(let auth):
                switch auth.credential {
                    case let appleIDCredentials as ASAuthorizationAppleIDCredential:
                        if let user = User(cred: appleIDCredentials){
                            var ref: DocumentReference? = nil
                            ref = db.collection("Users").addDocument(data: [
                                "firstName" : user.firstName,
                                "lastName" : user.lastName,
                                "email" : user.email,
                                "signInMethod" : "Sign in with Apple"
                            ]) { err in
                                if let err = err {
                                    print("Error adding document \(err)")
                                } else {
                                    print("Document successfully added with ID: \(ref!.documentID)")
                                }
                            }
                        }
                    default:
                        print(auth.credential as! String + " err")
                }
            case .failure( _):
                print("Cancelled Sign In Flow")
        }
    }
    
    func navigateToSignIn(){
        
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 12 Pro")
    }
}

