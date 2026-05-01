import SwiftUI

@MainActor
final class PermissionManager: ObservableObject {
    static let shared = PermissionManager()
    @Published var shouldShowOnboarding = true

    func refreshFullDiskAccessStatus() async {
        let testPath = ("~/Library/Application Support/com.apple.TCC/TCC.db" as NSString).expandingTildeInPath
        shouldShowOnboarding = !FileManager.default.isReadableFile(atPath: testPath)
    }
}

struct OnboardingFlowView: View {
    @State private var page = 0
    private let pages = ["欢迎使用 NexusOne", "功能全览", "风险警示与免责声明", "权限引导"]

    var body: some View {
        ZStack {
            LiquidAuroraBackground()
            VStack(spacing: 20) {
                TabView(selection: $page) {
                    ForEach(0..<4, id: \.self) { idx in
                        GlassCard {
                            VStack(spacing: 12) {
                                Text(pages[idx]).font(.largeTitle.bold())
                                Text(bodyForPage(idx)).multilineTextAlignment(.leading)
                            }
                        }
                        .padding()
                        .tag(idx)
                    }
                }
                HStack {
                    Button("上一步") { if page > 0 { page -= 1 } }
                    Spacer()
                    Button(page == 3 ? "完成" : "下一步") {
                        if page < 3 { page += 1 } else { PermissionManager.shared.shouldShowOnboarding = false }
                    }
                }.padding(.horizontal, 24)
            }
        }
    }

    private func bodyForPage(_ idx: Int) -> String {
        switch idx {
        case 0: return "NexusOne 是面向高级用户的一体化系统工具箱。"
        case 1: return "内建加速、修复、定制、硬件透视四大引擎。"
        case 2: return "请先备份数据。高权限操作可能影响系统稳定性。"
        default: return "请在 系统设置 > 隐私与安全性 > 完全磁盘访问权限 中授予本应用权限。"
        }
    }
}
