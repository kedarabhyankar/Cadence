//
//  Home.swift
//  Cadence
//
//  Created by Kedar Abhyankar on 5/26/21.
//

import Foundation
import SwiftUI
import Introspect

struct Home : View {
    
    @Environment(\.presentationMode) var presentationMode
    
    var body : some View {
        Text("Home!")
            .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading: Button(""){self.presentationMode.wrappedValue.dismiss()})
    }
}
