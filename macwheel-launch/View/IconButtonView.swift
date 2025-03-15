//
//  NormalIconButtonView.swift
//  macwheel-launch
//
//  Created by yang yang on 2025/3/15.
//

import SwiftUI

struct IconButtonView: View {
    var nsImage: NSImage
    var appPath: String
    
    var body: some View {
        Button {
            NSWorkspace.shared.open(URL(fileURLWithPath: appPath))
        } label: {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            Button("Show in Finder") {
                NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: appPath)])
            }
            Button("Open App") {
                NSWorkspace.shared.open(URL(fileURLWithPath: appPath))
            }
        }
    }
}

//#Preview {
//    IconButtonView()
//}
