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
    
    @State private var isPresented = false
    @State var noticeBoard: NoticeBoard
    @State var url: [URL] = []
    @StateObject var postViewModel = PostViewModel()
    
    var storageManager = HomeFirebaseManager.shared
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack {
                    if noticeBoard.isChange {
                        PostImageView(url: $url)
                    }
                    PostUserInfoView(postViewModel: postViewModel)
                                        
                    Divider()
                        .padding(.horizontal)
                    
                    // post 내용
                    PostContentView(noticeBoard: $noticeBoard)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // 교환 희망 장소
                    PostChangeLocationView(noticeBoard: $noticeBoard)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // 책장
                    UserBookshelfView(postViewModel: postViewModel)
                }
            }
            .onTapGesture {
                withAnimation(.easeIn(duration: 0.2)) {
                    isPresented = false
                }
            }
            
            // 수정하기, 삭제하기 버튼
            PostMenuBtnsView(
                postViewModel: postViewModel,
                isPresented: $isPresented,
                noticeBoard: $noticeBoard
            )
            
            // 채팅방 입장 버튼
            PostChatBtnView(postViewModel: postViewModel, noticeBoard: $noticeBoard)
            
        }
        .onAppear {
            if !noticeBoard.noticeImageLink.isEmpty && noticeBoard.isChange {
                Task {
                    for image in noticeBoard.noticeImageLink {
                        try await storageManager.downloadImage(noticeiId: noticeBoard.id, imageId: image) { url in
                            self.url.append(url)
                        }
                        
                    }
                }
            }
            
            Task {
                postViewModel.gettingUserInfo(userId: noticeBoard.userId)
                postViewModel.gettingUserBookShelf(userId: noticeBoard.userId, collection: "holdBooks")
                postViewModel.gettingUserBookShelf(userId: noticeBoard.userId, collection: "wishBooks")
                if UserManager.shared.isLogin {
                    postViewModel.fetchChatList(noticeBoardId: noticeBoard.id)
                    postViewModel.fetchBookMark()
                }
            }
            if noticeBoard.noticeLocation.count >= 2 {
                //                myCoord = (noticeBoard.noticeLocation[0], noticeBoard.noticeLocation[1])
            }
        }
        .navigationTitle(noticeBoard.isChange ? "바꿔요" : "구해요")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16))
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
                        .font(.system(size: 16))
                        .foregroundStyle(.gray)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}
