//
//  SignIn.swift
//  Navsight
//
//  Created by Aneesh on 14/5/25.
//

import AuthenticationServices
import Foundation

enum SignInService {
    struct CreateAccountRequest {
        var name: String
        var email: String
        var role: UserAccount.AccountRole
    }
    
    static func signIn(_ result: Result<ASAuthorization, any Error>, as role: UserAccount.AccountRole) async throws {
        do {
            guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential else { return }
            
            guard let idToken = credential.identityToken.flatMap({ String(data: $0, encoding: .utf8 )}) else { return }
            
            try await Supabase.client.auth.signInWithIdToken(credentials: .init(provider: .apple, idToken: idToken))
            
            var accountRequest: CreateAccountRequest? = nil
            
            if let fullName = credential.fullName, let email = credential.email {
                accountRequest = .init(name: fullName.formatted(), email: email, role: role)
            }
            
            try await signIntoAccount(creating: accountRequest)
        } catch {
            throw error
        }
    }
    
    static private func signIntoAccount(creating account: CreateAccountRequest? = nil) async throws {
        guard let userID = UserID.current else { throw "User not signed in "}
        
        if let account {
            let userAccount: UserAccount = .init(id: userID, name: account.name, email: account.email, role: account.role, language: UserDefaults.standard.string(forKey: "language") ?? "en")
            
            try await Supabase.client.from("users").insert(userAccount).execute()
            UserDefaults.standard.set(try JSONEncoder().encode(userAccount), forKey: "account")
            
            return
        }
        
        let queryResult: [UserAccount] = try await Supabase.client.from("users").select().eq("id", value: userID).execute().value
        guard let acc = queryResult.first else { throw "Account not found" }
        
        UserDefaults.standard.set(try JSONEncoder().encode(acc), forKey: "account")
    }
}
