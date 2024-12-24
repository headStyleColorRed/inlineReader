//
//  SwiftUIView.swift
//  
//
//  Created by Rodrigo Labrador Serrano on 3/6/24.
//

import SwiftUI

struct WidthViewExpander: ViewModifier {
    func body(content: Content) -> some View {
        VStack {
            Color.clear.frame(height: 0)
            content
        }
    }
}

public extension View {
    func fullWidthExpanded() -> some View {
        modifier(WidthViewExpander())
    }
}
