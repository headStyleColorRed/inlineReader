//
//  DismissActionExtensions.swift
//
//
//  Created by Rodrigo Labrador Serrano on 21/8/24.
//

import SwiftUI

// How to use:
/// struct CustomViewController: View {
///    @Environment(\.dismiss) var dismiss
///
///    var body: some View {
///        Button("Save") {
///            dismiss.onFinish {
///                // Do something
///            }
///        }
///    }
/// }
public extension DismissAction {
    func onFinish(after delay: Double = 0.5, completion: (() -> Void)? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { completion?() }
    }
}
