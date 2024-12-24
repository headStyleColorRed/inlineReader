//
//  UIViewControllerExtensions.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 29/7/21.
//  Copyright © 2024 airun. All rights reserved.
//

import Foundation
import UIKit

public extension UIViewController {
    func addTransition(_ transition: UIModalTransitionStyle) {
        self.modalPresentationStyle = .custom
        self.modalTransitionStyle = transition
    }
}
