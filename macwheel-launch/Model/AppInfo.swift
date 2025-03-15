//
//  AppInfo.swift
//  macwheel-launch
//
//  Created by yang yang on 2025/3/15.
//

import Foundation
import AppKit

struct AppInfo: Identifiable {
    let id = UUID()
    let name: String
    let bundleID: String
    let path: String
    let icon: NSImage?
}
