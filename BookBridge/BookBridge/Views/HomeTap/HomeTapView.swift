//
//  HomeTapView.swift
//  BookBridge
//
//  Created by 노주영 on 2/6/24.
//

import SwiftUI
//
struct HomeTapView: View {
    @StateObject var viewModel: HomeViewModel
    @StateObject var locationManager = LocationManager.shared
    
    @State private var isInsideXmark: Bool = false
    @State private var isOutsideXmark: Bool = false
    @State private var text = ""
    @State private var showRecentSearchView = false
    
    var tapCategory: TapCategory
    
    var body: some View {
        ZStack {
            ScrollView(.vertical, showsIndicators: false) {
                HStack {
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .padding(.leading, 8)
                        
                        TextField("검색어를 입력해주세요", text: $text, onCommit: {
                            viewModel.addRecentSearch(user: UserManager.shared.uid, text: text)
                            isOutsideXmark = false
                            isInsideXmark = false
                            
                        })
                        .padding(7)
                        .onChange(of: text) { _ in
                            isInsideXmark = !text.isEmpty
                        }
                        .onTapGesture {
                            if text.isEmpty{
                                isOutsideXmark = true
                            }
                            else {
                                isInsideXmark = true
                                isOutsideXmark = true
                            }
                        }
                        
                        if isInsideXmark {
                            Button {
                                //TODO: 검색창 작동할 때 초기화할 것
                                isInsideXmark = false
                                text = ""
                            } label: {
                                Image(systemName: "xmark.circle")
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 8)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    .background(Color(red: 233/255, green: 233/255, blue: 233/255))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .onTapGesture {
                        isOutsideXmark = true
                    }
                    
                    if isOutsideXmark  {
                        Button{
                            if isInsideXmark == false{
                                isOutsideXmark = false
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.black)
                        }
                    }
                    
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
                
                switch tapCategory {
                case .find:             //TODO: imageLinks 부분 받아오기
                    ForEach(viewModel.findNoticeBoards) { element in
                        HomeListCell(
                            noticeBoard: element,
                            isHopobookEmpty: element.hopeBook.isEmpty,
                            type: .find
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                case .change:
                    ForEach(viewModel.changeNoticeBoards) { element in
                        HomeListCell(
                            noticeBoard: element,
                            isHopobookEmpty: element.hopeBook.isEmpty,
                            type: .change
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                case .recommend:          //TODO: 추천도서 로직 및 뷰
                    EmptyView()
                }
            }
            
            if isOutsideXmark {
                if UserManager.shared.isLogin {
                    HomeRecentSearchView(viewModel: viewModel)
                        .background(Color.white)
                        .zIndex(1)
                        .padding(.top, 60)
                        .opacity(showRecentSearchView ? 1 : 0)
                        .onAppear {
                            withAnimation(.easeOut(duration: 0.5)) {
                                showRecentSearchView = true
                            }
                        }
                        .onDisappear {
                            showRecentSearchView = false
                        }
                }
                
                switch tapCategory {
                case .find:
                    ForEach(viewModel.findNoticeBoards) { element in
                        HomeListCell(
                            noticeBoard: element,
                            isHopobookEmpty: element.hopeBook.isEmpty,
                            type: .find
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                case .change:
                    ForEach(viewModel.changeNoticeBoards) { element in
                        HomeListCell(
                            noticeBoard: element,
                            isHopobookEmpty: element.hopeBook.isEmpty,
                            type: .change
                        )
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    
                case .recommend:          //TODO: 추천도서 로직 및 뷰
                    EmptyView()
                    
                }
            }
            
        }
        .environmentObject(viewModel)
        .onAppear {
            viewModel.fetchBookMark(user: UserManager.shared.uid)
        }
    }
}
