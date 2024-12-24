//
//  NavigationLazyView.swift
//  airun-ios
//
//  Created by Rodrigo Labrador Serrano on 19/12/24.
//

import SwiftUI

public struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    public init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    public var body: Content {
        build()
    }
}
