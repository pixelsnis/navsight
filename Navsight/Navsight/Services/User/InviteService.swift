//
//  InviteService.swift
//  Navsight
//
//  Created by Aneesh on 14/5/25.
//

import Foundation
import QRCode
import SwiftUI

@Observable
class InviteService {
    enum Status {
        case pending, accepted
    }
    
    var status: Status = .pending
    private(set) var invite: GuardianInvite? = nil
    
    func getQRCode() -> UIImage? {
        guard let inviteID = invite?.id else { return nil }
        
        guard let image = try? QRCode.build
            .text(inviteID.uuidString)
            .onPixels.shape(.circle())
            .eye.shape(.surroundingBars())
            .quietZonePixelCount(3)
            .foregroundColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
            .backgroundColor(CGColor(gray: 0, alpha: 0)) // Clear BG
            .generate.image(dimension: 512, representation: .png()) else { return nil }
        
        return UIImage(data: image)
    }
    
    func create() async throws {
        guard let userID = UserID.current else { throw "User not signed in" }
        
        // Check if there's an existing invite created by the user
        if let inviteData: Data = UserDefaults.standard.data(forKey: "invite"), let invite = try? JSONDecoder().decode(GuardianInvite.self, from: inviteData) {
            self.invite = invite
            return
        }
        
        let inv: GuardianInvite = .init(sender: userID, accepted: false)
        try await Supabase.client.from("invites").insert(inv).execute()
        
        self.invite = inv
    }
    
    static func accept(id: UUID) async throws {
        guard let userID = UserID.current else { throw "User not authenticated" }
        
        let endpoint = URL(string: "https://navsight-api.aneesh-30e.workers.dev/invites")!
        
        var request: URLRequest = .init(url: endpoint)
        try request.authenticate()
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let acceptRequest: InviteAcceptRequest = .init(inviteID: id.uuidString, userID: userID.uuidString)
        request.httpBody = try JSONEncoder().encode(acceptRequest)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else { throw "Response was not a valid HTTPURLResponse" }
        
        if (httpResponse.statusCode == 409) { throw "Invite already accepted by someone else" }
        else if (httpResponse.statusCode == 404) { throw "Invite not found" }
        
        guard httpResponse.statusCode == 200 else {
            let error = String(data: data, encoding: .utf8)
            throw error ?? "Unknown error"
        }
    }
    
    static func updateSelfWithGuardianID() async throws {
        guard let userID = UserID.current else { throw "User not signed in" }
        
        let queryResult: [UserAccount] = try await Supabase.client.from("users").select().eq("id", value: userID).execute().value
        
        guard let userAccount = queryResult.first else { throw "User account not found" }
        
        UserDefaults.standard.set(try JSONEncoder().encode(userAccount), forKey: "account")
    }
}

extension InviteService {
    struct InviteAcceptRequest: Codable {
        var inviteID: String
        var userID: String
        
        init(inviteID: String, userID: String) {
            self.inviteID = inviteID
            self.userID = userID
        }
        
        enum CodingKeys: String, CodingKey {
            case inviteID = "invite_id", userID = "user_id"
        }
    }
}
