import ArgumentParser
import Foundation
import SwiftParser

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
        print(tree.description)
    }
}
