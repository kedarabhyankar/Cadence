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
    
    @Environment(\.colorScheme) public var colorScheme : ColorScheme;
    @State var showLoginView : Bool = false
    @State var uid = ""
    @State var signedUpWithApple = false
    @State var signedInWithApple = false
    
    var body: some View {
        NavigationView {
            
            ZStack{
                Color.init("backgroundColor").edgesIgnoringSafeArea(.all)
            VStack {
                Image("cadence_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.size.width, height: 200)
                //            let title = Text("cadence")
                //                .font(.custom("Nexa Bold", size: 60))
                //                //                    .bold()
                //                //                    .kerning(5.0)
                //                .foregroundColor(self.colorScheme == .dark ? .blue : .purple).padding()
                Image("cadence_text")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.size.width - 50,  height: 200)
                    .background(
                        NavigationLink(destination:
                                        SignInWithAppleAdditionalDetailsView(userID: $uid, dateOfBirth: Date())
                                        .scaleEffect(),
                                       isActive: $signedUpWithApple){
                            EmptyView()
                        }
                    )
                    .background(
                        NavigationLink(destination: Home(), isActive: $signedInWithApple){
                            EmptyView()
                        }
                    )
                
                    let siwabutton = SignInWithAppleButton(.signIn, onRequest: configureSIWA, onCompletion: handleSIWA)
                        .signInWithAppleButtonStyle(self.colorScheme == .dark ? .white : .black)
                        .frame(height:45)
                        .padding()
                    
                    if(colorScheme == .dark){
                        siwabutton.signInWithAppleButtonStyle(.white)
                    } else {
                        siwabutton.signInWithAppleButtonStyle(.black)
                    }
                    
                    NavigationLink(destination:
                                    CredentialLoginScreen().onAppear(perform: UIApplication.shared.addTapGestureRecognizer)){
                        HStack {
                            Image(systemName: "envelope")
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
                    Spacer().frame(height: 50)
                    NavigationLink(destination:
                                    CredentialSignupScreen().onAppear(perform: UIApplication.shared.addTapGestureRecognizer)){
                        HStack {
                            Image(systemName: "envelope")
                            Text("Create a new account")
                                .bold()
                                .font(.system(size: 17))
                        }
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
                            //signed up
                            var _: DocumentReference? = nil
                            uid = user.email
                            signedUpWithApple = true
                            db.collection("Users").document(user.email).setData([
                                "firstName" : user.firstName,
                                "lastName" : user.lastName,
                                "email" : user.email,
                                "signInMethod" : "Sign in with Apple"
                            ]) { err in
                                if let err = err {
                                    print("Error adding document \(err)")
                                } else {
                                    print("Document successfully added with ID: \(user.email)")
                                    signedUpWithApple = true
                                }
                            }
                        } else {
                            signedInWithApple = true
                        }
                    default:
                        print(auth.credential as! String + " err")
                }
            case .failure( _):
                print("Cancelled Sign In Flow")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPhone 12 Pro")
    }
}

