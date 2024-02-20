//
//  PostMenuBtnsView.swift
//  BookBridge
//
//  Created by 이민호 on 2/20/24.
//

import SwiftUI

struct PostMenuBtnsView: View {
    @StateObject var postViewModel: PostViewModel
    @Binding var isPresented: Bool
    @Binding var noticeBoard: NoticeBoard
    
    var body: some View {
        VStack{
            HStack{
                
                Spacer()
                
                VStack{
                    if isPresented {
                        if UserManager.shared.uid != noticeBoard.userId {
                            Button {
                                if UserManager.shared.isLogin {
                                    postViewModel.bookMarkToggle(id: noticeBoard.id)
                                }
                                isPresented.toggle()
                            } label: {
                                Text( postViewModel.bookMarks.contains(noticeBoard.id) ? "관심목록 삭제" : "관심목록 추가")
                                    .font(.system(size: 14))
                                    .padding(1)
                            }
                        Divider()
                            .padding(1)
                            NavigationLink {
                                EmptyView()
                            } label: {
                                Text("신고하기")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.red)
                                    .padding(1)
                            }
                        } else {
                            NavigationLink {
                                if noticeBoard.isChange {
                                    ChangePostingModifyView(noticeBoard: $noticeBoard)
                                } else {
                                    FindPostingModifyView(noticeBoard: $noticeBoard)
                                }
                            } label: {
                                Text("수정하기")
                                    .font(.system(size: 14))
                                    .padding(1)
                            }
                            Divider()
                                .padding(1)
                            Button {
                                
                            } label: {
                                Text("삭제하기")
                                    .font(.system(size: 14))
                                    .foregroundStyle(Color.red)
                                    .padding(1)
                            }
                        }
                    }
                }
                .frame(width: 110, height: isPresented ? 80 : 0)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .circular)
                        .foregroundColor(Color(red: 230/255, green: 230/255, blue: 230/255))
                )
                .padding(.trailing)
            }
            
            Spacer()
            
        }
    }
}
