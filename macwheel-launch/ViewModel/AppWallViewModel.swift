//
//  AppWallViewModel.swift
//  macwheel-launch
//
//  Created by yang yang on 2025/3/15.
//

import Foundation

class AppWallViewModel: ObservableObject {
    @Published var appIcons: [AppInfo] = []
    @Published var defaultNumOfColumn = 4
}
