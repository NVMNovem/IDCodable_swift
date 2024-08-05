//
//  IDCodableHelpers.swift
//  IDCodable
//
//  Created by Damian Van de Kauter on 04/08/2024.
//

import SwiftSyntax
import SwiftSyntaxBuilder

internal extension EnumCaseDeclSyntax {
    
    var idAttributeExpression: ExprSyntax? {
        guard let attributeArguments = self.getAttributeSyntax(for: "Codable") else { return nil }
        guard let erpKeyExpr = attributeArguments.arguments?.as(LabeledExprListSyntax.self)?
            .first(where: { $0.label?.identifier?.name == "id" })
        else { return nil }
        
        return erpKeyExpr.expression
    }
    
    var codableAttributeExpression: ExprSyntax? {
        guard let attributeArguments = self.getAttributeSyntax(for: "Codable") else { return nil }
        guard let codingKeyExpr = attributeArguments.arguments?.as(LabeledExprListSyntax.self)?
            .first(where: { $0.label?.identifier?.name == "codable" })
        else { return nil }
        
        return codingKeyExpr.expression
    }
}
