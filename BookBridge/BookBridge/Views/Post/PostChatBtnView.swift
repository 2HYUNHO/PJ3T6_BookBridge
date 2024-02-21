//
//  PostChatBtnView.swift
//  BookBridge
//
//  Created by 이민호 on 2/21/24.
//

import SwiftUI

enum PostChatBtnViewError: Error {
    case Image
}

struct PostChatBtnView: View {
    @StateObject var postViewModel: PostViewModel
    @Binding var noticeBoard: NoticeBoard
    
    var body: some View {
        VStack {
            Spacer()
            
            if UserManager.shared.uid == noticeBoard.userId {
                NavigationLink {
                    ChatRoomListView(uid: UserManager.shared.uid)
                } label: {
                    Text("대화중인 채팅방 \(postViewModel.chatRoomList.count)")
                        .modifier(PostChatBtnTextStyle())
                }
            } else {
                if noticeBoard.state == 1 {
                    Text("예약중")
                        .modifier(PostChatBtnTextStyle())
                }
                else if noticeBoard.state == 0 {
                    if postViewModel.chatRoomList.isEmpty {
                        NavigationLink {
                            createChatMessageView()
                        } label: {
                            Text("채팅하기")
                                .modifier(PostChatBtnTextStyle())
                        }
                    } else {
                        NavigationLink {
                            createChatMessageView()
                        } label: {
                            Text("채팅하기")
                                .modifier(PostChatBtnTextStyle())
                        }
                    }
                }
            }
        }
        .frame(alignment: Alignment.bottom)
    }
}

extension PostChatBtnView {
    
    func createChatPartnerModel(with uiImage: UIImage) -> ChatPartnerModel {
        let nickname = postViewModel.user.nickname ?? "책벌레"
        let chatPartnerModel = ChatPartnerModel(
            nickname: nickname,
            noticeBoardId: noticeBoard.id,
            partnerId: noticeBoard.userId,
            partnerImage: uiImage,
            style: "중고귀신"
        )
        return chatPartnerModel
    }
    
    func createChatMessageView() -> AnyView? {
        if let image = UIImage(named: "DefaultImage") {
            return AnyView(
                ChatMessageView(
                    chatRoomListId: UUID().uuidString,
                    noticeBoardTitle: noticeBoard.noticeBoardTitle,
                    chatRoomPartner: createChatPartnerModel(with: image),
                    uid: UserManager.shared.uid
                )
            )
        } else {
            print("createChatMessageView: Image를 불러오지 못합니다.")
            return nil
        }
    }
}
