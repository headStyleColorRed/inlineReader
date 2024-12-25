//
//  ViewExtensions.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 30/9/21.
//  Copyright © 2024 airun. All rights reserved.
//
// swiftlint:disable identifier_name

import SwiftUI
import Combine

public enum OSVersion: Int { case iOS_16, iOS_17 }

public extension View {


    var currentIOSVersion: OSVersion? {
        if #available(iOS 17.0, *) {
            return .iOS_17
        } else if #available(iOS 16.0, *) {
            return .iOS_16
        } else {
            return nil
        }
    }

    func isDeviceUsing(_ versions: [OSVersion]) -> Bool? {
        guard let currentIOSVersion = currentIOSVersion else { return nil }
        return versions.first(where: { $0 == currentIOSVersion }) != nil
    }

    /// It will return an UIImage of the view and subviews selected
    /// ```swift
    /// let stack: some View {
    ///     VStack {
    ///         Text("Ok... all good")
    ///         Text("Sounds good to me too")
    ///     }
    /// }
    ///
    /// var body: some View {
    ///     HStack {
    ///         stack
    ///     }
    /// }
    ///
    /// func getSnapshot() -> UIImage {
    ///     return stack.snapshot()
    /// }
    /// ```
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self.ignoresSafeArea())
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

// Extension to read the size of a view without modifying it
// https://fivestars.blog/articles/swiftui-share-layout-information/
public struct SizePreferenceKey: PreferenceKey {
    static public var defaultValue: CGSize = .zero
    static public func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

public struct FramePreferenceKey: PreferenceKey {
    static public var defaultValue: CGRect = .zero
    static public func reduce(value: inout CGRect, nextValue: () -> CGRect) {}
}

public extension View {
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self) { newValue in
            DispatchQueue.main.async {
                onChange(newValue)
            }
        }
    }

    func readFrame(coordinateSpace: CoordinateSpace = .global, onChange: @escaping (CGRect) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: FramePreferenceKey.self, value: geometryProxy.frame(in: coordinateSpace))
            }
        )
        .onPreferenceChange(FramePreferenceKey.self) { newValue in
            onChange(newValue)
        }
    }
}

public extension View {
    // Wraps the view in the standard rounded corner rectangle
    func roundedBorder<S>(_ content: S = Color(hex: "#C9C9C9"),
                          width: CGFloat = 1,
                          cornerRadius: CGFloat = 8,
                          inset: CGFloat = 0) -> some View where S: ShapeStyle {
        let roundedRect = RoundedRectangle(cornerRadius: cornerRadius)
        return clipShape(roundedRect)
            .overlay(
                roundedRect
                    .inset(by: inset)
                    .strokeBorder(content, lineWidth: width)
            )
    }
}

public struct CompatibleConfirmationDialog: ViewModifier {
    var title: String
    var buttonText: String
    @Binding var deleteRequest: Bool
    var action: () -> Void

    public init(title: String,
                buttonText: String,
                deleteRequest: Binding<Bool>,
                action: @escaping () -> Void) {
        self.title = title
        self.buttonText = buttonText
        _deleteRequest = deleteRequest
        self.action = action
    }

    public func body(content: Content) -> some View {
        content
            .confirmationDialog("",
                                isPresented: $deleteRequest) {
                Button(buttonText, role: .destructive) {
                    action()
                }
            } message: {
                Text(title)
            }
    }
}

public extension View {
    func compatibleConfirmationDialog(title: String,
                                      buttonText: String,
                                      deleteRequest: Binding<Bool>,
                                      action: @escaping () -> Void) -> some View {
        modifier(CompatibleConfirmationDialog(title: title,
                                              buttonText: buttonText,
                                              deleteRequest: deleteRequest,
                                              action: action))
    }
}

public extension View {
    @available(iOS, deprecated: 16.0, message: "Use presentationDetents directly instead")
    @ViewBuilder func compatiblePresentationDetents(_ detents: Set<CustomPresentationDetent>) -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDetents(Set(detents.map({ $0.sdk })))
        } else {
            self
        }
    }

    @available(iOS, deprecated: 16.0, message: "Use presentationDragIndicator directly instead")
    @ViewBuilder func compatiblePresentationDragIndicator(_ visibility: CustomVisibility) -> some View {
        if #available(iOS 16.0, *) {
            self.presentationDragIndicator(visibility.sdk)
        } else if visibility == .visible {
            VStack(spacing: 0) {
                Capsule()
                    .frame(width: 36, height: 5)
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .padding(.top, 5)
                Spacer()
                self
                Spacer()
                Spacer().frame(height: 10) // Compensate for capsule plus padding so self stays in the center
            }
        } else {
            self
        }
    }
}

public enum CustomPresentationDetent: Hashable {
    case small
    case medium
    case large
    case fraction(CGFloat)
    case height(CGFloat)

    @available(iOS 16.0, *)
    public var sdk: PresentationDetent {
        switch self {
        case .small:
            return .fraction(0.2)
        case .medium:
            return .medium
        case .large:
            return .large
        case let .fraction(fraction):
            return .fraction(fraction)
        case let .height(height):
            return .height(height)
        }
    }
}

@available(iOS, deprecated: 15.0, message: "Use Visibility directly instead")
public enum CustomVisibility: Hashable {
    case visible
    case hidden
    case automatic

    public var sdk: Visibility {
        switch self {
        case .automatic:
            return .automatic
        case .hidden:
            return .hidden
        case .visible:
            return .visible
        }
    }
}

public extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool,
                                          transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }

    @ViewBuilder func `if`<TrueContent: View, FalseContent: View>(
        _ condition: @autoclosure () -> Bool,
        transform: (Self) -> TrueContent,
        else elseTransform: (Self) -> FalseContent
    ) -> some View {
        if condition() {
            transform(self)
        } else {
            elseTransform(self)
        }
    }
}

public extension View {
    func withoutAnimation(action: @escaping () -> Void) {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            action()
        }
    }
}

@available(iOS, deprecated: 17.0, message: "Use native API instead")
public extension View {
    @ViewBuilder func withNumericAnimationIfPossible() -> some View {
        if #available(iOS 17.0, *) {
            self.contentTransition(.numericText())
        } else {
            self
        }
    }
}

/// These two functions are used to detect when the app is in the background and foreground
/// and call the given function. Can be used like you would a viewModifier:
/// Text("Hello, world!")
/// .movingBackground {
///     print("App is in the background")
/// }
/// .movingForeground {
///     print("App is in the foreground")
/// }
public extension View {
    func movingBackground(_ f: @escaping () -> Void) -> some View {
        self.onReceive(
            NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification),
            perform: { _ in f() }
        )
    }

    func movingForeground(_ f: @escaping () -> Void) -> some View {
        self.onReceive(
            NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification),
            perform: { _ in f() }
        )
    }

}

public extension View {
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    ///
    ///     Text("Label")
    ///         .isHidden(true)
    ///
    /// Example for complete removal:
    ///
    ///     Text("Label")
    ///         .isHidden(true, remove: true)
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}

public extension View {
    func onFirstAppear(_ action: @escaping () -> Void) -> some View {
        modifier(FirstAppear(action: action))
    }
}

private struct FirstAppear: ViewModifier {
    let action: () -> Void

    @State private var hasAppeared = false

    func body(content: Content) -> some View {
        content.onAppear {
            guard !hasAppeared else { return }
            hasAppeared = true
            action()
        }
    }
}


extension View {
    func withLoader(loading: Binding<Bool>, color: UIColor = .gray,
                    radius: CGFloat = 25, strokeWidth: CGFloat = 5) -> some View {
        modifier(LoaderModifierView(loading: loading, color: color, radius: radius, strokeWidth: strokeWidth))
    }
}

struct LoaderModifierView: ViewModifier {
    @Binding var loading: Bool
    var color: UIColor
    var radius: CGFloat
    var strokeWidth: CGFloat

    func body(content: Content) -> some View {
        if loading {
            VStack {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color(color))
                Spacer()
            }
            .frame(height: UIScreen.main.bounds.height)
        } else {
            content
        }
    }

    public init(loading: Binding<Bool>, color: UIColor, radius: CGFloat, strokeWidth: CGFloat) {
        self._loading = loading
        self.color = color
        self.radius = radius
        self.strokeWidth = strokeWidth
    }
}
