//
//  ChangePostingView1.swift
//  BookBridge
//
//  Created by 이현호 on 1/29/24.

import SwiftUI
import UniformTypeIdentifiers

struct ChangePostingView: View {
    @State private var titleText = ""
    @State private var contentText = ""
    @State private var isDestinationActive = false
    @State private var sourceType = 0
    @State private var showActionSheet = false
    @State private var showImagePicker = false
    @State private var selectedImages: [UIImage] = []
    
    @State var text: String = ""
    
    @StateObject var changeViewModel = ChangePostViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading) {
                    // 이미지 스크롤 뷰
                    ImageScrollView(selectedImages: $selectedImages, showActionSheet: $showActionSheet)
                    
                    // 제목 입력 필드
                    Text("제목")
                        .bold()
                    TextField("제목을 입력해주세요", text: $titleText)
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                        .padding(.bottom, 20)
                    
                    // 상세 설명 입력 필드
                    VStack(alignment: .leading) {
                        Text("상세설명")
                            .bold()
                        ZStack(alignment: .topLeading) {
                            TextField("상세 내용을 작성해주세요", text: $text, axis: .vertical)
                                .padding()
                                .frame(height: 200, alignment: .top)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                            Spacer()
                        }
                    }
                    .padding(.bottom, 20)
                    
                    // 교환희망 장소 선택 버튼
                    Text("교환 희망 장소")
                        .bold()
                    Button(action: {
                        isDestinationActive = true
                    }) {
                        HStack {
                            Text("교환장소 선택")
                                .foregroundColor(.black)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(hex: "EAEAEA"))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1)
                        )
                    }
                    .navigationDestination(isPresented: $isDestinationActive) {
                        Text("교환 장소 선택 뷰")
                        EmptyView()
                    }
                    .padding(.bottom, 20)
                    
                    // 확인 버튼
                    Button(action: {
                        // 확인 버튼이 클릭되었을 때 수행할 동작
                        changeViewModel.uploadPost(title: titleText, detail: text, images: selectedImages)
                    }) {
                        Text("확인")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color(hex:"59AAE0"))
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding()
            .navigationTitle("바꿔요")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog(
                "",
                isPresented: $showActionSheet,
                titleVisibility: .hidden,
                actions: {
                    Button("카메라", role: .destructive) {
                        self.sourceType = 0
                        self.showImagePicker.toggle()
                    }
                    Button("라이브러리") {
                        self.sourceType = 1
                        self.showImagePicker.toggle()
                    }
                },
                message: {
                }
            )
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(isVisible: $showImagePicker, images: $selectedImages, sourceType: sourceType)
        }
    }
}

// 추가된 이미지 스크롤 뷰
struct ImageScrollView: View {
    @Binding var selectedImages: [UIImage]
    @Binding var showActionSheet: Bool
    @State var photoEditShowModal = false
    @State var index: Int = 0
    @State var selectedIndex: Int? = nil
    @State private var showingAlert = false
    @State var items: [String] = []
    @State var draggedItem : UIImage?
    
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ZStack {
                    Rectangle()
                        .fill(Color(hex: "EAEAEA"))
                        .cornerRadius(10)
                        .frame(width: 100, height: 100)
                    VStack {
                        if selectedImages.count >= 5 {
                            Button(action: {
                                self.showingAlert = true
                            }) {
                                Image(systemName: "camera.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                    .foregroundColor(.gray)
                                    .padding(10)
                            }
                            .alert(isPresented: $showingAlert) {
                                Alert(title: Text("알림"), message: Text("이미지는 최대 5장까지 첨부할 수 있습니다."),
                                      dismissButton: .default(Text("확인")))
                            }
                        } else {
                            CameraButton(showActionSheet: $showActionSheet)
                        }
                        HStack {
                            Text("\(selectedImages.count)")
                                .foregroundStyle(Color(hex:"59AAE0"))
                                .padding(.trailing, -3)
                            Text("/ 5")
                        }
                        .padding(.top, -15)
                    }
                    .frame(width: 80, height: 80) // 카메라 버튼 범위
                }
                ForEach(selectedImages.indices, id: \.self) { imageIndex in
                    let img = selectedImages[imageIndex]
                    ZStack {
                        ZStack {
                            ZStack {
                                Image(uiImage: img)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 100, height: 100)
                                    .onTapGesture {
                                        self.index = imageIndex
                                        photoEditShowModal = true
                                    }
                                    .onDrag({
                                        self.draggedItem = img
                                        return NSItemProvider(item: nil, typeIdentifier: String(imageIndex))
                                    })
                                    .onDrop(of: [UTType.image], delegate: ImageDropDelegate(item: img, items: $selectedImages, draggedItem: $draggedItem))
                                
                                if imageIndex == 0 {
                                    VStack {
                                        Spacer()
                                        ZStack {
                                            Rectangle()
                                                .fill(Color.black)
                                                .frame(height: 25)
                                            Text("대표사진")
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                            }
                            .cornerRadius(10)
                        }
                        .overlay {
                            ZStack {
                                DeleteImageButton(selectedImages: $selectedImages, items: $items, index: imageIndex)
                            }
                            .frame(width: 140, height: 140, alignment: .topTrailing) // Delete버튼 위치
                        }
                    } // ImageSet
                    .fullScreenCover(isPresented: $photoEditShowModal) {
                        ImageEditorModalView(selectedImages: $selectedImages, showImageEditorModal: $photoEditShowModal, index: $index)
                    }
                }
                .onChange(of: selectedImages) { newValue in
                    items.removeAll()
                    for i in selectedImages.indices {
                        items.append(String(i))
                    }
                }
            }
            .padding(.vertical, 20)
        }
    }
}

// 사진 편집 모달 뷰
struct ImageEditorModalView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedImages: [UIImage]
    @Binding var showImageEditorModal: Bool
    @Binding var index: Int
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "xmark")
                    .onTapGesture {
                        presentationMode.wrappedValue.dismiss()
                    }
                
                Spacer()
                
                Text("1/1")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button(action: {
                    // 완료 버튼 클릭 시 편집된 이미지 저장 후 모달 종료
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("완료")
                        .font(.headline)
                }
            }
        }
        .padding()
        
        // 모달창에 보여질 이미지
        Image(uiImage: selectedImages[index])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity,maxHeight: .infinity)
            .clipped()
    }
}

// 카메라 버튼
struct CameraButton: View {
    @Binding var showActionSheet: Bool
    
    var body: some View {
        Button(action: {
            self.showActionSheet = true
        }) {
            Image(systemName: "camera.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)
                .padding(10)
        }
    }
}

// 이미지 삭제 버튼
struct DeleteImageButton: View {
    @Binding var selectedImages: [UIImage]
    @Binding var items: [String]
    var index: Int
    
    var body: some View {
        ZStack {
            Image(systemName: "xmark.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.black)
                .frame(width: 25, height: 25)
        }
        .frame(width: 35, height: 35) // Delete버튼 범위
        .onTapGesture {
            if index < selectedImages.count {
                selectedImages.remove(at: index)
            }
        }
    }
}

struct ImageDropDelegate : DropDelegate {
    
    let item : UIImage
    @Binding var items : [UIImage]
    @Binding var draggedItem : UIImage?
    
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
    
    func dropEntered(info: DropInfo) {
        guard let draggedItem = self.draggedItem else {
            return
        }
        
        if draggedItem != item {
            let from = items.firstIndex(of: draggedItem)!
            let to = items.firstIndex(of: item)!
            withAnimation(.default) {
                self.items.move(fromOffsets: IndexSet(integer: from), toOffset: to > from ? to + 1 : to)
            }
        }
    }
}

#Preview {
    ChangePostingView()
}
