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
                                .font(font())
                                .foregroundColor(foregroundColor) // TODO: MORE COLOR OPTS
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                        }.padding(indicatorPadding * geo.size.height)
                        .frame(width: geo.size.width / CGFloat(labels.count))
                        .offset(x: CGFloat(i) * geo.size.width / CGFloat(labels.count))
                    }
                }
                // the item that is selected?
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .foregroundColor(foregroundColor)
                    Text(labels[index])
                        .font(font()) // TODO: Color options TODO: Consolidate this and the above
                        .foregroundColor(backgroundColor)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }.padding(indicatorPadding * geo.size.height)
                .frame(width: geo.size.width / CGFloat(labels.count))
                .offset(x: CGFloat(index) * geo.size.width / CGFloat(labels.count))
                .animation(.easeOut, value: index)
            }
        }
        .onChange(of: normalValue) { _ in
            index = Int(normalValue * 0.99 * Float(labels.count))
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

#Preview {
    struct PreviewWrapper: View {
        @State var index = 2
        var body: some View {
            IndexedSlider(index: $index, labels: ["c", "c ♯", "d", "d ♯", "e", "f", "f♯", "g", "g ♯", "a", "a ♯", "b", "c", "long"])
                .fontFace("Verdana")
                .cornerRadius(100000)
                .frame(height: 32)
        }
    }

    return PreviewWrapper()
}
