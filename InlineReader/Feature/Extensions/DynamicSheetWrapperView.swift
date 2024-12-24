//
//  DynamicSheetWrapperView.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 17/5/23.
//

import SwiftUI

public struct DynamicSheetWrapperView: ViewModifier {
    @Environment(\.presentationMode) private var presentationMode
    public var detents: Set<CustomPresentationDetent>
    @State private var size: CGSize = .zero

    public func body(content: Content) -> some View {
        content
            .compatiblePresentationDetents(detents)
            .compatiblePresentationDragIndicator(.visible)
            .animation(.easeIn, value: size)
    }
}

public struct AutomaticSheetWrapperView: ViewModifier {
    @State private var size: CGSize = .zero

    public func body(content: Content) -> some View {
        content
            .background(GeometryReader { geometry in
                Color.clear.onAppear {
                    size = geometry.size
                }
                .onChange(of: geometry.size) { newSize in
                    size = newSize
                }
            })
            .compatiblePresentationDetents([.height(size.height)])
            .animation(.easeIn, value: size)
    }
}

public extension View {
    func dynamicSheetHeight(detents sizes: Set<CustomPresentationDetent> = [.small, .medium, .large]) -> some View {
        modifier(DynamicSheetWrapperView(detents: sizes))
    }

    func automaticSheetHeight() -> some View {
        modifier(AutomaticSheetWrapperView())
    }
}

struct DynamicSheetWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        Button("Show") {
            print("Toggle Sheet")
        }.sheet(isPresented: .constant(true)) {
            Text("Hello")
                .dynamicSheetHeight()
        }
    }
}
