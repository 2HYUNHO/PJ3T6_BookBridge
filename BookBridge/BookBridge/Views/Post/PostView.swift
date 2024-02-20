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
                    
                    //post 내용
                    PostContentView(noticeBoard: $noticeBoard)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    //교환 희망 장소
                    ChangeLocationView(noticeBoard: $noticeBoard)
                    
                    Divider()
                        .padding(.horizontal)
                    
                    //상대방 책장
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

struct PostMapView: UIViewRepresentable {
    
    @Binding var lat: Double // 모델 좌표 lat
    @Binding var lng: Double // 모델 좌표 lng
    var isDetail: Bool
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let mapView = NMFNaverMapView()
        if !isDetail {
            mapView.showZoomControls = false
            mapView.mapView.isScrollGestureEnabled = false
        }
        
        // 마커 좌표를 설정
        let markerCoord = NMGLatLng(lat: lat, lng: lng)
        
        // 내 위치 활성화 버튼을 표시
        //        mapView.showLocationButton = true
        
        // 초기 카메라 위치를 마커의 위치로 설정하고 줌 레벨을 조정
        let cameraUpdate = NMFCameraUpdate(scrollTo: markerCoord, zoomTo: 15)
        mapView.mapView.moveCamera(cameraUpdate)
        
        // 마커를 생성하고 지도에 표시
        let marker = NMFMarker(position: markerCoord)
        marker.mapView = mapView.mapView
        
        return mapView
    }
    
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        //        _ = NMGLatLng(lat: lat, lng: lng)
        //        _ = NMFCameraUpdate(scrollTo: newMyCoord)
    }
}
