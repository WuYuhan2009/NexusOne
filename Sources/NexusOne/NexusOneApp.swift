import SwiftUI

@main
struct NexusOneApp: App {
    @StateObject private var permissionManager = PermissionManager.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if permissionManager.shouldShowOnboarding {
                    OnboardingFlowView()
                } else {
                    RootDashboardView()
                }
            }
            .preferredColorScheme(.dark)
            .task {
                await permissionManager.refreshFullDiskAccessStatus()
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
}
