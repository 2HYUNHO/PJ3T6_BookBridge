//
//  PostMapSeeMoreView.swift
//  BookBridge
//
//  Created by 김지훈 on 2024/02/15.
//

import SwiftUI

struct PostMapDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var lat: Double
    @Binding var lng: Double
    @Binding var noticeBoard: NoticeBoard
    
    var body: some View {
        PostMapView(lat: $lat, lng: $lng, isDetail: true)
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
            }
            .navigationBarBackButtonHidden()
            .edgesIgnoringSafeArea(.bottom)
    }
}
