//
//  IDCodable.swift
//  Funico Scheduler
//
//  Created by Damian Van de Kauter on 04/08/2024.
//

import Foundation

@attached(extension, conformances: IDCodable, names: named(CodableType), named(init), named(id), named(codable))
@attached(member, names: arbitrary)
public macro IDCodable() = #externalMacro(
    module: "IDCodableMacros",
    type: "IDCodableMacro"
)

@attached(peer)
public macro Codable<C: Swift.Codable>(id: String, codable: C) = #externalMacro(
    module: "IDCodableMacros",
    type: "CodableMacro"
)

//MARK: - Protocol

/// A protocol that makes the
///
/// This protocol conforms to `RawRepresentable<String>`.
/// This makes each `enum` being stored on it's `id`.
///
public protocol IDCodable: RawRepresentable<String>, Codable, Identifiable<String>, Hashable {
    
    associatedtype CodableType: Codable, Equatable, CustomStringConvertible
    
    init?(id: String)
    init?(codable: CodableType)
    
    var id: String { get }
    var codable: CodableType { get }
}

/// This protocol conforms to `RawRepresentable<String>`.
/// This makes each `enum` being stored on it's `id`.
///
public extension IDCodable {
    
    var rawValue: String {
        return self.id
    }
    
    init?(rawValue: String) {
        guard let idInit = Self.init(id: rawValue) else { return nil }
        self = idInit
    }
}

public extension IDCodable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        switch decoder.idCodableType {
        case .codable:
            let codableType = try container.decode(CodableType.self)
            
            if let stringType = codableType as? String, stringType.isEmpty {
                throw IDCodableError.empty
            } else {
                guard let codableInit = Self(codable: codableType) else {
                    throw IDCodableError.invalidValue
                }
                
                self = codableInit
            }
        default:
            let codableType = try container.decode(String.self)
            
            if codableType.isEmpty {
                throw IDCodableError.empty
            } else {
                guard let idInit = Self(id: codableType) else {
                    throw IDCodableError.invalidValue
                }
                
                self = idInit
            }
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch encoder.idCodableType {
        case .codable:
            try container.encode(codable)
        default:
            try container.encode(id)
        }
    }
}

public enum IDCodableType: Codable {
    case id
    case codable
}

public extension CodingUserInfoKey {
    static let idCodableType = CodingUserInfoKey(rawValue: "IDCodableType")!
}

public extension Decoder {
    
    var idCodableType: IDCodableType? {
        return self.userInfo[.idCodableType] as? IDCodableType
    }
}

public extension Encoder {
    
    var idCodableType: IDCodableType? {
        return self.userInfo[.idCodableType] as? IDCodableType
    }
}
