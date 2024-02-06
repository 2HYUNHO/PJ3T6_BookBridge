//
//  StorageManager.swift
//  BookBridge
//
//  Created by 이현호 on 1/29/24.
//

import Foundation
import Firebase
import FirebaseStorage
import PhotosUI


extension UIImage {
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}

// StorageImage 모델
struct StorageImage : Hashable {
    var name: String
    var fullPath: String
    var image: UIImage
    
    init(name: String, fullPath: String, image: UIImage) {
        self.name = name
        self.fullPath = fullPath
        self.image = image
    }
}


class StorageManager : ObservableObject{
    
    static let shared = StorageManager()
    private init() {}
    
    @Published var images: [StorageImage] = []
    let storage = Storage.storage()
    
    
    // Firebase의 listAll() 메서드를 사용하여 저장소의 모든 항목을 나열
    func listAllFiles() {
        // 이미지 폴더의 모든 파일을 나열
        let storageRef = storage.reference().child("images")
        
        storageRef.listAll { result, error in
            guard let result = result, error == nil else {
                return
            }
            
            self.images.removeAll()
            
            for item in result.items {
                print("Item in images forder:", item)
                print("Item in images fullPath:", item.fullPath)
                item.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    guard let data = data, let image = UIImage(data: data), error == nil else {
                        return
                    }
                    
                    self.images.append(
                        StorageImage(name: item.name, fullPath: item.fullPath, image: image))
                }
            }
            
        }
    }
    
    // 하나의 항목만 나열
    func listItem() {
        // 이미지 폴더의 모든 파일을 나열
        let storageRef = storage.reference().child("images")
        
        storageRef.list(maxResults: 1) { result, error in
            guard let result = result, error == nil else {
                return
            }
            
            self.images.removeAll()
            
            for item in result.items {
                print("Item in images forder:", item)
                print("Item in images fullPath:", item.fullPath)
                item.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    guard let data = data, let image = UIImage(data: data), error == nil else {
                        return
                    }
                    
                    self.images.append(
                        StorageImage(name: item.name, fullPath: item.fullPath, image: image))
                }
            }
            
        }
    }
    
    // 항목 삭제
    func deleteItem(fullPath: String) {
        let item = storage.reference().child( fullPath )
        item.delete { error in
            guard error == nil else {
                print("Error deleting item.", error!)
                return
            }
            
            for (index, item) in self.images.enumerated() where fullPath == item.fullPath {
                self.images.remove(at: index)
            }
        }
    }
    
    
}
