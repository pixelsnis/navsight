//
//  UserIDProvider.swift
//  Navsight
//
//  Created by Aneesh on 14/5/25.
//

import Foundation

enum UserID {
    static var current: UUID? {
        Supabase.client.auth.currentUser?.id
    }
}
