//
//  MacroHelpers.swift
//  IDCodable
//
//  Created by Damian Van de Kauter on 04/08/2024.
//

import SwiftSyntax
import SwiftSyntaxBuilder

internal extension EnumCaseDeclSyntax {
    
    func getAttributeSyntax(for name: String) -> AttributeSyntax? {
        return self.attributes
            .compactMap({ $0.as(AttributeSyntax.self) })
            .first(where: { $0.attributeName.as(IdentifierTypeSyntax.self)?.name.text == name })
    }
}

internal extension EnumCaseDeclSyntax {
    
    var element: EnumCaseElementSyntax? {
        return self.elements.first
    }
}

internal extension ExprSyntaxProtocol {
    
    func getType() -> String? {
        if self.is(BooleanLiteralExprSyntax.self)  {
            return "Bool"
        } else if self.is(StringLiteralExprSyntax.self) {
            return "String"
        } else if self.is(IntegerLiteralExprSyntax.self) {
            return "Int"
        } else if self.is(FloatLiteralExprSyntax.self) {
            return "Float"
        } else {
            return nil
        }
    }
}
