//
//  HomeView.swift
//  BookBridge
//
//  Created by 노주영 on 2/6/24.
//

import SwiftUI
import FirebaseStorage

struct HomeView: View {
    @StateObject var viewModel = HomeViewModel()
    @StateObject var userManager = UserManager.shared
    @StateObject var locationManager = LocationManager.shared
    @State private var selectedPicker: TapCategory = .find
    @State private var showingLoginView = false
    @State private var showingTownSettingView = false
        
    @Namespace private var animation
        
    var body: some View {
            VStack {
                HStack {
                    Button {
                        if userManager.isLogin {
                            // 로그인시
                            showingTownSettingView.toggle()
                        } else {
                            // 비로그인시
                            showingLoginView.toggle()
                        }
                    } label: {
                        HStack{
                            Text(userManager.isLogin ? userManager.currentDong : locationManager.dong)
                            Image(systemName: "chevron.down")
                        }
                        .padding(.leading, 20)
                        .foregroundStyle(.black)
                        
                    }
                    Spacer()
                    
                    // 임시로 만든 로그인/로그아웃 버튼입니다.
                    Button {
                        if userManager.isLogin {
                            userManager.logout()
                        } else {
                            showingLoginView.toggle()
                        }
                    } label: {
                        Text(userManager.isLogin ? "로그아웃" : "로그인")
                    }
                    .padding(.trailing, 20)
                }
                
                tapAnimation()
                
                HomeTapView(viewModel: viewModel, tapCategory: selectedPicker)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.updateNoticeBoards()
                }
            }
            .sheet(isPresented: $showingLoginView) {
                LoginView(showingLoginView: $showingLoginView)
            }
            .navigationDestination(isPresented: $showingTownSettingView) {
                TownSettingView()
                    .toolbar(.hidden, for: .tabBar)
            }
            .onChange(of: userManager.isLogin) { _ in
                print("로그인 변동 감지")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.updateNoticeBoards()
                }
            }
            .onChange(of: locationManager.dong) { _ in
                print("현재위치 변동 감지")
                if !userManager.isLogin {
                    viewModel.updateNoticeBoards()
                }
            }
            .onChange(of: userManager.isChanged) { _ in
                print("선택한동 변동 감지")
                viewModel.updateNoticeBoards()
            }
        
    }
    
    
    @ViewBuilder
    private func tapAnimation() -> some View {
        HStack {
            ForEach(TapCategory.allCases, id: \.self) { item in
                VStack {
                    Text(item.rawValue)
                        .font(.title3)
                        .frame(maxWidth: .infinity/3, minHeight: 50)
                        .foregroundColor(selectedPicker == item ? .black : .gray)
                    
                    if selectedPicker == item {
                        Capsule()
                            .foregroundColor(.black)
                            .frame(height: 3)
                            .matchedGeometryEffect(id: "info", in: animation)
                            .padding(.bottom, 0)
                    }
                    
                }
                .onTapGesture {
                    withAnimation(.easeInOut) {
                        self.selectedPicker = item
                    }
                }
            }
        }
        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color(red: 200/255, green: 200/255, blue: 200/255)), alignment: .bottom)
    }
}

