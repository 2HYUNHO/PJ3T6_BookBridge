//
//  BookView.swift
//  BookBridge
//
//  Created by 김건호 on 2/2/24.
//

import SwiftUI

struct BookView: View {
    @EnvironmentObject var viewModel: BookShelfViewModel
    @Binding var selectedBook: Item?
    @Binding var isEditing: Bool  // 편집 모드 상태 바인딩
    
    var tap: tapInfo
    
    
    
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 3)
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.filteredBooks, id: \.id) { book in
                    ZStack ( alignment : .topTrailing){
                        VStack {
                            if let urlString = book.volumeInfo.imageLinks?.smallThumbnail, let url = URL(string: urlString) {
                                AsyncImage(url: url){
                                    image in
                                    image
                                        .resizable()
                                        .frame(width: (UIScreen.main.bounds.width - 60) / 3, height: 164)
                                        .shadow(color: .gray, radius: 5, x: 0, y: 2)
                                        .onTapGesture{
                                            selectedBook = book
                                        }
                                } placeholder: {
                                    ProgressView()
                                        .frame(width: 60, height: 80)
                                }
                            } else {
                                Image("imageNil")
                                    .resizable()
                                    .shadow(color: .gray, radius: 5, x: 0, y: 2)
                                    .frame(width: (UIScreen.main.bounds.width - 60) / 3, height: 164)
                                    .onTapGesture{
                                        selectedBook = book
                                    }
                            }
                            
                            
                        }
                        .frame(width: (UIScreen.main.bounds.width - 60) / 3)
                        
                        if isEditing {
                            ZStack{
                                Button {
                                    viewModel.deleteBook(book, for: tap)
                                    viewModel.fetchBooks(for: tap)
                                    
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .frame(width: 24, height: 24)
                                    
                                }
                            }
                            
                        }
                        
                        
                        
                        
                    }
                }
                .padding(.top, 8)
            }
        }
    }
}



