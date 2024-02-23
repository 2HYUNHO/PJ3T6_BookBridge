//
//  ChangePostView.swift
//  BookBridge
//
//  Created by jonghyun baik on 2/7/24.
//

import SwiftUI
import NMapsMap

struct PostView: View {
    @Environment(\.dismiss) private var dismiss
    
    @Binding var isShowPlusBtn: Bool
    
    @StateObject var postViewModel = PostViewModel()
    @StateObject var reportViewmodel = ReportViewModel()
    
    @State var noticeBoard: NoticeBoard
    
    @State private var isPresented = false
    
    var storageManager = HomeFirebaseManager.shared
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView() {
                    VStack {
                        if noticeBoard.isChange {
                            PostImageView(urlString: noticeBoard.noticeImageLink)
                        }
                        
                        PostUserInfoView(postViewModel: postViewModel)
                                            
                        Divider()
                            .padding(.horizontal)
                        
                        //post 내용
                        PostContent(noticeBoard: $noticeBoard)
                                            
                        Divider()
                            .padding(.horizontal)
                                            
                        //상대방 책장
                        PostUserBookshelf(postViewModel: postViewModel)
                                            
                        Divider()
                            .padding(.horizontal)
                        
                        // 교환 희망 장소
                        PostChangeLocationView(
                            postViewModel: postViewModel,
                            noticeBoard: $noticeBoard
                        )
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(maxHeight: geometry.size.height - 65)
            }
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.2)) {
                    isPresented = false
                }
            }
            
            PostMenuBtnsView(
                postViewModel: postViewModel,
                reportVM: reportViewmodel,
                isPresented: $isPresented,
                noticeBoard: $noticeBoard
            )
            
            VStack {
                Spacer()
                
                if UserManager.shared.uid == noticeBoard.userId {
                    NavigationLink {
                        ChatRoomListView(isShowPlusBtn: $isShowPlusBtn, isComeNoticeBoard: true, uid: UserManager.shared.uid)
                    } label: {
                        Text("대화중인 채팅방 \(postViewModel.chatRoomList.count)")
                            .padding(.top, 5)
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60, alignment: Alignment.center).ignoresSafeArea()
                            .foregroundStyle(Color.white)
                            .background(Color(hex: "59AAE0"))
                    }
                } else {
                    if noticeBoard.state == 1 {
                        //TODO: 예약중인데 내가 예약중인 경우
                        
                        Text("예약중")
                            .padding(.top, 5)
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60, alignment: Alignment.center).ignoresSafeArea()
                            .foregroundStyle(Color.white)
                            .background(Color(.lightGray))
                    } else if noticeBoard.state == 2 {
                        Text("교환완료")
                            .padding(.top, 5)
                            .font(.system(size: 20, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .frame(height: 60, alignment: Alignment.center).ignoresSafeArea()
                            .foregroundStyle(Color.white)
                            .background(Color(.lightGray))
                    } else {
                        //채팅한 적이 없는 경우
                        if postViewModel.chatRoomList.isEmpty {
                            NavigationLink {
                                if let image = UIImage(contentsOfFile: "DefaultImage") {
                                    ChatMessageView(
                                        isShowPlusBtn: $isShowPlusBtn,
                                        chatRoomListId: UUID().uuidString,
                                        noticeBoardTitle: noticeBoard.noticeBoardTitle,
                                        chatRoomPartner: ChatPartnerModel(
                                            nickname: postViewModel.user.nickname ?? "책벌레",
                                            noticeBoardId: noticeBoard.id,
                                            partnerId: noticeBoard.userId,
                                            partnerImage: image,
                                            style: "중고귀신"
                                        ),
                                        uid: UserManager.shared.uid
                                    )
                                }
                            } label: {
                                Text("채팅하기")
                                    .padding(.top, 5)
                                    .font(.system(size: 20, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60, alignment: Alignment.center).ignoresSafeArea()
                                    .foregroundStyle(Color.white)
                                    .background(Color(hex: "59AAE0"))
                            }
                        } else {
                            //채팅한 적이 있는 경우
                            NavigationLink {
                                if let image = UIImage(contentsOfFile: "DefaultImage") {
                                    ChatMessageView(
                                        isShowPlusBtn: $isShowPlusBtn,
                                        chatRoomListId: postViewModel.chatRoomList.first!,
                                        noticeBoardTitle: noticeBoard.noticeBoardTitle,
                                        chatRoomPartner: ChatPartnerModel(
                                            nickname: postViewModel.user.nickname ?? "책별레",
                                            noticeBoardId: noticeBoard.id,
                                            partnerId: noticeBoard.userId,
                                            partnerImage: image,
                                            style: "중고귀신"
                                        ),
                                        uid: UserManager.shared.uid
                                    )
                                }
                            } label: {
                                Text("채팅하기")
                                    .padding(.top, 5)
                                    .font(.system(size: 20, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60, alignment: Alignment.center).ignoresSafeArea()
                                    .foregroundStyle(Color.white)
                                    .background(Color(hex: "59AAE0"))
                            }
                        }
                    }
                }
            }
            .frame(alignment: Alignment.bottom)
        }
        .onAppear {
            isShowPlusBtn = false
            
            Task {
                postViewModel.gettingUserInfo(userId: noticeBoard.userId)
                postViewModel.gettingUserBookShelf(userId: noticeBoard.userId, collection: "holdBooks")
                postViewModel.gettingUserBookShelf(userId: noticeBoard.userId, collection: "wishBooks")
                
                if UserManager.shared.isLogin {
                    postViewModel.fetchChatList(noticeBoardId: noticeBoard.id)
                    postViewModel.fetchBookMark()
                }
            }
        }
        .navigationTitle(noticeBoard.isChange ? "바꿔요" : "구해요")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.easeIn(duration: 0.2)) {
                        isPresented.toggle()
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(.black)
                }
            }
        }
    }
}
