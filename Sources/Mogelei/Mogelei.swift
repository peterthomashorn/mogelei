import ArgumentParser
import Foundation
import SwiftParser
import SwiftSyntax
import SwiftSyntaxBuilder

enum MogeleiError: Error {
    case dataRetrieval
    case stringConversion
}

@main
struct Mogelei: ParsableCommand {
    @Argument(help: "The source code file to scan for protocols.")
    var file: String

    mutating func run() throws {
        guard let data = FileManager.default.contents(atPath: file) else {
            throw MogeleiError.dataRetrieval
        }

        guard let code = String(data: data, encoding: .utf8) else {
            throw MogeleiError.stringConversion
        }

        let tree = Parser.parse(source: code)
        var declarations = [ProtocolDeclSyntax]()

        for statement in tree.statements {
            guard let declaration = statement.item.as(ProtocolDeclSyntax.self) else {
                continue
            }

            declarations.append(declaration)
        }

        let mockCode = SwiftSyntaxBuilder.SourceFile {
            for declaration in declarations {
                ClassDecl(identifier: "\(declaration.identifier.text)Mock") {
                    for member in declaration.members.members {
                        if let function = member.decl.as(FunctionDeclSyntax.self) {
                            let callCountVariableName = "\(function.identifier.text)Called"
                            VariableDecl(stringLiteral: "var \(callCountVariableName) = false")

                            FunctionDecl(
                                identifier: function.identifier,
                                signature: function.signature
                            ) {
                                SequenceExpr() {
                                    ExprList() {
                                        IdentifierExpr(stringLiteral: callCountVariableName)
                                        AssignmentExpr(assignToken: Token.equal)
                                        BooleanLiteralExpr(booleanLiteral: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        print(mockCode.formatted().description)
    }
}
