import Foundation
import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct IDCodableMacro: ExtensionMacro, MemberMacro {
    
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            //TODO: Emit an error here
            return []
        }
        
        let enumCaseDecles = enumDecl.memberBlock.members.compactMap({ $0.decl.as(EnumCaseDeclSyntax.self) })
        let caseTypes = enumCaseDecles.compactMap({ $0.codableAttributeExpression })
        //let type = (pattern.typeAnnotation?.as(TypeAnnotationSyntax.self))?.type
        guard let caseType = caseTypes.first?.getType() else {
            //TODO: Emit an error here
            return []
        }
        
        let idInitializer = try InitializerDeclSyntax("init?(id: String)") {
            try SwitchExprSyntax("switch id") {
                for enumCaseDecl in enumCaseDecles {
                    for enumCaseElement in enumCaseDecl.elements {
                        let identifier = enumCaseElement.name
                        if let id = enumCaseDecl.idAttributeExpression {
                            """
                            case \(id.trimmed): self = .\(identifier)
                            """
                        }
                    }
                }
                """
                default: return nil
                """
            }
        }
        let idVariable = try VariableDeclSyntax("var id: String") {
            try SwitchExprSyntax("switch self") {
                for enumCaseDecl in enumCaseDecles {
                    for enumCaseElement in enumCaseDecl.elements {
                        let identifier = enumCaseElement.name
                        if let id = enumCaseDecl.idAttributeExpression {
                            """
                            case .\(identifier): return \(id.trimmed)
                            """
                        }
                    }
                }
            }
        }
        
        let codableInitializer = try InitializerDeclSyntax("init?(codable: \(raw: caseType))") {
            try SwitchExprSyntax("switch codable") {
                for enumCaseDecl in enumCaseDecles {
                    for enumCaseElement in enumCaseDecl.elements {
                        let identifier = enumCaseElement.name
                        if let codable = enumCaseDecl.codableAttributeExpression {
                            """
                            case \(codable.trimmed): self = .\(identifier)
                            """
                        }
                    }
                }
                """
                default: return nil
                """
            }
        }
        let codableVariable = try VariableDeclSyntax("var codable: \(raw: caseType)") {
            try SwitchExprSyntax("switch self") {
                for enumCaseDecl in enumCaseDecles {
                    for enumCaseElement in enumCaseDecl.elements {
                        let identifier = enumCaseElement.name
                        if let codable = enumCaseDecl.codableAttributeExpression {
                            """
                            case .\(identifier): return \(codable.trimmed)
                            """
                        }
                    }
                }
            }
        }
        
        let idCodableExtension = try ExtensionDeclSyntax("extension \(type.trimmed): IDCodable") {
            """
            typealias CodableType = \(raw: caseType)
            """
            idInitializer
            idVariable
            codableInitializer
            codableVariable
        }
        
        return [
            idCodableExtension
        ]
    }
    
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDecl = declaration.as(EnumDeclSyntax.self) else {
            //TODO: Emit an error here
            return []
        }
        return []
    }
}

enum CodableMacro: PeerMacro {
    static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

enum ERPModelDiagnostic: DiagnosticMessage {
    
    case missingPrefix(String)
    
    var severity: DiagnosticSeverity {
        switch self {
        case .missingPrefix: return .warning
        }
    }
    
    var message: String {
        switch self {
        case .missingPrefix(let prefix):
            return "It is recommended to add '\(prefix)' as a prefix to your struct"
        }
    }
    
    var diagnosticID: MessageID {
        switch self {
        case .missingPrefix:
            return MessageID(domain: "ERPModel", id: "missingPrefix")
        }
    }
    
    func fixits(from declaration: some DeclGroupSyntax) -> [FixIt] {
        switch self {
        case .missingPrefix(let prefix):
            if var newDeclaration = declaration.as(StructDeclSyntax.self) {
                let oldName = newDeclaration.name
                let newNameText = prefix + oldName.text
                
                newDeclaration.name = .identifier(
                    newNameText, leadingTrivia: oldName.leadingTrivia, trailingTrivia: oldName.trailingTrivia, presence: oldName.presence
                )
                
                return [
                    FixIt(message: ERPModelFixit("Add '\(prefix)' as prefix", diagnostic: self),
                          changes: [.replace(oldNode: declaration._syntaxNode, newNode: newDeclaration._syntaxNode)])
                ]
            }
            return []
        }
    }
}

struct ERPModelFixit: FixItMessage {
    var message: String
    var fixItID: MessageID
    
    init(_ message: String, diagnostic: DiagnosticMessage) {
        self.message = message
        self.fixItID = diagnostic.diagnosticID
    }
}

@main
struct IDCodablePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        IDCodableMacro.self,
        CodableMacro.self
    ]
}
