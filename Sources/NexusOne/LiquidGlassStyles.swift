import SwiftUI

struct LiquidAuroraBackground: View {
    @State private var phase: CGFloat = 0.0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 24.0)) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            MeshGradient(width: 3, height: 3, points: [
                SIMD2<Float>(0, 0),
                SIMD2<Float>(0.5 + Float(sin(t * 0.12)) * 0.12, 0),
                SIMD2<Float>(1, 0.1 + Float(cos(t * 0.10)) * 0.08),
                SIMD2<Float>(0, 0.5 + Float(cos(t * 0.18)) * 0.12),
                SIMD2<Float>(0.5, 0.5),
                SIMD2<Float>(1, 0.5 + Float(sin(t * 0.16)) * 0.10),
                SIMD2<Float>(0.1 + Float(sin(t * 0.14)) * 0.10, 1),
                SIMD2<Float>(0.5 + Float(cos(t * 0.09)) * 0.14, 1),
                SIMD2<Float>(1, 1)
            ], colors: [
                .indigo, .cyan, .mint,
                .blue, .teal, .purple,
                .black, .blue.opacity(0.8), .cyan
            ])
            .ignoresSafeArea()
            .overlay(Color.black.opacity(0.20).ignoresSafeArea())
        }
    }
}

struct GlassCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(0.30), lineWidth: 1)
            }
            .shadow(color: .cyan.opacity(0.22), radius: 20, x: 0, y: 8)
            .shadow(color: .black.opacity(0.30), radius: 12, x: 0, y: 6)
            .innerShadow()
    }
}

private extension View {
    func innerShadow() -> some View {
        self.overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.22), lineWidth: 1)
                .blur(radius: 1)
                .offset(x: -1, y: -1)
                .mask(RoundedRectangle(cornerRadius: 24, style: .continuous).fill(LinearGradient(colors: [.white, .clear], startPoint: .topLeading, endPoint: .bottomTrailing)))
        }
    }
}
