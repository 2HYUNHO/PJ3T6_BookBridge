//
//  HomeViewModel.swift
//  BookBridge
//
//  Created by jonghyun baik on 2/1/24.
//

import Foundation
import FirebaseFirestore

class HomeViewModel : ObservableObject {
    static let share = HomeViewModel()
    let db = Firestore.firestore()
    
    
    var noticeBoards : [NoticeBoard] = []
    
    func gettingAllDocs() {
        db.collection("noticeBoard").getDocuments() { (querySnapshot, err) in
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                guard let documents = querySnapshot?.documents else {return}
                
                for document in documents {
                    if document.data()["date"] is Timestamp {
                        guard let stamp = document.data()["date"] as? Timestamp else {
                            return
                        }
                        
                        self.noticeBoards.append(
                            NoticeBoard(
                                userId: document.data()["userId"] as! String,
                                noticeBoardTitle: document.data()["noticeBoardTitle"] as! String,
                                noticeBoardDetail: document.data()["noticeBoardDetail"] as! String,
                                noticeImageLink: document.data()["noticeImageLink"] as! [String],
                                noticeLocation: document.data()["noticeLocation"] as! [Double],
                                isChange: document.data()["isChange"] as! Bool, state: document.data()["state"] as! Int,
                                date: stamp.dateValue(),
                                hopeBook: []
                            ))
                            print(self.noticeBoards)
                    }
                }
            }
        }
    }
    
    init() {
         gettingAllDocs()
    }
}
