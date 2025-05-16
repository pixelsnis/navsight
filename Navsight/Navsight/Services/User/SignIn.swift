//
//  SignIn.swift
//  Navsight
//
//  Created by Aneesh on 14/5/25.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import SwiftUI

enum SignInService {
    static func signIn(as role: UserAccount.AccountRole) async throws {
        do {
            guard let rootViewController = await UIApplication.shared.keyWindow?.rootViewController else { return }
         
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken else { return }
            let accessToken = result.user.accessToken.tokenString
            
            guard let profile = result.user.profile else { return }
            
            try await Supabase.client.auth.signInWithIdToken(credentials: .init(provider: .google, idToken: idToken.tokenString, accessToken: accessToken))
            guard let userID = UserID.current else { return }
            
            let user: UserAccount = .init(id: userID, name: profile.name, email: profile.email, role: role, language: UserDefaults.standard.string(forKey: "language") ?? "en")
            try await Supabase.client.from("users").upsert(user).execute()
            
            if role == .guardian {
                _ = try await WardInfo.get()
            }
        } catch {
            throw error
        }
    }
}

extension UIApplication {
    var keyWindow: UIWindow? {
        // Get connected scenes
        return self.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}
