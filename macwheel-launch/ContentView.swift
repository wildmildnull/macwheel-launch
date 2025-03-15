//
//  ContentView.swift
//  macwheel-launch
//
//  Created by yang yang on 2025/3/15.
//

import SwiftUI

struct ContentView: View {
    let appWallViewModel = AppWallViewModel()
    
    var body: some View {
        AppWallView().environmentObject(appWallViewModel)
    }
}

#Preview {
    ContentView()
}
