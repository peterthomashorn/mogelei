import ArgumentParser

@main
struct Mogelei: ParsableCommand {
    @Argument(help: "The source code file to scan for protocols.")
    var file: String

    mutating func run() throws {
        print("Should scan file: \(file)")
    }
}
