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
}
