//
//  ChangeLocationView.swift
//  BookBridge
//
//  Created by 이민호 on 2/20/24.
//

import SwiftUI

struct PostChangeLocationView: View {
    @Binding var noticeBoard: NoticeBoard
    @State var showingPostMapDetail = false
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("교환 희망 장소")
                    .font(.system(size: 25))
                    .fontWeight(.bold)
                    .padding(.horizontal)
                    .padding(.top)
                
                Spacer()
                
                Button {
                    showingPostMapDetail.toggle()
                } label: {
                    Text("더보기")
                        .padding(.horizontal)
                        .padding(.top)
                }
            }
            
            
            if noticeBoard.noticeLocation.count >= 2 {
                PostMapView(
                    lat: $noticeBoard.noticeLocation[0],
                    lng: $noticeBoard.noticeLocation[1],
                    isDetail: false
                )
            }
            
            Text(noticeBoard.noticeLocationName)
                .font(.system(size: 15))
                .padding(.horizontal)
        }
        .navigationDestination(isPresented: $showingPostMapDetail) {
            PostMapDetailView(
                lat: $noticeBoard.noticeLocation[0],
                lng: $noticeBoard.noticeLocation[1],
                noticeBoard: $noticeBoard
            )
        }
        .frame(
            minWidth: UIScreen.main.bounds.width,
            minHeight: 400,
            alignment: Alignment.topLeading
        )
        .padding(.bottom)
    }
}
