import SwiftUI

/// Knob in which you start by tapping in its bound and change the value by either horizontal or vertical motion
public struct SmallKnob: View {
    @Binding var value: Float
    var range: ClosedRange<Float> = 0.0 ... 1.0

    var backgroundColor: Color = .gray
    var foregroundColor: Color = .black

    @Environment(\.isEnabled) private var isEnabled: Bool

    /// Initialize the knob with a bound value and range
    /// - Parameters:
    ///   - value: value being controlled
    ///   - range: range of the value
    public init(value: Binding<Float>, range: ClosedRange<Float> = 0.0 ... 1.0) {
        _value = value
        self.range = range
    }

    var normalizedValue: Double {
        Double((value - range.lowerBound) / (range.upperBound - range.lowerBound))
    }

    var offsetX: CGFloat {
        -sin(normalizedValue * 1.6 * .pi + 0.2 * .pi) / 2.0 * 0.75
    }

    var offsetY: CGFloat {
        cos(normalizedValue * 1.6 * .pi + 0.2 * .pi) / 2.0 * 0.75
    }


    public var body: some View {
        Control(value: $value, in: range,
                geometry: .twoDimensionalDrag(xSensitivity: 1, ySensitivity: 1)) { geo in
            ZStack(alignment: .center) {
                Ellipse().foregroundColor(backgroundColor)
                Rectangle().foregroundColor(foregroundColor)
                    .frame(width: geo.size.width / 20, height: geo.size.height / 4)
                    .rotationEffect(Angle(radians: normalizedValue * 1.6 * .pi + 0.2 * .pi))
                    .offset(x: offsetX * Double(geo.size.width), y: offsetY * Double(geo.size.height))
            }.drawingGroup() // Drawing groups improve antialiasing of rotated indicator
        }
                .enabledState(isEnabled)
                .aspectRatio(CGSize(width: 1, height: 1), contentMode: .fit)

    }
}


extension SmallKnob {
    /// Modifier to change the background color of the knob
    /// - Parameter backgroundColor: background color
    public func backgroundColor(_ backgroundColor: Color) -> SmallKnob {
        var copy = self
        copy.backgroundColor = backgroundColor
        return copy
    }

    /// Modifier to change the foreground color of the knob
    /// - Parameter foregroundColor: foreground color
    public func foregroundColor(_ foregroundColor: Color) -> SmallKnob {
        var copy = self
        copy.foregroundColor = foregroundColor
        return copy
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var value: Float = 0.5
        @State private var isDisabled: Bool = false

        var body: some View {
            Toggle("Disable?", isOn: $isDisabled)

            SmallKnob(value: $value)
                .disabled(isDisabled)
                .frame(width: 100)
        }
    }

    return PreviewWrapper()
}
