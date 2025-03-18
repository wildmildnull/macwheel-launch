//
//  AppWallView.swift
//  macwheel-launch
//
//  Created by yang yang on 2025/3/15.
//

import SwiftUI

struct AppWallView: View {
    
    @EnvironmentObject private var viewModel: AppWallViewModel
    @State private var searchText = ""
    @State private var selectedIndex = 1
    @State private var viewMode: ViewMode = .grid
    
    private let options = ["2", "3", "4", "5"]
    
    var body: some View {
        VStack {
            switch viewMode {
            case .grid:
                GridView(searchText: $searchText, selectedIndex: $selectedIndex)
            case .list:
                ListView(searchText: $searchText)
            }
        }
        .searchable(text: $searchText, placement: .toolbar)
        .searchPresentationToolbarBehavior(.avoidHidingContent)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                HStack {
                    viewModeButton(
                        systemImage: "square.grid.2x2",
                        mode: .grid,
                        label: "Grid View"
                    )
                    
                    viewModeButton(
                        systemImage: "list.bullet",
                        mode: .list,
                        label: "List View"
                    )
                    
                    Picker("Select", selection: $selectedIndex) {
                        ForEach(0..<options.count, id:\.self) { index in
                            Text(options[index]).tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 100, height: 20, alignment: .leading)
                    .disabled(viewMode == .grid ? false : true)
                }
            }
        }
        .task {
            await loadAppIcons()
        }
    }
    
    // 视图模式切换按钮组件
    private func viewModeButton(systemImage: String, mode: ViewMode, label: String) -> some View {
        Button {
            viewMode = mode
        } label: {
            Image(systemName: systemImage)
                .foregroundStyle(viewMode == mode ? .blue : .gray)
        }
        .help(label)
    }
    
    private func loadAppIcons() async {
        if !viewModel.appIcons.isEmpty {
            print("Loading data from cache.")
            return
        }
        
        print("Loading data from disk.")
        
        let apps = await fetchInstalledApps()
        var icons: [AppInfo] = []
        
        await withTaskGroup(of: AppInfo?.self) { group in
            for appPath in apps {
                group.addTask {
                    await parseAppInfo(at: appPath)
                }
            }
            
            for await result in group {
                if let validResult = result {
                    icons.append(validResult)
                }
            }
        }
        
        DispatchQueue.main.async {
            viewModel.appIcons = icons.sorted { $0.name < $1.name }
        }
    }

    private func fetchInstalledApps() async -> [URL] {
        let appsDir = URL(fileURLWithPath: "/Applications")
        let systemAppDir = URL(fileURLWithPath: "/System/Applications")
        
        do {
            var urls: [URL] = []
            
            let userAppsUrl = try getURLs(forUrl: appsDir)
            let systemAppsUrl = try getURLs(forUrl: systemAppDir)
            
            urls.insert(contentsOf: userAppsUrl, at: 0)
            urls.insert(contentsOf: systemAppsUrl, at: 1)
            
            return urls.filter { url in
                guard let resourceValues = try? url.resourceValues(forKeys: [.isApplicationKey]),
                      resourceValues.isApplication == true else {
                    return false
                }
                return true
            }
        } catch {
            print("访问目录失败: \(error.localizedDescription)")
            return []
        }
    }
    
    private func getURLs(forUrl url: URL) throws -> [URL] {
        return try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isApplicationKey], options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
    }
    
    // 解析单个应用信息
    private func parseAppInfo(at url: URL) async -> AppInfo? {
        let infoPlistURL = url.appendingPathComponent("Contents/Info.plist")
        
        guard let infoDict = NSDictionary(contentsOf: infoPlistURL) as? [String: Any] else {
            return nil
        }
        
        let bundleID = infoDict["CFBundleIdentifier"] as? String ?? "unknown"
        let name = infoDict["CFBundleDisplayName"] as? String
                    ?? infoDict["CFBundleName"] as? String
                    ?? url.deletingPathExtension().lastPathComponent
        
        // 解析图标
        let iconName: String?
        if let iconFile = infoDict["CFBundleIconFile"] as? String {
            iconName = iconFile
        } else if let iconFiles = (infoDict["CFBundleIcons"] as? [String: Any])?["CFBundlePrimaryIcon"] as? [String: Any],
                  let files = iconFiles["CFBundleIconFiles"] as? [String] {
            iconName = files.last // 取最大尺寸的图标
        } else {
            iconName = nil
        }
        
        // 加载图标
        let icon: NSImage? = {
            guard let iconName = iconName else { return nil }
            
            let iconBaseURL = url.appendingPathComponent("Contents/Resources")
            let possiblePaths = [
                iconBaseURL.appendingPathComponent("\(iconName).icns"),
                iconBaseURL.appendingPathComponent(iconName),
                iconBaseURL.appendingPathComponent("\(iconName).png")
            ]
            
            for path in possiblePaths {
                if FileManager.default.fileExists(atPath: path.path) {
                    return NSImage(contentsOf: path)
                }
            }
            
            // 尝试通过系统API获取
            return NSWorkspace.shared.icon(forFile: url.path)
        }()
        
        return AppInfo(
            name: name,
            bundleID: bundleID,
            path: url.path,
            icon: icon
        )
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

enum ViewMode {
    case grid
    case list
}



#Preview {
    AppWallView()
}
