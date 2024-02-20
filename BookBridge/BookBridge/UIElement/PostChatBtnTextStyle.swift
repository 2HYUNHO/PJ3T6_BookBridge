//
//  PostChatBtnTextStyle.swift
//  BookBridge
//
//  Created by 이민호 on 2/21/24.
//

import Foundation
import SwiftUI

struct PostChatBtnTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(Color.white)
            .frame(width: UIScreen.main.bounds.width, height: 57, alignment: Alignment.center)
            .background(Color(hex: "59AAE0"))
            .padding(1)
    }
}
