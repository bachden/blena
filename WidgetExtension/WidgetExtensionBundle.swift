//
//  WidgetExtensionBundle.swift
//  WidgetExtension
//
//  Created by Lê Vinh on 10/16/24.
//

import WidgetKit
import SwiftUI

@main
struct WidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        WidgetExtension()
        WidgetExtensionControl()
        WidgetExtensionLiveActivity()
    }
}
