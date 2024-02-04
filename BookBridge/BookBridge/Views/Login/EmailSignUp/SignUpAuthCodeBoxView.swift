//
//  SignUpAuthCodeView.swift
//  BookBridge
//
//  Created by 이민호 on 1/29/24.
//

import SwiftUI

struct SignUpAuthCodeBoxView: View {
    @StateObject var signUpVm: SignUpViewModel    
    @State var isLoading = false
    
    var body: some View {
        VStack {
            HStack {
                Text("인증번호")
                    .font(.system(size: 10))
                    .foregroundStyle(Color(hex: "999999"))
                                            
                if signUpVm.timeLabel != "" {
                    Text(signUpVm.timeLabel)
                        .font(.system(size: 10))
                        .foregroundStyle(Color(hex: "FF0000"))
                }
                
                Spacer()
            }
                        
            HStack {
                TextField("인증번호를 입력해주세요", text: $signUpVm.userAuthCode)
                    .modifier(InputTextFieldStyle())
                
                HStack {
                    if isLoading {
                        LoadingCircle(size: 10, color: "999999")
                    }
                    
                    Button {
                        isLoading = true
                        signUpVm.sendMail() {
                            isLoading = false
                        }
                    } label: {
                        Text("재전송")
                    }
                }
                .modifier(MiddleWhiteBtnStyle())
            }            
                        
            if let certiResult = signUpVm.isCertiClear {
                if certiResult == .wrong {
                    StatusTextView(text: "잘못된 인증번호 입니다.", color: "F80B0B")
                }
            }
            
        }
    }
    
}

#Preview {
    SignUpAuthCodeBoxView(signUpVm: SignUpViewModel())
}
