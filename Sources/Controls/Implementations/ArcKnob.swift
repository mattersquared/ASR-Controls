import SwiftUI

/// Knob in which you control the value by moving in a circular shape
public struct ArcKnob: View {
    @Binding var value: Float
    var text = ""

    var backgroundColor: Color = .gray
    var foregroundColor: Color = .red
    var fontFace: String = ""

    @State var isShowingValue = false
    var range: ClosedRange<Float>
    var origin: Float = 0

    @Environment(\.isEnabled) private var isEnabled: Bool

    /// Initialize the knob
    /// - Parameters:
    ///   - text: Default text that shows when the value is not shown
    ///   - value: Bound value that is being controlled
    ///   - range: Range of values
    ///   - origin: Center point from which to draw the arc, usually zero but can be 50% for pan
    public init(_ text: String, value: Binding<Float>,
                range: ClosedRange<Float> = 0 ... 100,
                origin: Float = 0) {
        _value = value
        self.origin = origin
        self.text = text
        self.range = range
    }

    func dim(_ proxy: GeometryProxy) -> CGFloat {
        min(proxy.size.width, proxy.size.height)
    }

    let minimumAngle = Angle(degrees: 45)
    let maximumAngle = Angle(degrees: 315)
    var angleRange: CGFloat {
        CGFloat(maximumAngle.degrees - minimumAngle.degrees)
    }

    var nondimValue: Float {
        (value - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    var originLocation: Float {
        (origin - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    private func font(_ geo: GeometryProxy) -> Font {
        let size = dim(geo) * 0.2
        if fontFace.isEmpty {
            return .system(size: size, weight: .bold)
        } else {
            return .custom(fontFace, size: size).weight(.bold)
        }
    }

    var trimFrom: CGFloat {
        if value >= origin {
            return minimumAngle.degrees / 360 + CGFloat(originLocation) * angleRange / 360.0
        } else {
            return (minimumAngle.degrees + CGFloat(nondimValue) * angleRange) / 360.0
        }
    }

    var trimTo: CGFloat {
        if value >= origin {
            return (minimumAngle.degrees +  CGFloat(nondimValue) * angleRange) / 360.0 + 0.0001
        } else {
            return (minimumAngle.degrees + CGFloat(originLocation) * angleRange) / 360.0
        }
    }

    public var body: some View {
        Control(value: $value, in: range,
                geometry: .angle(angularRange: minimumAngle ... maximumAngle),
                onStarted: { isShowingValue = true },
                onEnded: { isShowingValue = false }) { geo in
            ZStack(alignment: .center) {
                Circle()
                    .trim(from: minimumAngle.degrees / 360.0, to: maximumAngle.degrees / 360.0)

                    .rotation(.degrees(-270))
                    .stroke(backgroundColor,
                            style: StrokeStyle(lineWidth: dim(geo) / 10,
                                               lineCap: .round))
                    .squareFrame(dim(geo) * 0.8)
                    .foregroundColor(foregroundColor)

                // Stroke value trim of knob
                Circle()
                    .trim(from: trimFrom, to: trimTo)
                    .rotation(.degrees(-270))
                    .stroke(foregroundColor,
                            style: StrokeStyle(lineWidth: dim(geo) / 10,
                                               lineCap: .round))
                    .squareFrame(dim(geo) * 0.8)

                Text("\(isShowingValue ? "\(Int(value))" : text)")
                    .frame(width: dim(geo) * 0.8)
                    .font(font(geo))
                    .foregroundColor(backgroundColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.2)
            }.enabledState(isEnabled)
        }
        .onAppear {
            value <>= range
        }
    }
}


extension ArcKnob {
    /// Modifier to change the background color of the knob
    /// - Parameter backgroundColor: background color
    public func backgroundColor(_ backgroundColor: Color) -> ArcKnob {
        var copy = self
        copy.backgroundColor = backgroundColor
        return copy
    }

    /// Modifier to change the foreground color of the knob
    /// - Parameter foregroundColor: foreground color
    public func foregroundColor(_ foregroundColor: Color) -> ArcKnob {
        var copy = self
        copy.foregroundColor = foregroundColor
        return copy
    }

    /// Modifier to change the font face of the knob
    /// - Parameter fontFace: the font face as a string
    public func fontFace(_ fontFace: String) -> ArcKnob {
        var copy = self
        copy.fontFace = fontFace
        return copy
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var value: Float = 0.0
        @State var isDisabled: Bool = false

        var body: some View {
            Toggle("Disable?", isOn: $isDisabled)
                .toggleStyle(.switch)

            ArcKnob("Mod", value: $value, range: -10...10, origin: -0.5)
                .disabled(isDisabled)
        }
    }

    return PreviewWrapper()

}
