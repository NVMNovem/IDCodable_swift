//
//  IDCodableError.swift
//  IDCodable
//
//  Created by Damian Van de Kauter on 04/08/2024.
//

import Foundation

enum IDCodableError: Error {
    case empty
    case invalidValue
}

extension IDCodableError: LocalizedError {
    var errorCode: Int {
        switch self {
        case .empty:
            return 0
        case .invalidValue:
            return 1
        }
    }
}
