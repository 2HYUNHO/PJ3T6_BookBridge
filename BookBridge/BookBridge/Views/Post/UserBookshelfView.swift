//
//  UserBookshelfView.swift
//  BookBridge
//
//  Created by 이민호 on 2/20/24.
//

import SwiftUI

struct UserBookshelfView: View {
    @StateObject var postViewModel: PostViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(postViewModel.user.nickname ?? "책벌레")님의 책장")
                .font(.system(size: 25))
                .fontWeight(.bold)
                .padding()
            
            //책장 리스트뷰
            HStack{
                Text("보유 도서")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                Spacer()
                
                NavigationLink(destination: BookShelfView(userId: postViewModel.user.id, initialTapInfo: .hold, isBack: true)
                    .navigationBarBackButtonHidden()
                ) {
                    Text("더보기")
                        .foregroundStyle(Color(red: 153/255, green: 153/255, blue: 153/255))
                }
            }
            .padding(.horizontal)
            
            List{
                ForEach(postViewModel.holdBooks) { element in
                    if let bookTitle = element.volumeInfo.title {
                        Text(bookTitle)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .padding(.bottom)
            
            HStack{
                Text("희망 도서")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                Spacer()
                NavigationLink(destination: BookShelfView(userId: postViewModel.user.id,initialTapInfo: .wish,isBack: true)
                    .navigationBarBackButtonHidden()) {
                        Text("더보기")
                            .foregroundStyle(Color(red: 153/255, green: 153/255, blue: 153/255))
                    }
            }
            .padding(.horizontal)
            
            List{
                ForEach(postViewModel.wishBooks) { element in
                    if let bookTitle = element.volumeInfo.title {
                        Text(bookTitle)
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .frame(
            minWidth: UIScreen.main.bounds.width,
            minHeight: 300,
            alignment: Alignment.topLeading
        )
        .padding(.bottom, 60)
    }
}
