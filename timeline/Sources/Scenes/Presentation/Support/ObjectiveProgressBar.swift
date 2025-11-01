import SwiftUI

struct ObjectiveProgressBar: View {
    let progress: Double
    let color: Color
    private let minimumFilledWidth: CGFloat = 4

    var body: some View {
        GeometryReader { proxy in
            let clampedProgress = progress.clamped(to: 0...1)
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(Color.primary.opacity(0.06))
                Capsule(style: .continuous)
                    .fill(color.opacity(0.9))
                    .frame(width: max(proxy.size.width * clampedProgress, minimumFilledWidth))
            }
        }
        .frame(height: 10)
    }
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
