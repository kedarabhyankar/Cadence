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
    
    var body : some View {
        Text("Verify Screen")
    }
}
