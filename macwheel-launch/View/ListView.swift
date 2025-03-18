//
//  ListView.swift
//  macwheel-launch
//
//  Created by yang yang on 2025/3/18.
//

import SwiftUI

struct ListView: View {
    
    @EnvironmentObject var viewModel: AppWallViewModel
    @Binding var searchText: String
    
    var filteredApps: [AppInfo] {
        if searchText.isEmpty {
            return viewModel.appIcons
        } else {
            return viewModel.appIcons.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        Table(filteredApps) {
            TableColumn("Name") { app in
                HStack {
                    createAppIconView(with: app)
                    createAppTextView(with: app)
                }
            }
            
            TableColumn("BundleID") { app in
                Text(app.bundleID).font(.caption)
            }
        }
    }
    
    
    // 若函数需要返回条件视图（如 if-else），需添加 @ViewBuilder 修饰符，去掉return
    @ViewBuilder
    private func createAppIconView(with app: AppInfo) -> some View {
        if app.name == "Books" {
            if let nsImage = NSImage(named: "Books") {
                IconButtonView(nsImage: nsImage, appPath: app.path)
            }
        } else {
            if let nsImage = app.icon {
                IconButtonView(nsImage: nsImage, appPath: app.path)
            } else if let nsImage = NSImage(named: app.name) {
                IconButtonView(nsImage: nsImage, appPath: app.path)
            } else if let nsImage = NSImage(systemSymbolName: "questionmark.square.fill", accessibilityDescription: nil) {
                IconButtonView(nsImage: nsImage, appPath: app.path)
            }
        }
    }
    
    private func createAppTextView(with app: AppInfo) -> some View {
        return Text(app.name)
            .font(.caption)
            .lineLimit(2)
            .frame(width: 80)
    }
    
}

#Preview {
    @Previewable @State var searchText = ""
    ListView(searchText: $searchText)
}
