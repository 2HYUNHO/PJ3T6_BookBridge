//
//  SignInGoogleHelper.swift
//  BookBridge
//
//  Created by 이민호 on 1/25/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

class GoogleSignManager {
    @MainActor
    func signIn() async throws -> GoogleSignResultModel {
        guard let topVC = GoogleLoginViewController.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        let tokens = GoogleSignResultModel(idToken: idToken, accessToken: accessToken)
        return tokens
    }
}
