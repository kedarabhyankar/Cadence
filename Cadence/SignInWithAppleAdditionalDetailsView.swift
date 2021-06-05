//
//  SignInWithAppleAdditionalDetailsView.swift
//  Cadence
//
//  Created by Kedar Abhyankar on 5/30/21.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignInWithAppleAdditionalDetailsView : View {
    //TODO if going back from this screen need to delete SIWA request and allow user to resign up if necessary
    
    @Binding var userID: String
    @State var dateOfBirth = Date()
    @State private var refresh = false
    @Environment(\.colorScheme) var colorScheme : ColorScheme;
    @State var dfString: String = ""
    @State var dpIdentifier = 0
    @Environment(\.presentationMode) var presentationMode
    @State var finishedDOBProcess = false
    
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
                    Text("Sign up with Apple").font(.title)
                    Spacer().frame(width: 10)
                    Image(systemName: "applelogo").resizable().aspectRatio(contentMode: .fill).frame(width: 20, height: 20)
                    //might need to not use this based on HID requirements... not sure tho
                    Spacer()
                }
                Spacer()
                    .frame(width: 10)
                    .onAppear(perform: UIApplication.shared.addTapGestureRecognizer)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarItems(leading: Button(""){self.presentationMode.wrappedValue.dismiss()})
                Text("You've signed up with Apple, but we just need a few more details.")
                    .font(.system(size: 15))
                    .multilineTextAlignment(.leading)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                Spacer()
                HStack {
                    Spacer().frame(width: 10)
                    Text("Date of Birth").font(.title2)
                    Spacer()
                }
                DatePicker("_" + (refresh ? "" : " "), selection: $dateOfBirth, in: dateRange, displayedComponents: [.date])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
                    .id(dpIdentifier)
                Spacer()
            }
            Spacer()
            Button(action: {
                let db = Firestore.firestore()
                let docRef = db.collection("Users").document(userID)
                print("DOB \(dateOfBirth)")
                docRef.updateData([
                    "dateOfBirth" : dateOfBirth
                ]) { err in
                    if let err = err {
                        print("Error updating document \(err)")
                    } else {
                        print("Document successfully updated")
                    }
                }
                finishedDOBProcess = true
            }, label: {
                HStack {
                    Image(systemName: "arrow.right.square")
                    Text("Finish Sign Up")
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
                NavigationLink(destination: Home(), isActive: $finishedDOBProcess){
                    EmptyView()
                }
            )
        }
    }
}
