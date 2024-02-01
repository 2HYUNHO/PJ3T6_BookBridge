//
//  FindIdVM.swift
//  BookBridge
//
//  Created by 김건호 on 1/30/24.
//

import Foundation
import Firebase
import SwiftSMTP
import Combine

class FindIdViewModel: ObservableObject {
    @Published var id: String = ""
    @Published var nickname: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var passwordConfirm: String = ""
    @Published var userAuthCode: String = "" // 사용자가 입력하는 인증번호
    @Published var timeRemaining = 180
    @Published var timeLabel: String = ""
    @Published var isCertiActive = false
    private var authCode: String? // 인증번호
    var isCertiClear = false
    
//    func sendMail() {
//        let mail_to = Mail.User(name: "mail_to", email: email)
//        authCode = createEmailCode()
//        let mail = Mail(
//            from: mail_from,
//            to: [mail_to],
//            subject: "북다리 이메일 인증번호",
//            text: emailContent(code: authCode ?? "")
//        )
//        smtp.send(mail)
//        isCertiActive.toggle()
//        showingTime()
//    }
    
    func sendMessage() {
        
    }
    
    func showingTime() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            
            self.timeRemaining -= 1
            
            let min = self.timeRemaining / 60
            let sec = self.timeRemaining % 60
            
            if self.timeRemaining > 0 {
                self.timeLabel = "\(min)분 \(sec)초 남음"
            } else {
                self.timeRemaining = 180
                self.authCode = nil
                self.timeLabel = "인증시간만료"
                timer.invalidate()
            }
        }
    }
    

    
    func isCertiCode() -> Bool {
        if userAuthCode == self.authCode {
            self.isCertiClear.toggle()
            self.timeRemaining = 0
        }
        return userAuthCode == self.authCode
    }
}
