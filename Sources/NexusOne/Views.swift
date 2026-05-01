import SwiftUI

struct RootDashboardView: View {
    @StateObject private var engine = CommandEngine.shared
    @State private var hosts = ""
    @State private var showHidden = false

    var body: some View {
        NavigationSplitView {
            List {
                Label("加速", systemImage: "bolt.fill")
                Label("修复", systemImage: "wrench.and.screwdriver.fill")
                Label("定制", systemImage: "paintbrush.fill")
                Label("硬件", systemImage: "cpu.fill")
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
        } detail: {
            ZStack {
                LiquidAuroraBackground()
                ScrollView {
                    VStack(spacing: 16) {
                        GlassCard { VStack(alignment: .leading) {
                            Text("系统深度加速").font(.title2.bold())
                            Button("Universal Cache Wipe") { engine.lastOutput = engine.universalCacheWipe() }
                            Button("Xcode Pro Clean") { engine.lastOutput = engine.xcodeProClean() }
                            Button("RAM Purge") { engine.lastOutput = engine.ramPurge() }
                        }}
                        GlassCard { VStack(alignment: .leading) {
                            Text("系统修复大师").font(.title2.bold())
                            Button("读取 Hosts") { hosts = engine.readHosts() }
                            TextEditor(text: $hosts).frame(minHeight: 120)
                            Button("写回 Hosts") { engine.lastOutput = engine.writeHosts(hosts) }
                            Button("Spotlight Rebuild") { engine.lastOutput = engine.spotlightRebuild() }
                            Button("Icon Cache Reset") { engine.lastOutput = engine.iconCacheReset() }
                            Button("DNS Flush") { engine.lastOutput = engine.dnsFlush() }
                        }}
                        GlassCard { VStack(alignment: .leading) {
                            Text("深度定制").font(.title2.bold())
                            Button("Dock Overdrive") { engine.lastOutput = engine.setDockOverdrive(hideImmediate: true, recentApps: false) }
                            Button("截图改为 PNG 到桌面") { engine.lastOutput = engine.setScreenshot(format: "png", path: "~/Desktop") }
                            Toggle("显示隐藏文件", isOn: $showHidden).onChange(of: showHidden) { _, v in engine.lastOutput = engine.toggleHiddenFiles(show: v) }
                            Button("禁用开机音") { engine.lastOutput = engine.setLoginAudio(enabled: false) }
                        }}
                        GlassCard { VStack(alignment: .leading) {
                            Text("硬件透视").font(.title2.bold())
                            Button("Battery Lab") { engine.lastOutput = engine.batteryLab() }
                            Button("SSD Wear") { engine.lastOutput = engine.ssdWear() }
                        }}
                        GlassCard { Text(engine.lastOutput).font(.system(.footnote, design: .monospaced)).frame(maxWidth: .infinity, alignment: .leading) }
                    }.padding(20)
                }
            }
        }
    }
}
