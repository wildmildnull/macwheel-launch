//
//  GridView.swift
//  macwheel-launch
//
//  Created by yang yang on 2025/3/18.
//

import SwiftUI

struct GridView: View {
    
    @EnvironmentObject var viewModel: AppWallViewModel
    @Binding var searchText: String
    @Binding var selectedIndex: Int
    
    let options = ["2", "3", "4", "5"]
    
    var columns:[GridItem] {
        if let num = Int(options[selectedIndex]) {
            return Array(repeating: GridItem(.flexible(), spacing: 1), count: num)
        } else {
            return Array(repeating: GridItem(.flexible(), spacing: 1), count: viewModel.defaultNumOfColumn)
        }
    }
    
    var filteredApps: [AppInfo] {
        if searchText.isEmpty {
            return viewModel.appIcons
        } else {
            return viewModel.appIcons.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(filteredApps, id: \.bundleID) { app in
                    VStack {
                        createAppIconView(with: app)
                        createAppTextView(with: app)
                    }
                }
            }
            .padding()
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

    @ViewBuilder
    private func createAppTextView(with app: AppInfo) -> some View {
         Text(app.name)
            .font(.caption)
            .lineLimit(2)
            .frame(width: 80)
    }
    
}

#Preview {
    //GridView()
}
