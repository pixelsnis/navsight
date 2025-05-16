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

    // Function to generate a QR code for the invite
    func getQRCode() -> UIImage? {
        // Ensure an invite ID is available to generate the QR code
        guard let inviteID = invite?.id else { return nil }

        // Attempt to generate the QR code with specific design parameters
        guard
            let image = try? QRCode.build
                .text(inviteID.uuidString)  // Set the QR code text to the invite ID
                .onPixels.shape(.circle())  // Set the shape of the QR code pixels to a circle
                .eye.shape(.surroundingBars())  // Set the shape of the QR code eyes to surrounding bars
                .quietZonePixelCount(3)  // Set the quiet zone pixel count to 3
                .foregroundColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))  // Set the foreground color to black
                .backgroundColor(CGColor(gray: 0, alpha: 0))  // Set the background color to clear
                .generate.image(dimension: 512, representation: .png())
        else { return nil }  // Generate the QR code image with a dimension of 512 and PNG representation

        // Convert the generated image data to a UIImage
        return UIImage(data: image)
    }

    // Function to create a new invite asynchronously
    func create() async throws {
        // Ensure the current user ID is available
        guard let userID = UserID.current else { throw "User not signed in" }

        // Check if there's an existing invite created by the user
        if let inviteData: Data = UserDefaults.standard.data(forKey: "invite"),
            let invite = try? JSONDecoder().decode(GuardianInvite.self, from: inviteData)
        {
            // If an existing invite is found, set it as the current invite and exit
            self.invite = invite
            return
        }

        // Create a new invite with the current user as the sender and accepted status as false
        let inv: GuardianInvite = .init(sender: userID, accepted: false)
        // Attempt to insert the new invite into the database asynchronously
        try await Supabase.client.from("invites").insert(inv).execute()

        // Set the newly created invite as the current invite
        self.invite = inv
    }

    // Static function to accept an invite asynchronously
    static func accept(id: UUID) async throws {
        // Ensure the current user ID is available
        guard let userID = UserID.current else { throw "User not authenticated" }

        // Define the endpoint URL for accepting invites
        let endpoint = URL(string: "https://navsight-api.aneesh-30e.workers.dev/invites")!

        // Prepare a URLRequest for the endpoint
        var request: URLRequest = .init(url: endpoint)
        // Attempt to authenticate the request
        try request.authenticate()

        // Set the request method to POST and the content type to JSON
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Prepare the accept request with the invite ID and user ID
        let acceptRequest: InviteAcceptRequest = .init(
            inviteID: id.uuidString, userID: userID.uuidString)
        // Encode the accept request into JSON and set it as the request body
        request.httpBody = try JSONEncoder().encode(acceptRequest)

        // Attempt to send the request and get the response data asynchronously
        let (data, response) = try await URLSession.shared.data(for: request)
        // Ensure the response is a valid HTTPURLResponse
        guard let httpResponse = response as? HTTPURLResponse else {
            throw "Response was not a valid HTTPURLResponse"
        }

        // Handle different response status codes
        if httpResponse.statusCode == 409 {
            throw "Invite already accepted by someone else"
        } else if httpResponse.statusCode == 404 {
            throw "Invite not found"
        }

        // If the response status code is not 200, throw an error with the response data
        guard httpResponse.statusCode == 200 else {
            let error = String(data: data, encoding: .utf8)
            throw error ?? "Unknown error"
        }
    }

    // Static function to update the user account with the guardian ID asynchronously
    static func updateSelfWithGuardianID() async throws {
        // Ensure the current user ID is available
        guard let userID = UserID.current else { throw "User not signed in" }

        // Attempt to query the user account with the current user ID asynchronously
        let queryResult: [UserAccount] = try await Supabase.client.from("users").select().eq(
            "id", value: userID
        ).execute().value

        // Ensure a user account is found
        guard let userAccount = queryResult.first else { throw "User account not found" }

        // Encode the user account into JSON and store it in UserDefaults
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
            case inviteID = "invite_id"
            case userID = "user_id"
        }
    }
}
