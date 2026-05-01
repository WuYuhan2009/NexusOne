import Foundation
import IOKit.ps

@MainActor
final class CommandEngine: ObservableObject {
    static let shared = CommandEngine()
    @Published var lastOutput = ""
    private init() {}

    private let safeRoots = ["/Users", "/Library/Caches", "/var/folders", "/private/var/folders", "/etc/hosts"]

    private func validatePath(_ path: String) -> Bool {
        let expanded = (path as NSString).expandingTildeInPath
        return safeRoots.contains { expanded == $0 || expanded.hasPrefix($0 + "/") }
    }

    private func run(_ launchPath: String, _ args: [String], privileged: Bool = false) -> String {
        if privileged {
            let result = PrivilegedHelper.shared.runPrivileged(command: launchPath, arguments: args)
            return result.1
        }
        let p = Process()
        p.executableURL = URL(fileURLWithPath: launchPath)
        p.arguments = args
        let pipe = Pipe()
        p.standardOutput = pipe
        p.standardError = pipe
        do {
            try p.run(); p.waitUntilExit()
            return String(data: pipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
        } catch { return error.localizedDescription }
    }

    func universalCacheWipe() -> String {
        let targets = ["~/Library/Caches", "/Library/Caches", "/var/folders"]
        for t in targets where !validatePath(t) { return "Unsafe path rejected: \(t)" }
        let script = "for d in \"$HOME/Library/Caches\" \"/Library/Caches\" \"/var/folders\"; do /usr/bin/find \"$d\" -mindepth 1 -maxdepth 8 -exec /bin/rm -rf {} +; done"
        return run("/bin/zsh", ["-lc", script], privileged: true)
    }

    func xcodeProClean() -> String {
        let script = "/bin/rm -rf \"$HOME/Library/Developer/Xcode/DerivedData\"/* \"$HOME/Library/Developer/CoreSimulator/Devices\"/*/data/Library/Logs/* \"$HOME/Library/Developer/Xcode/iOS DeviceSupport\"/*"
        return run("/bin/zsh", ["-lc", script], privileged: false)
    }

    func ramPurge() -> String { run("/usr/bin/memory_pressure", ["-S", "-l", "critical"], privileged: true) }
    func spotlightRebuild() -> String { run("/usr/bin/mdutil", ["-Ea", "/"], privileged: true) }
    func iconCacheReset() -> String { run("/bin/zsh", ["-lc", "/bin/rm -rf /Library/Caches/com.apple.iconservices.store; /usr/bin/killall Dock Finder"], privileged: true) }
    func dnsFlush() -> String { run("/bin/zsh", ["-lc", "/usr/bin/killall -HUP mDNSResponder; /usr/bin/killall discoveryutil || true"], privileged: true) }

    func readHosts() -> String { run("/bin/cat", ["/etc/hosts"], privileged: true) }
    func writeHosts(_ content: String) -> String {
        let escaped = content.replacingOccurrences(of: "\\", with: "\\\\").replacingOccurrences(of: "\"", with: "\\\"")
        return run("/bin/zsh", ["-lc", "printf \"\(escaped)\" > /tmp/nexusone_hosts && /bin/cp /tmp/nexusone_hosts /etc/hosts && /bin/chmod 644 /etc/hosts"], privileged: true)
    }

    func setDockOverdrive(hideImmediate: Bool, recentApps: Bool) -> String {
        let speed = hideImmediate ? "0" : "0.2"
        return run("/bin/zsh", ["-lc", "/usr/bin/defaults write com.apple.dock autohide-time-modifier -float \(speed); /usr/bin/defaults write com.apple.dock show-recents -bool \(recentApps ? "true" : "false"); /usr/bin/killall Dock"], privileged: false)
    }

    func setScreenshot(format: String, path: String) -> String {
        let p = (path as NSString).expandingTildeInPath
        let cmd = "/usr/bin/defaults write com.apple.screencapture type \(format.lowercased()); /usr/bin/defaults write com.apple.screencapture location \"\(p)\"; /usr/bin/killall SystemUIServer"
        return run("/bin/zsh", ["-lc", cmd])
    }

    func toggleHiddenFiles(show: Bool) -> String { run("/bin/zsh", ["-lc", "/usr/bin/defaults write com.apple.finder AppleShowAllFiles -bool \(show ? "true" : "false"); /usr/bin/killall Finder"]) }
    func setLoginAudio(enabled: Bool) -> String { run("/usr/sbin/nvram", ["SystemAudioVolume=\(enabled ? "%80" : "%00")"], privileged: true) }

    func batteryLab() -> String {
        guard let snapshot = IOPSCopyPowerSourcesInfo()?.takeRetainedValue(), let list = IOPSCopyPowerSourcesList(snapshot)?.takeRetainedValue() as? [CFTypeRef], let source = list.first, let detail = IOPSGetPowerSourceDescription(snapshot, source)?.takeUnretainedValue() as? [String: Any] else { return "Battery data unavailable" }
        let cycle = detail["CycleCount"] ?? detail["AppleRawCurrentCapacity"] ?? "n/a"
        let max = detail[kIOPSMaxCapacityKey as String] ?? detail["DesignCapacity"] ?? 0
        let current = detail[kIOPSCurrentCapacityKey as String] ?? detail["AppleRawCurrentCapacity"] ?? 0
        let watts = detail[kIOPSPowerSourceStateKey as String] ?? detail["BatteryHealth"] ?? "n/a"
        return "Cycle: \(cycle)\nCurrent/Max: \(current)/\(max)\nState: \(watts)"
    }

    func ssdWear() -> String { run("/bin/zsh", ["-lc", "which smartctl >/dev/null || (echo 'smartmontools missing'; exit 0); smartctl -a disk0 | egrep 'Data Units Written|Total_LBAs_Written'"], privileged: true) }
}
