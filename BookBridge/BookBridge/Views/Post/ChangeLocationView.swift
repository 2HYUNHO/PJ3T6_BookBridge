//
//  ChangeLocationView.swift
//  BookBridge
//
//  Created by 이민호 on 2/20/24.
//

import SwiftUI

struct ChangeLocationView: View {
    @Binding var noticeBoard: NoticeBoard
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("교환 희망 장소")
                .font(.system(size: 25))
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top)
            
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
        .frame(
            minWidth: UIScreen.main.bounds.width,
            minHeight: 400,
            alignment: Alignment.topLeading
        )
        .padding(.bottom)
    }
}
