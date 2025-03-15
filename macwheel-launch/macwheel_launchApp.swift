//
//  macwheel_launchApp.swift
//  macwheel-launch
//
//  Created by yang yang on 2025/3/15.
//

import SwiftUI

@main
struct macwheel_launchApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 600, maxWidth: 800)
        }
        .windowResizability(.contentSize)
    }
}
