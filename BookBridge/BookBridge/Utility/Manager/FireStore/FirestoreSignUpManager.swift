//
//  FirestoreSignUpManager.swift
//  BookBridge
//
//  Created by 이민호 on 2/5/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class FirestoreSignUpManager {
    static let shared = FirestoreSignUpManager()
    private init() {}
    let db = Firestore.firestore()
    
    func convertUserModelToDictionary(user: UserModel) -> [String : Any] {
        let userData = [
            "id" : user.id ?? "",  // change these according to you model
            "email": user.email ?? "",
            "password": user.passsword ?? "",
            "nickname": user.nickname ?? "",
            "phoneNumber": user.phoneNumber ?? "",
            "distance": user.distance ?? 1,
            "joinDate": user.joinDate ?? "",
            "dong": user.dong ?? ""
        ] as [String : Any]
        
        return userData as [String : Any]
    }
    
    func convertLocationToDictionary(location: Location) -> [String : Any] {
        let locationData = [
            "id": location.id ?? "",
            "lat": location.lat ?? 37.49235,
            "long": location.long ?? 127.0056634,
        ] as [String : Any]
        
        return locationData as [String : Any]
    }
                
    func addUser(
        id: String,
        email: String,
        password: String,
        nickname: String,
        phoneNumber: String = ""
    ) {
        let user = UserModel(
            id: id,
            email: email,
            passsword: password,
            nickname: nickname,
            phoneNumber: phoneNumber,
            distance: 1,
            joinDate: Date(),
            dong: [LocationManager.shared.distriction]
        )
        let userData = convertUserModelToDictionary(user: user)
              
        db.collection("User").document(id).setData(userData)  { err in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("User has been saved!")
            }
        }
    }
                   
    func addUserLocation(userId: String) {
        let document = db.collection("User").document(userId).collection("Location").document()
        let documentId = document.documentID
        let location = Location (
            id: documentId,
            lat: LocationManager.shared.lat,
            long: LocationManager.shared.long
        )
        let locationData = convertLocationToDictionary(location: location)
        
        document.setData(locationData, merge: false) { err in
            if let err = err {
                print(err.localizedDescription)
            } else {
                print("Location has been saved!")
            }
        }
    }
    
    func register(email: String, password: String, nickname: String, phoneNumber: String = "", completion: @escaping () -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let user = result?.user else { return }
                self.addUser(id: user.uid, email: email, password: password, nickname: nickname, phoneNumber: phoneNumber)
                self.addUserLocation(userId: user.uid)
                completion()
            }
        }
    }
    

    
    func getUserData(email: String, completion: @escaping ([String: Any]?) -> Void) {
        db.collection("User").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(nil)
            } else {
                if let document = querySnapshot?.documents.first {
                    completion(document.data())
                } else {
                    completion(nil)
                }
            }
        }
    }
}
