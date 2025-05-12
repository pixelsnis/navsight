//
//  StringToError.swift
//  Navsight
//
//  Created by Aneesh on 11/5/25.
//

import Foundation

extension String: @retroactive Error {}
extension String: @retroactive LocalizedError {
    public var errorDescription: String? { return self }
}

