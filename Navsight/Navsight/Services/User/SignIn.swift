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

// Enum for managing the sign-in process
enum SignInService {
    // Function to initiate the sign-in process for a given role
    static func signIn(as role: UserAccount.AccountRole) async throws {
        do {
            // Retrieve the root view controller to present the sign-in flow
            guard let rootViewController = await UIApplication.shared.keyWindow?.rootViewController
            else { return }

            // Attempt to sign in with Google
            let result = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController)

            // Extract the ID token and access token from the sign-in result
            guard let idToken = result.user.idToken else { return }
            let accessToken = result.user.accessToken.tokenString

            // Extract the user profile from the sign-in result
            guard let profile = result.user.profile else { return }

            // Use the ID token and access token to sign in with Supabase
            try await Supabase.client.auth.signInWithIdToken(
                credentials: .init(
                    provider: .google, idToken: idToken.tokenString, accessToken: accessToken))

            // Retrieve the current user ID
            guard let userID = UserID.current else { return }

            // Create a new UserAccount instance with the retrieved data
            let user: UserAccount = .init(
                id: userID, name: profile.name, email: profile.email, role: role,
                language: UserDefaults.standard.string(forKey: "language") ?? "en")

            // Upsert the user into the database
            try await Supabase.client.from("users").upsert(user).execute()

            // If the user is a guardian, attempt to retrieve their ward information
            if role == .guardian {
                _ = try await WardInfo.get()
            }
        } catch {
            // Propagate any errors that occur during the sign-in process
            throw error
        }
    }
}

// Extension to UIApplication to find the key window
extension UIApplication {
    var keyWindow: UIWindow? {
        // This extension method finds the key window by filtering through connected scenes to find the first active, on-screen, and visible UIWindowScene, and then returns its key window.
        return self.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }

}
