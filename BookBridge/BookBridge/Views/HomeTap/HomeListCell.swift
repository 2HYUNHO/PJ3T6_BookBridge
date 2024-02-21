//
//  HomeListCell.swift
//  BookBridge
//
//  Created by 이민호 on 2/20/24.
//

import SwiftUI


struct HomeListCell: View {
    @State var showingPostView = false
    var noticeBoard: NoticeBoard
    var isHopobookEmpty: Bool
    var type: BoardType
        
    var body: some View {
        VStack {
            Button {
                showingPostView.toggle()
            } label: {
                switch type {
                case .find:
                    if isHopobookEmpty {
                        HomeListItemView(
                            author: "",
                            date: noticeBoard.date,
                            id: noticeBoard.id,
                            imageLinks: [],
                            isChange: noticeBoard.isChange,
                            locate: noticeBoard.noticeLocation,
                            title: noticeBoard.noticeBoardTitle,
                            userId: noticeBoard.userId,
                            location: noticeBoard.noticeLocationName
                        )
                    } else {
                        HomeListItemView(
                            author: noticeBoard.hopeBook[0].volumeInfo.authors?[0] ?? "",
                            date: noticeBoard.date,
                            id: noticeBoard.id,
                            imageLinks: [noticeBoard.hopeBook[0].volumeInfo.imageLinks?.smallThumbnail ?? ""],
                            isChange: noticeBoard.isChange,
                            locate: noticeBoard.noticeLocation,
                            title: noticeBoard.noticeBoardTitle,
                            userId: noticeBoard.userId,
                            location: noticeBoard.noticeLocationName
                        )
                    }
                case .change:
                    HomeListItemView(
                        author: "",
                        date: noticeBoard.date,
                        id: noticeBoard.id,
                        imageLinks: noticeBoard.noticeImageLink,
                        isChange: noticeBoard.isChange,
                        locate: noticeBoard.noticeLocation,
                        title: noticeBoard.noticeBoardTitle,
                        userId: noticeBoard.userId,
                        location: noticeBoard.noticeLocationName
                    )
                }               
            }
        }
        .navigationDestination(isPresented: $showingPostView) {
            PostView(noticeBoard: noticeBoard)
        }
    }
}

//#Preview {
//    HomeListCell()
//}
