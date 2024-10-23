//
//  OpenURL.swift
//  blena
//
//  Created by Lê Vinh on 10/15/24.
//

import Foundation
import AppIntents
import UIKit

@available(iOS 17.0, macOS 14.0, watchOS 10.0, *)
struct OpenURL: AppIntent, WidgetConfigurationIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "OpenURLIntent"

    static var title: LocalizedStringResource = "Open URL"
    static var description = IntentDescription("Open URL in Blena")
    static var openAppWhenRun: Bool = true

    @Parameter(title: "URL", default: "https://apple.com")
    var URL: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Open an URL") {
            \.$URL
        }
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$URL)) { URL in
            DisplayRepresentation(
                title: "Open an URL",
                subtitle: "Open an URL in Blena Browser"
            )
        }
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        NSLog("perform")

        await MainActor.run {
            // Update the UI or open a specific view in response to the intent
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let window = appDelegate.window,
               let rootVC = window.rootViewController as? UINavigationController,
               let viewController = rootVC.topViewController as? ViewController {
                viewController
                    .loadLocation(
                        URL!
                    )  // Load the URL in your custom view controller
            }
        }
        return .result(dialog: .responseSuccess)
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
fileprivate extension IntentDialog {
    static func URLParameterPrompt(URL: String) -> Self {
        "Open \(URL) in Blena"
    }
    static var responseSuccess: Self {
        "The link open now."
    }
    static var responseFailure: Self {
        "Failed to open the link."
    }
}


@available(iOS 17.0, macOS 14.0, watchOS 7.0, tvOS 17.0, *)
struct MyAppShortcuts: AppShortcutsProvider {
    @AppShortcutsBuilder
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenURL(),
            phrases: [
                "Open [URL] in Blena",
                "Use Blena to open [URL]",
                "Blena open [URL]",
                "Open URL with Blena"
            ],
            shortTitle: "Open URL",
            systemImageName: "globe"
        )
    }
}
