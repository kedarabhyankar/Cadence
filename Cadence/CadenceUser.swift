//
//  CadenceUser.swift
//  Cadence
//
//  Created by Kedar Abhyankar on 6/5/21.
//

import Foundation
import AuthenticationServices

class CadenceUser: Codable{
    let userID : String
    let firstName : String
    let lastName : String
    let email : String
    
    init?(cred: ASAuthorizationAppleIDCredential){
        guard
            let first = cred.fullName?.givenName,
            let last = cred.fullName?.familyName,
            let email = cred.email
        else {
            return nil
        }
        self.userID = cred.user
        self.firstName = first
        self.lastName = last
        self.email = email
    }
}
