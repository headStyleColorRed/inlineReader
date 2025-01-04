//
//  BannerManager.swift
//  InlineReader
//
//  Created by Rodrigo Labrador Serrano on 4/1/25.
//

import SwiftMessages
import UIKit
import SwiftUI

public protocol SwiftMessagesProtocol {
    func show(config: SwiftMessages.Config, view: UIView)
}

extension SwiftMessages: SwiftMessagesProtocol {}

public class BannerManager {
    @MainActor
    public static var sharedInstance: SwiftMessagesProtocol = SwiftMessages.sharedInstance

    public static func showSuccess(title: String? = nil,
                                   message: String,
                                   details: String? = nil,
                                   config: SwiftMessages.Config? = nil) {
        print(details ?? "")
        showMessage(title: title,
                    message: message,
                    type: .success,
                    config: config)
    }

    public static func showMessage(title: String? = nil,
                                   message: String,
                                   details: String? = nil,
                                   config: SwiftMessages.Config? = nil) {
        print(details ?? "")
        showMessage(title: title,
                    message: message,
                    type: .info,
                    config: config)
    }

    public static func showError(title: String? = nil,
                                 message: String,
                                 details: String? = nil,
                                 config: SwiftMessages.Config? = nil) {
        print(details ?? "")
        showMessage(title: title,
                    message: message,
                    type: .error,
                    config: config)
    }

    static private func showMessage(title: String?,
                                    message: String?,
                                    button: AnyView? = nil,
                                    type: NotificationBannerType = .info,
                                    id: String = UUID().uuidString,
                                    config: SwiftMessages.Config? = nil) {
        DispatchQueue.main.async {
            guard UIApplication.shared.applicationState == .active ||
                    UIApplication.shared.applicationState == .inactive else {
                return
            }

            let notificationView = NotificationView(title: title, message: message, button: button, type: type)
            let messageViewController = UIHostingController(rootView: notificationView)

            // Wrap view inside an identifiableView. We need this so that SwiftMessages can hide a message on demand
            let messageView = IdentifiableView(title: title, message: message)

            messageViewController.view.backgroundColor = .clear
            messageView.addSubview(messageViewController.view)
            // Add constraints to make the messageViewController.view fill the messageView
            messageViewController.view.translatesAutoresizingMaskIntoConstraints = false
            messageViewController.view.topAnchor.constraint(equalTo: messageView.topAnchor).isActive = true
            messageViewController.view.leadingAnchor.constraint(equalTo: messageView.leadingAnchor).isActive = true
            messageViewController.view.trailingAnchor.constraint(equalTo: messageView.trailingAnchor).isActive = true
            messageViewController.view.bottomAnchor.constraint(equalTo: messageView.bottomAnchor).isActive = true

            messageView.id = id

            sharedInstance.show(config: config ?? .init(), view: messageView)
        }
    }

    public class IdentifiableView: UIView, Identifiable, MarginAdjustable {
        public var id: String = UUID().uuidString
        public var title: String?
        public var message: String?

        init(title: String? = nil, message: String? = nil) {
            self.title = title
            self.message = message
            super.init(frame: .zero) // Call to UIView's designated initializer
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // MARK: MarginAdjustable

        public var layoutMarginAdditions: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)

        public var collapseLayoutMarginAdditions: Bool = true

        public var respectSafeArea: Bool = false

        // Extra padding to show the message below the navigation bar
        public var bounceAnimationOffset: CGFloat = -92
    }
}


public enum NotificationBannerType {
    case info, success, error, warning

    @ViewBuilder
    var image: some View {
        switch self {
        case .info:
            Image(systemName: "info.circle")
                .resizable()
                .foregroundStyle(Color(hex: "#005598"))
        case .success:
            Image(systemName: "checkmark.circle")
                .resizable()
                .foregroundStyle(Color(hex: "#116729"))
        case .error:
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .foregroundStyle(Color(hex: "#B20C0C"))
        case .warning:
            Image(systemName: "info.circle")
                .resizable()
                .foregroundStyle(Color(hex: "#FFBB00"))
        }
    }

    var backgroundColor: Color {
        switch self {
        case .success:
            return Color(hex: "#E5FFEC")
        case .error:
            return Color(hex: "#FFE9EF")
        case .warning:
            return Color(hex: "#FEF7EB")
        default:
            return Color(hex: "#EBF6FF")
        }
    }

    var foregroundColor: Color {
        switch self {
        case .success:
            return Color(hex: "#35C759")
        case .error:
            return Color(hex: "#FF1D13")
        case .warning:
            return Color(hex: "#3B3B3B")
        default:
            return Color(hex: "#005599")
        }
    }

    var defaultTitle: String {
        switch self {
        case .success:
            return "Success"
        case .error:
            return "Error"
        case .warning:
            return "Warning"
        case .info:
            return "Info"
        }
    }
}

public struct NotificationView: View {
    var title: String?
    var message: String?
    var button: AnyView?
    var type: NotificationBannerType = .info

    public init(
        title: String? = nil,
        message: String? = nil,
        button: AnyView? = nil,
        type: NotificationBannerType = .info
    ) {
        self.title = title
        self.message = message
        self.button = button
        self.type = type
    }

    public var body: some View {
        HStack(alignment: message != nil ? .top : .center, spacing: 16) {
            type.image
                .frame(width: 33, height: 33)

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title ?? type.defaultTitle)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "#3B3B3B"))
                    if let message {
                        Text(message)
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#3B3B3B"))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)

                if let button {
                    button
                        .font(.system(size: 14))
                        .tint(type.foregroundColor)
                        .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(type.backgroundColor)
        .cornerRadius(6)
        .padding(16)
    }
}

