import SwiftUI

public extension View {
    func squareFrame(_ squareSide: CGFloat) -> some View {
        frame(width: squareSide, height: squareSide)
    }
}

extension CGRect {
    func offset(by off: CGSize) -> CGRect {
        offsetBy(dx: off.width, dy: off.height)
    }
}

extension View {
    func enabledState(_ isEnabled: Bool) -> some View {
        self.opacity(isEnabled ? 1.0 : 0.5)
    }
}
