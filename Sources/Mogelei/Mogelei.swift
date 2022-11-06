import ArgumentParser
import Foundation
import SwiftParser
import SwiftSyntax

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
            print("Found declaration of: \(declaration.identifier)")
        }
    }
}
