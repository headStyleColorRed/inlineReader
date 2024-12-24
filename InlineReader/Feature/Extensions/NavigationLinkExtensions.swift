//
//  NavigationLinkExtensions.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 31/1/22.
//  Copyright © 2022 airun. All rights reserved.
//

import SwiftUI

public extension NavigationLink where Label == EmptyView, Destination == EmptyView {
    /// Useful in cases where a `NavigationLink` is needed but there should not be
    /// a destination. e.g. for programmatic navigation.
    static var empty: NavigationLink {
        self.init(destination: EmptyView(), label: { EmptyView() })
    }
}
