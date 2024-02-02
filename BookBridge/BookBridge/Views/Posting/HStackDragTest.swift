//
//  HStackDragTest.swift
//  BookBridge
//
//  Created by jmyeong on 2/1/24.
//

import SwiftUI
import UniformTypeIdentifiers

struct HStackDragTest: View {
    
    @State var imageNames = ["1.square.fill", "2.square.fill", "3.square.fill"]
    @State var items = ["0", "1", "2"]
    @State var draggedItem : String?
    
    
    var body: some View {
        LazyHStack(spacing: 20) {
                ForEach(items, id:\.self) { item in
                    Image(systemName: imageNames[Int(item) ?? 0])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .onDrag({
                            self.draggedItem = item
                            return NSItemProvider(item: nil, typeIdentifier: item)
                        }) 
                        .onDrop(of: [UTType.text], delegate: MyDropDelegate(item: item, items: $items, draggedItem: $draggedItem))
                }
            }
            .padding()
        }
    }


struct MyDropDelegate : DropDelegate {
    
    let item : String
    @Binding var items : [String]
    @Binding var draggedItem : String?
    
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
    HStackDragTest()
}
