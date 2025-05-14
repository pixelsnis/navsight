//
//  UserTypes.swift
//  Navsight
//
//  Created by Aneesh on 14/5/25.
//

import Foundation

struct UserAccount: Codable {
    enum AccountRole: String, Codable {
        case ward = "ward", guardian = "guardian"
    }
    
    private(set) var id: UUID
    var name: String
    var email: String
    var role: AccountRole
    var guardian: UUID?
    var language: String
    
    init(id: UUID = UUID(), name: String, email: String, role: AccountRole, guardian: UUID? = nil, language: String) {
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.guardian = guardian
        self.language = language
    }
}

struct GuardianInvite: Codable {
    private(set) var id: UUID
    private(set) var sender: UUID
    var accepted: Bool
    var created: Date
    
    init(id: UUID = UUID(), sender: UUID, accepted: Bool, created: Date = .now) {
        self.id = id
        self.sender = sender
        self.accepted = accepted
        self.created = created
    }
}
