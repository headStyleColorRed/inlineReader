//
//  UIApplication+handleURL.swift
//  airun
//
//  Created by Rodrigo Labrador Serrano on 28/12/21.
//  Copyright © 2024 airun. All rights reserved.
//

import Foundation
import UIKit

public extension UIApplication {
    /// This function forwards the URL to the AppDelegate handler so that we have a chance to check if the URL is one of
    /// the types that the app handles by itself.
    /// - Parameters:
    ///   - url: The url to handle.
    /// - Returns: Whether the URL was handled successfully or not.
    @discardableResult
    func handleURL(_ url: URL) -> Bool {
        // If scheme is omitted, default to http and recursively try again
        if url.scheme == nil,
           var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
            components.scheme = "http"
            guard let newURL = components.url else { return false }
            handleURL(newURL)
            return true
        }

        // NSUserActivityTypeBrowsingWeb only works with http and https
        guard url.scheme == "http" || url.scheme == "https" else {
            UIApplication.shared.open(url)
            return true
        }

        let userActivity =  NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
        userActivity.webpageURL = url

        // Try to handle the URL using the AppDelegate handler and fallback to the regular URL opener if it fails
        guard delegate?.application?(self, continue: userActivity, restorationHandler: { _ in }) == true else {
            UIApplication.shared.open(url)
            return true
        }

        return false
    }
}
