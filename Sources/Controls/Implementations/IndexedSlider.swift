import SwiftUI

public struct IndexedSlider: View {
    @Binding var index: Int
    @State var normalValue: Float = 0.0
    var labels: [AttributedString]

    var backgroundColor: Color = .gray
    var foregroundColor: Color = .red
    var cornerRadius: CGFloat = 0
    var indicatorPadding: CGFloat = 0.07
    var fontFace: String = ""

    @Environment(\.isEnabled) private var isEnabled: Bool

    init(index: Binding<Int>, labels: [String]) {
        self.init(index: index, labels: labels.map(AttributedString.init))
    }

    public init(index: Binding<Int>, labels: [AttributedString]) {
        _index = index
        self.labels = labels
    }

    private func font() -> Font {
        let size = 16.0
        if fontFace.isEmpty {
            return .system(.body).bold()
        } else {
            return .custom(fontFace, size: size).bold()
        }
    }

    private var activeLabelText: AttributedString {
        labels[index <> 0...labels.count-1]
    }

    public var body: some View {
        Control(value: $normalValue, geometry: .horizontalPoint) { geo in
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .foregroundColor(backgroundColor)
                ZStack {
                    ForEach(0..<labels.count, id: \.self) { i in
                        ZStack {
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .foregroundColor(foregroundColor.opacity(0.15))
                            Text(labels[i])
                                .indexedSliderText(font: font())
                                .foregroundColor(foregroundColor)
                        }.padding(indicatorPadding * geo.size.height)
                        .frame(width: geo.size.width / CGFloat(labels.count))
                        .offset(x: CGFloat(i) * geo.size.width / CGFloat(labels.count))
                    }
                }
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundColor(foregroundColor)
                    Text(activeLabelText)
                        .indexedSliderText(font: font())
                        .foregroundColor(backgroundColor)

                }.padding(indicatorPadding * geo.size.height)
                .frame(width: geo.size.width / CGFloat(labels.count))
                .offset(x: CGFloat(index) * geo.size.width / CGFloat(labels.count))
                .animation(.easeOut, value: index)
            }
        }
        .enabledState(isEnabled)
        .onChange(of: normalValue) { _ in
            index = Int(normalValue * 0.99 * Float(labels.count))
        }
        .onAppear {
            index <>= 0...labels.count-1
        }
    }
}

extension IndexedSlider {
    /// Modifier to change the background color of the slider
    /// - Parameter backgroundColor: background color
    public func backgroundColor(_ backgroundColor: Color) -> IndexedSlider {
        var copy = self
        copy.backgroundColor = backgroundColor
        return copy
    }

    /// Modifier to change the foreground color of the slider
    /// - Parameter foregroundColor: foreground color
    public func foregroundColor(_ foregroundColor: Color) -> IndexedSlider {
        var copy = self
        copy.foregroundColor = foregroundColor
        return copy
    }

    /// Modifier to change the corner radius of the slider bar and the indicator
    /// - Parameter cornerRadius: radius (make very high for a circular indicator)
    public func cornerRadius(_ cornerRadius: CGFloat) -> IndexedSlider {
        var copy = self
        copy.cornerRadius = cornerRadius
        return copy
    }
    
    /// Modifier to change the font face used in the slider and its components
    /// - Parameter fontFace: font face as a string
    public func fontFace(_ fontFace: String) -> IndexedSlider {
        var copy = self
        copy.fontFace = fontFace
        return copy
    }
}

private extension View {
    func indexedSliderText(font: Font) -> some View {
        self.modifier(IndexedSliderModifier(font: font))
    }
}

private struct IndexedSliderModifier: ViewModifier {
    private let font: Font

    init(font: Font) {
        self.font = font
    }

    func body(content: Content) -> some View {
        content
            .font(font)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var index = 20020
        @State private var isDisabled: Bool = false

        var body: some View {
            Toggle("Disable?", isOn: $isDisabled)

            IndexedSlider(index: $index, labels: ["c", "c♯", "d", "d♯", "e", "f", "f♯", "g", "g♯", "a", "a♯", "b", "c"])
                .backgroundColor(.mint)
                .foregroundColor(.black)
                .fontFace("Verdana")
                .cornerRadius(100000)
                .disabled(isDisabled)
                .frame(height: 32)
        }
    }

    return PreviewWrapper()
}
