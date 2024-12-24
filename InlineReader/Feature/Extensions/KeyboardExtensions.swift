//
//  KeyboardExtensions.swift
//
//
//  Created by Rodrigo Labrador Serrano on 20/12/23.
//

import SwiftUI

struct WithKeyboardDoneButtonViewModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Spacer()

                        Button("done".localized) {
                            UIApplication.shared.sendAction(
                                #selector(UIApplication.resignFirstResponder),
                                to: nil, from: nil, for: nil)
                        }.foregroundColor(.airunBlue)
                    }
                }
            }
    }
}

public extension View {
    func withKeyboardDoneButton() -> some View {
        self.modifier(WithKeyboardDoneButtonViewModifier())
    }
}
