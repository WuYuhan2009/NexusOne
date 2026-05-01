import Foundation
import Security

@MainActor
final class PrivilegedHelper {
    static let shared = PrivilegedHelper()
    private init() {}

    @discardableResult
    func runPrivileged(command: String, arguments: [String]) -> (Int32, String) {
        let full = ([command] + arguments).map { $0.replacingOccurrences(of: "\"", with: "\\\"") }.joined(separator: " ")
        let script = "do shell script \"\(full)\" with administrator privileges"
        var error: NSDictionary?
        if let output = NSAppleScript(source: script)?.executeAndReturnError(&error).stringValue {
            return (0, output)
        }
        let message = (error?[NSAppleScript.errorMessage] as? String) ?? "Privileged command failed"
        return (1, message)
    }
}
