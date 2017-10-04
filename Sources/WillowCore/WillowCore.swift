import Files
import Foundation

public class WillowCore {
    private let arguments: [String]

    public init(arguments: [String] = CommandLine.arguments) {
        self.arguments = arguments
    }

    public func run() throws {
        // Collect and verify the arguments
        let flags = Flags(arguments: arguments)
        if flags.help {
            Log.write(help)
            exit(Exit.success)
        } else if flags.version {
            Log.write(version)
            exit(Exit.success)
        } else if !flags.valid {
            Log.error(usage)
            exit(Exit.failure)
        }

        let lexer = Lexer()

        do {
            let expanded = NSString(string: flags.inputFile).expandingTildeInPath
            let file = try File(path: expanded, using: FileManager.default).readAsString()
            let tokens = try lexer.tokenize(file)

            // Create the output file
            let outputFile = try FileSystem().createFile(at: expanded.dropLast(3) + ".willowout")

            let output = tokens.reduce("") { $0 + $1.value }
            try outputFile.write(string: output)
        } catch let error {
            Log.error(error)
            exit(Exit.failure)
        }
    }
}