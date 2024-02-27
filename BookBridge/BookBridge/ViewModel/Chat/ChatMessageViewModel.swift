//
//  ChatLogViewModel.swift
//  BookBridge
//
//  Created by 이현호 on 2/6/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatMessageViewModel: ObservableObject {
    
    @Published var bookImage: UIImage = UIImage(named: "DefaultImage")!
    @Published var chatImages: [String: UIImage] = [:]
    @Published var chatMessages: [ChatMessageModel] = []
    @Published var chatText = ""
    @Published var count = 0
    @Published var noticeBoardInfo: NoticeBoard = NoticeBoard(userId: "", noticeBoardTitle: "", noticeBoardDetail: "", noticeImageLink: [], noticeLocation: [], noticeLocationName: "", isChange: false, state: 0, date: Date(), hopeBook: [], reservationId: "")
    @Published var reservationName: String = ""
    @Published var saveChatRoomId: String = ""
    @Published var selectedImages: [UIImage] = []
    
    var firestoreListener: ListenerRegistration?
    
    let nestedGroup = DispatchGroup()
    let nestedGroupImage = DispatchGroup()
}

/*
 viewModel.initNewCount(uid: uid, chatRoomId: chatRoomListId)
 viewModel.fetchMessages(uid: uid, chatRoomListId: chatRoomListId)
 viewModel.getNoticeBoardInfo(noticeBoardId: chatRoomPartner.noticeBoardId)
 */

//MARK: 정보 가져오기
extension ChatMessageViewModel {
    // 메시지 가져오기
    func fetchMessages(uid: String) {
        // 실시간 업데이트 감시
        firestoreListener = FirebaseManager.shared.firestore.collection("User").document(uid).collection("chatRoomList").document(saveChatRoomId).collection("messages").order(by: "date", descending: false).addSnapshotListener { querySnapshot, error in
            guard error == nil else { return }
            guard let documents = querySnapshot else { return }
            
            self.chatMessages.removeAll()
            
            // 메시지 전송: 중복 x
            for document in documents.documents {
                guard let changeTime = document.data()["date"] as? Timestamp else { return }
                
                self.chatMessages.append(ChatMessageModel(
                    date: changeTime.dateValue() ,
                    imageURL: document.data()["imageURL"] as? String ?? "",
                    location: document.data()["location"] as? [String] ?? ["100", "200"],
                    message: document.data()["message"] as? String ?? "",
                    sender: document.data()["sender"] as? String ?? ""
                ))
            }
            
            // 자동 스크롤 비동기
            DispatchQueue.main.async {
                self.count += 1
            }
        }
    }
    
    //게시물 정보 가져오기
    func getNoticeBoardInfo(noticeBoardId: String) {
        self.noticeBoardInfo = NoticeBoard(userId: "", noticeBoardTitle: "", noticeBoardDetail: "", noticeImageLink: [], noticeLocation: [], noticeLocationName: "", isChange: false, state: 0, date: Date(), hopeBook: [])
        
        let query = FirebaseManager.shared.firestore.collection("noticeBoard").document(noticeBoardId)
        
        query.getDocument { documentSnapshot, error in
            guard error == nil else { return }
            guard let document = documentSnapshot else { return }
            guard let stamp = document.data()?["date"] as? Timestamp else { return }
            guard let isChange = document.data()?["isChange"] as? Bool else { return }
            guard let noticeImageLink = document.data()?["noticeImageLink"] as? [String] else { return }
            guard let reservationId = document.data()?["reservationId"] as? String else { return }
            
            if isChange {          //바꿔요 게시물
                let noticeBoard = NoticeBoard(
                    id: document.data()?["noticeBoardId"] as? String ?? "",
                    userId: document.data()?["userId"] as? String ?? "",
                    noticeBoardTitle: document.data()?["noticeBoardTitle"] as? String ?? "",
                    noticeBoardDetail: document.data()?["noticeBoardDetail"] as? String ?? "",
                    noticeImageLink: noticeImageLink,
                    noticeLocation: document.data()?["noticeLocation"] as? [Double] ?? [],
                    noticeLocationName: document.data()?["noticeLocationName"] as? String ?? "",
                    isChange: document.data()?["isChange"] as? Bool ?? false,
                    state: document.data()?["state"] as? Int ?? 0,
                    date: stamp.dateValue(),
                    hopeBook: [],
                    reservationId: reservationId
                )
                
                self.getReservationName(reservationId: reservationId)
                self.getNoticeBoardImage(urlString: noticeImageLink[0])
                
                DispatchQueue.main.async {
                    self.noticeBoardInfo = noticeBoard
                }
            } else {                                                    //구해요 게시물
                query.collection("hopeBooks").getDocuments { querySnapshot2, err2 in
                    guard err2 == nil else { return }
                    guard let hopeDocuments = querySnapshot2?.documents else { return }
                    
                    var hopeBooks: [Item] = []
                    
                    for doc in hopeDocuments {
                        if doc.exists {
                            self.nestedGroup.enter() // Enter nested DispatchGroup
                            
                            query.collection("hopeBooks").document(doc.documentID).collection("industryIdentifiers").getDocuments { (querySnapshot, error) in
                                guard let industryIdentifiers = querySnapshot?.documents else {
                                    self.nestedGroup.leave()
                                    return
                                }
                                
                                var isbn: [IndustryIdentifier] = []
                                
                                for industryIdentifier in industryIdentifiers {
                                    isbn.append(IndustryIdentifier(identifier: industryIdentifier.documentID))
                                }
                                
                                let item = Item(id: doc.documentID, volumeInfo: VolumeInfo(
                                    title: doc.data()["title"] as? String ?? "",
                                    authors: (doc.data()["authors"] as? [String] ?? [""]),
                                    publisher: doc.data()["publisher"] as? String ?? "",
                                    publishedDate: doc.data()["publishedDate"] as? String ?? "",
                                    description: doc.data()["description"] as? String ?? "",
                                    industryIdentifiers: isbn,
                                    pageCount: doc.data()["pageCount"] as? Int ?? 0,
                                    categories: doc.data()["categories"] as? [String] ?? [""],
                                    imageLinks: ImageLinks(smallThumbnail: doc.data()["imageLinks"] as? String ?? "")))
                                
                                hopeBooks.append(item)
                                
                                self.nestedGroup.leave() // Leave nested DispatchGroup
                            }
                        } else {
                            self.nestedGroup.leave() // Leave nested DispatchGroup
                        }
                    }
                    
                    self.nestedGroup.notify(queue: .main) {
                        // All tasks in nested DispatchGroup completed
                        let noticeBoard = NoticeBoard(
                            id: document.data()?["noticeBoardId"] as? String ?? "",
                            userId: document.data()?["userId"] as? String ?? "",
                            noticeBoardTitle: document.data()?["noticeBoardTitle"] as? String ?? "",
                            noticeBoardDetail: document.data()?["noticeBoardDetail"] as? String ?? "",
                            noticeImageLink: document.data()?["noticeImageLink"] as? [String] ?? [],
                            noticeLocation: document.data()?["noticeLocation"] as? [Double] ?? [],
                            noticeLocationName: document.data()?["noticeLocationName"] as? String ?? "",
                            isChange: document.data()?["isChange"] as? Bool ?? false,
                            state: document.data()?["state"] as? Int ?? 0,
                            date: stamp.dateValue(),
                            hopeBook: hopeBooks,
                            reservationId: document.data()?["reservationId"] as? String ?? ""
                        )
                        
                        self.getReservationName(reservationId: document.data()?["reservationId"] as? String ?? "")
                        
                        if hopeBooks.isEmpty {
                            self.bookImage = UIImage(named: "DefaultImage")!
                        } else {
                            print(hopeBooks[0])
                            self.getNoticeBoardImage(urlString: hopeBooks[0].volumeInfo.imageLinks?.smallThumbnail ?? "")
                        }
                        
                        DispatchQueue.main.async {
                            self.noticeBoardInfo = noticeBoard
                        }
                    }
                }
            }
        }
    }
}

//MARK: 메시지 전송 (Text)
extension ChatMessageViewModel {
    // 메시지 전송 저장 chatRoomListId가 있는 경우
    func handleSend(uid: String, partnerId: String) {
        let timestamp = Date()
        
        let messageData = [
            "date": timestamp,
            "imageURL": "",
            "location": ["100", "200"],
            "message": self.chatText,
            "sender": uid
        ] as [String : Any]
        
        // 발신자용 메시지 전송 저장
        let myQuery = FirebaseManager.shared.firestore.collection("User")
            .document(uid)
            .collection("chatRoomList").document(saveChatRoomId)
        
        let senderDocument = myQuery.collection("messages").document()
        
        senderDocument.setData(messageData) { error in
            guard error == nil else { return }
            
            print("Successfully saved current user sending message")
            
            self.count += 1 // 채팅 화면 하단 갱신
        }
        
        myQuery.updateData([
            "date": timestamp,
            "recentMessage": self.chatText
        ])
        
        // 수신자용 메시지 전송 저장
        let partnerQuery = FirebaseManager.shared.firestore.collection("User").document(partnerId).collection("chatRoomList").document(saveChatRoomId)
        
        let recipientMessageDocument = partnerQuery.collection("messages").document()
        
        recipientMessageDocument.setData(messageData) { error in
            guard error == nil else { return }
            print("Recipient saved message as well")
        }
        
        partnerQuery.getDocument { documentSnapshot, error in
            guard error == nil else { return }
            guard let document = documentSnapshot else { return }
            
            partnerQuery.updateData([
                "date": timestamp,
                "newCount": (document.data()?["newCount"] as? Int ?? 0) + 1,
                "recentMessage": self.chatText
            ])
            
            self.chatText = ""
        }
    }
    
    // 메시지 전송 저장 chatRoomListId가 없는 경우
    func handleSendNoId(uid: String, partnerId: String, completion: () -> ()) {
        saveChatRoomId = UUID().uuidString
        
        let timestamp = Date()
        
        let query1 = FirebaseManager.shared.firestore.collection("User").document(uid).collection("chatRoomList").document(saveChatRoomId)
        
        query1.setData([
            "date": timestamp,
            "id": saveChatRoomId,
            "isAlarm": true,
            "newCount": 0,
            "noticeBoardId": noticeBoardInfo.id,
            "noticeBoardTitle": noticeBoardInfo.noticeBoardTitle,
            "partnerId": partnerId,
            "recentMessage": "",
            "userId": uid
        ])
        
        let query2 = FirebaseManager.shared.firestore.collection("User").document(partnerId).collection("chatRoomList").document(saveChatRoomId)
        
        query2.setData([
            "date": timestamp,
            "id": saveChatRoomId,
            "isAlarm": true,
            "newCount": 0,
            "noticeBoardId": noticeBoardInfo.id,
            "noticeBoardTitle": noticeBoardInfo.noticeBoardTitle,
            "partnerId": uid,
            "recentMessage": "",
            "userId": partnerId
        ])
        
        completion()
    }
}

//MARK: 메시지 전송 (Image)
extension ChatMessageViewModel {
    func handleSendImage(uid: String, partnerId: String) {
        let timestamp = Date()
        
        for image in self.selectedImages {
            self.nestedGroupImage.enter()
            
            saveImage(image: image) { urlString in
                let messageData = [
                    "date": timestamp,
                    "imageURL": urlString,
                    "location": ["100", "200"],
                    "message": "",
                    "sender": uid
                ] as [String : Any]
                
                
                // 발신자용 메시지 전송 저장
                let myQuery = FirebaseManager.shared.firestore.collection("User")
                    .document(uid)
                    .collection("chatRoomList").document(self.saveChatRoomId)
                
                let senderDocument = myQuery.collection("messages").document()
                
                senderDocument.setData(messageData) { error in
                    guard error == nil else { return }
                    
                    print("Successfully saved current user sending message")
                    
                    self.count += 1 // 채팅 화면 하단 갱신
                }
                
                myQuery.updateData([
                    "date": timestamp,
                    "recentMessage": "사진"
                ])
                
                // 수신자용 메시지 전송 저장
                let partnerQuery = FirebaseManager.shared.firestore.collection("User").document(partnerId).collection("chatRoomList").document(self.saveChatRoomId)
                
                let recipientMessageDocument = partnerQuery.collection("messages").document()
                
                recipientMessageDocument.setData(messageData) { error in
                    guard error == nil else { return }
                    print("Recipient saved message as well")
                }
                
                partnerQuery.getDocument { documentSnapshot, error in
                    guard error == nil else { return }
                    guard let document = documentSnapshot else { return }
                    
                    
                    partnerQuery.updateData([
                        "date": timestamp,
                        "newCount": (document.data()?["newCount"] as? Int ?? 0) + 1,
                        "recentMessage": "사진"
                    ])
                }
            }
            self.nestedGroupImage.leave()
        }
        
        self.nestedGroup.notify(queue: .main) {
            self.selectedImages.removeAll()
        }
    }
    
    //이미지 저장
    func saveImage(image: UIImage, completion: @escaping(String) -> ()) {
        guard let imageData = image.jpegData(compressionQuality: 0.2) else { return }
        
        let ref = FirebaseManager.shared.storage.reference().child("ChatRoom/\(saveChatRoomId)/\(UUID().uuidString)")
        
        ref.putData(imageData, metadata: nil) { metadata, err in
            guard err == nil else { return }
            
            ref.downloadURL { url, error in
                guard error == nil else { return }
                guard let url = url else { return }
                
                completion(url.absoluteString)
            }
        }
    }
    
    //이미지 불러오기
    func getChatImage(urlString: String) {
        if !self.chatImages.contains(where: { $0.key == urlString }) {
            if let url = URL(string: urlString) {
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let imageData = data else { return }
                    
                    DispatchQueue.main.async {
                        self.chatImages.updateValue(UIImage(data: imageData) ?? UIImage(named: "DefaultImage")!, forKey: urlString)
                    }
                }.resume()
            }
        }
    }
}

//MARK: 게시물 이미지 가져오기
extension ChatMessageViewModel {
    func getNoticeBoardImage(urlString: String) {
        if let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let imageData = data else { return }
                
                DispatchQueue.main.async {
                    self.bookImage = UIImage(data: imageData) ?? UIImage(named: "DefaultImage")!
                }
            }.resume()
        }
    }
}

//MARK: newCount 초기화
extension ChatMessageViewModel {
    //채팅방 입장시 newCount 초기화
    func initNewCount(uid: String) {
        FirebaseManager.shared.firestore.collection("User").document(uid).collection("chatRoomList").document(saveChatRoomId).updateData([
            "newCount": 0
        ])
    }
}

//MARK: 알림기능
extension ChatMessageViewModel {
    func changeAlarm(uid: String, isAlarm: Bool) {
        let myQuery = FirebaseManager.shared.firestore.collection("User")
            .document(uid)
            .collection("chatRoomList").document(saveChatRoomId)
        myQuery.updateData([
            "isAlarm": isAlarm ? false : true
        ])
    }
}

//MARK: NoticeBoard 상태값 변경
extension ChatMessageViewModel {
    func changeState(state: Int, partnerId: String, noticeBoardId: String) {
        let partnerQuery = FirebaseManager.shared.firestore.collection("User").document(partnerId)
        let noticeQuery = FirebaseManager.shared.firestore.collection("noticeBoard").document(noticeBoardId)
        
        print(partnerId)
        partnerQuery.getDocument { documentSnapshot, error in
            guard error == nil else { return }
            guard let document = documentSnapshot?.data() else { return }
            
            var requests = document["requests"] as? [String] ?? []
            
            if state == 0 {
                if let index = requests.firstIndex(of: noticeBoardId) {
                    requests.remove(at: index)
                    
                    partnerQuery.updateData([
                        "requests": requests
                    ])
                    
                    noticeQuery.updateData([
                        "state": state,
                        "reservationId": ""
                    ])
                    
                    self.noticeBoardInfo.reservationId = ""
                } else {
                    print("오류")
                }
            } else {
                if !requests.contains(noticeBoardId) {
                    requests.append(noticeBoardId)
                    
                    partnerQuery.updateData([
                        "requests": requests
                    ])
                }
                
                noticeQuery.updateData([
                    "state": state,
                    "reservationId": partnerId
                ])
                
                self.noticeBoardInfo.reservationId = partnerId
            }
        }
        
        self.noticeBoardInfo.state = state
    }
}
//MARK: 예약자명 가져오기
extension ChatMessageViewModel {
    func getReservationName(reservationId: String) {
        if reservationId != "" {
            let query = FirebaseManager.shared.firestore.collection("User").document(reservationId)
            
            query.getDocument { documentSnapshot, error in
                guard error == nil else { return }
                guard let document = documentSnapshot?.data() else { return }
                
                self.reservationName = document["nickname"] as? String ?? ""
            }
        }
    }
}


//MARK: 상대방에게 메세지 Push 알림
extension ChatMessageViewModel {
    
    func sendNotification(to partnerId: String, with message: String) async {
        do {
            // 사용자 알림설정 체크
            let isEnabled = try await getChattingAlarmStatus(for: partnerId)
            
            if isEnabled {
                // 사용자 알림 보내기 API
                await sendNotificationAPI(to: partnerId, withMessage: message)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    private func getChattingAlarmStatus(for partnerId: String) async throws -> Bool {
        let query = FirebaseManager.shared.firestore.collection("User").document(partnerId)
        let document = try await query.getDocument()
        return document.data()?["isChattingAlarm"] as? Bool ?? true
    }
    
    private func sendNotificationAPI(to userId: String, withMessage message: String) async {
        guard let url = URL(string: "http://192.168.0.16:3000/send-notification") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["userId": userId, "message": message]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("알림 전송 실패")
                return
            }
            print("알림 전송 성공")
        } catch {
            print("알림 전송 에러: \(error.localizedDescription)")
        }
    }
}
