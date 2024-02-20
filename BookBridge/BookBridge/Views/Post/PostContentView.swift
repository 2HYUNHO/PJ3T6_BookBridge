//
//  PostContentView.swift
//  BookBridge
//
//  Created by 이민호 on 2/20/24.
//

import SwiftUI

struct PostContentView: View {
    @Binding var noticeBoard: NoticeBoard
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(noticeBoard.noticeBoardTitle)
                .font(.system(size: 25))
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top)
            Text("1시간전")
                .font(.system(size: 10))
                .padding(.horizontal)
            Text(noticeBoard.noticeBoardDetail)
                .font(.system(size: 15))
                .padding()
        }
        .frame(
            minWidth: UIScreen.main.bounds.width,
            minHeight: 200,
            alignment: Alignment.topLeading
        )
    }
}
