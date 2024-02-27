//
//  HomeListItemView.swift
//  BookBridge
//
//  Created by 노주영 on 2/6/24.
//

import SwiftUI

struct HomeListItemView: View {
    @EnvironmentObject var viewModel: HomeViewModel
    
    var homeFirebaseManager = HomeFirebaseManager.shared
    
    var author: String
    var date: Date
    var id: String
    var imageLinks: [String]
    var isChange: Bool
    var locate: [Double]
    var title: String
    var userId: String
    var location: String
    var detail : String
    
    var body: some View {
        HStack {
            if imageLinks.isEmpty {
                Image("Character")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 75, height: 100)
                    .foregroundStyle(.black)
                    .cornerRadius(10)
                    .padding()
            } else {
                Image(uiImage:
                        (isChange ? viewModel.changeNoticeBoardsDic[id] : viewModel.findNoticeBoardsDic[id]) ?? UIImage(named: "Character")!
                )
                .resizable()
                .frame(width: 75, height: 100)
                .foregroundStyle(.black)
                .cornerRadius(10)
                .padding()
            }
            
            
            VStack(alignment: .leading, spacing: 0){
                Divider().opacity(0)
                Text("\(title)")
                    .font(.system(size: 15))
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                    .padding(.top, 10)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                if author != "" {
                    Text("\(author)")
                        .font(.system(size: 10))
                        .padding(.top, 5)
                        .foregroundStyle(Color(red: 75/255, green: 75/255, blue: 75/255))
                }
                
                
                
                Text("\(detail)")
                    .font(.system(size: 14))
                    .padding(.top, 5)
                    .foregroundStyle(Color(red: 75/255, green: 75/255, blue: 75/255))
                    .multilineTextAlignment(.leading)
                
                Spacer()
                

                HStack{
                    Text("\(location.count>=20 ? location.components(separatedBy: " ")[3] : location) |")
                            .font(.system(size: 10))
                            .lineLimit(1)
                            .padding(.bottom, 10)
                            .foregroundStyle(Color(red: 75/255, green: 75/255, blue: 75/255))
                    
                        Text("\(ConvertManager.getTimeDifference(from: date))")
                            .font(.system(size: 10))
                            .padding(.bottom, 10)
                            .foregroundStyle(Color(red: 75/255, green: 75/255, blue: 75/255))
                }
             
                
                

            }
            
            Spacer()
            if UserManager.shared.isLogin {
                VStack{
                    Button {
                        viewModel.bookMarkToggle(user: userId, id: id)
                    } label: {
                        if (viewModel.bookMarks.contains(id)) {
                            Image(systemName: "bookmark.fill")
                                .font(.system(size: 20))
                                .padding()
                                .foregroundColor(.black)
                        } else {
                            Image(systemName: "bookmark")
                                .font(.system(size: 20))
                                .padding()
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                }
            }
        }
        .frame(height: 120, alignment: .center)
        .onAppear {
            if !imageLinks.isEmpty {
                viewModel.getDownLoadImage(isChange: isChange, noticeBoardId: id, urlString: imageLinks[0])
            }
        }
    }
}
