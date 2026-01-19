//
//  TextListenerApp.swift
//  TextListener
//
//  Created on macOS
//

import SwiftUI
import AppKit
import Foundation

// Menu bar icon that properly renders as a template image
struct MenuBarIcon: View {
    private var menuBarImage: NSImage? {
        guard let nsImage = NSImage(named: "MenuBarLogo") else { return nil }
        // Create a copy and set as template for proper menu bar rendering
        let templateImage = nsImage.copy() as! NSImage
        templateImage.isTemplate = true
        // Set the size for menu bar (standard is 18x18 or 22x22)
        templateImage.size = NSSize(width: 18, height: 18)
        return templateImage
    }
    
    var body: some View {
        if let image = menuBarImage {
            Image(nsImage: image)
                .renderingMode(.template)
        } else {
            // Fallback to SF Symbol if asset not found
            Image(systemName: "text.bubble.fill")
        }
    }
}

// #region agent log helper
func writeDebugLog(_ logData: [String: Any]) {
    // Use app's support directory instead of hardcoded path
    guard let appSupportDir = FileManager.default.urls(for: .applicationSupportDirectory, 
                                                      in: .userDomainMask).first else {
        // Fallback to console if we can't get app support directory
        if let jsonData = try? JSONSerialization.data(withJSONObject: logData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("DEBUG: \(jsonString)")
        }
        return
    }
    
    let appDir = appSupportDir.appendingPathComponent("TextListener")
    let logDir = appDir.path
    let logPath = appDir.appendingPathComponent("debug.log").path
    
    do {
        // Create directory if it doesn't exist
        try FileManager.default.createDirectory(atPath: logDir, withIntermediateDirectories: true, attributes: nil)
        
        let jsonData = try JSONSerialization.data(withJSONObject: logData)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            if let fileHandle = FileHandle(forWritingAtPath: logPath) {
                fileHandle.seekToEndOfFile()
                fileHandle.write((jsonString + "\n").data(using: .utf8)!)
                fileHandle.closeFile()
            } else {
                // File doesn't exist, create it
                try (jsonString + "\n").write(toFile: logPath, atomically: false, encoding: .utf8)
            }
        }
    } catch {
        // Fallback: print to console if file writing fails
        print("DEBUG LOG ERROR: \(error.localizedDescription)")
        if let jsonData = try? JSONSerialization.data(withJSONObject: logData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            print("DEBUG: \(jsonString)")
        }
    }
}
// #endregion

@main
struct TextListenerApp: App {
    @StateObject private var speechManager = SpeechManager()
    @StateObject private var textCapture = TextCaptureManager()
    @StateObject private var windowManager = FloatingWindowManager()
    @StateObject private var shortcutManager = GlobalShortcutManager()
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarViewWrapper()
                .environmentObject(speechManager)
                .environmentObject(textCapture)
                .environmentObject(windowManager)
                .environmentObject(shortcutManager)
        } label: {
            MenuBarIcon()
        }
        .menuBarExtraStyle(.window)
        
        WindowGroup(id: "floating-control") {
            FloatingControlWindow()
                .environmentObject(speechManager)
                .environmentObject(textCapture)
                .environmentObject(windowManager)
                .frame(width: 380, height: 220)
                .onAppear {
                    configureFloatingWindow()
                }
        }
        .defaultSize(width: 380, height: 220)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
        
        // Settings Window
        WindowGroup(id: "settings") {
            SettingsView()
                .environmentObject(speechManager)
                .environmentObject(shortcutManager)
                .onAppear {
                    configureSettingsWindow()
                }
        }
        .defaultSize(width: 600, height: 700)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
    
    init() {
        // Show settings window on first launch after a delay
        // Note: Window opening is handled via SwiftUI's openWindow in MenuBarViewWrapper
        // This prevents System Settings from opening unnecessarily
    }
    
    
    private func configureSettingsWindow() {
        DispatchQueue.main.async {
            // #region agent log
            let allWindowsInfo: [[String: Any]] = NSApplication.shared.windows.enumerated().map { idx, win in
                [
                    "index": idx,
                    "identifier": win.identifier?.rawValue ?? "nil",
                    "title": win.title,
                    "isVisible": win.isVisible
                ] as [String: Any]
            }
            writeDebugLog([
                "sessionId": "debug-session",
                "runId": "run1",
                "hypothesisId": "B,C",
                "location": "TextListenerApp.swift:101",
                "message": "configureSettingsWindow() called",
                "data": ["totalWindows": NSApplication.shared.windows.count, "allWindows": allWindowsInfo],
                "timestamp": Int(Date().timeIntervalSince1970 * 1000)
            ])
            // #endregion
            
            // Find all settings windows (check for exact match and prefix match)
            let settingsWindows = NSApplication.shared.windows.filter { win in
                let identifier = win.identifier?.rawValue ?? ""
                return identifier == "settings" || identifier.hasPrefix("settings-")
            }
            
            // #region agent log
            writeDebugLog([
                "sessionId": "debug-session",
                "runId": "run1",
                "hypothesisId": "B,C",
                "location": "TextListenerApp.swift:115",
                "message": "Settings windows found",
                "data": ["settingsWindowCount": settingsWindows.count, "identifiers": settingsWindows.map { $0.identifier?.rawValue ?? "nil" }],
                "timestamp": Int(Date().timeIntervalSince1970 * 1000)
            ])
            // #endregion
            
            // Close duplicate settings windows (keep only the first one)
            if settingsWindows.count > 1 {
                for duplicateWindow in settingsWindows.dropFirst() {
                    duplicateWindow.close()
                }
            }
            
            if let window = settingsWindows.first {
                // Set window identifier if not set
                if window.identifier == nil {
                    window.identifier = NSUserInterfaceItemIdentifier("settings")
                }
                // Ensure window is visible and activated
                window.makeKeyAndOrderFront(nil)
                NSApp.activate(ignoringOtherApps: true)
                
                // #region agent log
                writeDebugLog([
                    "sessionId": "debug-session",
                    "runId": "run1",
                    "hypothesisId": "C",
                    "location": "TextListenerApp.swift:125",
                    "message": "Configured first settings window",
                    "data": ["identifier": window.identifier?.rawValue ?? "nil", "duplicateCount": settingsWindows.count - 1],
                    "timestamp": Int(Date().timeIntervalSince1970 * 1000)
                ])
                // #endregion
            }
        }
    }
    
    private func configureFloatingWindow() {
        // Find the window immediately and configure it
        if let window = NSApplication.shared.windows.first(where: { 
            let identifier = $0.identifier?.rawValue ?? ""
            return identifier == "floating-control" || identifier.hasPrefix("floating-control-")
        }) {
            windowManager.configureWindow(window)
        }
    }
}

// Window delegate to prevent auto-closing
class FloatingWindowDelegate: NSObject, NSWindowDelegate {
    static let shared = FloatingWindowDelegate()
    private var shouldAllowClose = false
    
    func setAllowClose(_ allow: Bool) {
        shouldAllowClose = allow
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        // Only allow closing if explicitly requested via hideWindow()
        // This prevents auto-closing when menu bar closes
        let identifier = sender.identifier?.rawValue ?? "nil"
        print("DEBUG: FloatingWindowDelegate.windowShouldClose() - id: \(identifier), shouldAllowClose: \(shouldAllowClose)")
        return shouldAllowClose
    }
    
    func windowWillClose(_ notification: Notification) {
        // Reset the flag after window closes
        shouldAllowClose = false
    }
}

// Window Manager to control floating window visibility
class FloatingWindowManager: ObservableObject {
    @Published var isVisible = false
    
    func showWindow() {
        print("DEBUG: ====== FloatingWindowManager.showWindow() CALLED ======")
        
        // Check if window already exists
        let existingWindow = NSApplication.shared.windows.first(where: { win in
            let identifier = win.identifier?.rawValue ?? ""
            return identifier == "floating-control" || identifier.hasPrefix("floating-control-")
        })
        
        if let window = existingWindow {
            print("DEBUG: showWindow() - found existing window, bringing to front")
            window.orderFrontRegardless()
            NSApp.activate(ignoringOtherApps: true)
            isVisible = true
            return
        }
        
        print("DEBUG: showWindow() - no existing window, requesting creation")
        NotificationCenter.default.post(name: NSNotification.Name("CreateFloatingWindow"), object: nil)
        
        // Set isVisible to true so the menu bar UI reflects the intent
        // The window will be configured by onAppear when it's created
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.isVisible = true
        }
    }
    
    func hideWindow() {
        print("DEBUG: FloatingWindowManager.hideWindow() called")
        isVisible = false
        // Close all floating control windows
        // SwiftUI appends "-AppWindow-N" to identifiers, so match by prefix
        let floatingWindows = NSApplication.shared.windows.filter { win in
            let identifier = win.identifier?.rawValue ?? ""
            return identifier == "floating-control" || identifier.hasPrefix("floating-control-") ||
                   (win.title == "floating-control" && identifier.isEmpty)
        }
        
        print("DEBUG: hideWindow() - found \(floatingWindows.count) windows to close")
        
        // Temporarily allow closing by setting flag in delegate
        for window in floatingWindows {
            print("DEBUG: Closing window: \(window.identifier?.rawValue ?? "nil")")
            if let delegate = window.delegate as? FloatingWindowDelegate {
                delegate.setAllowClose(true)
            }
            window.close()
        }
    }
    
    func toggleWindow() {
        if isVisible {
            hideWindow()
        } else {
            showWindow()
        }
    }
    
    func configureWindow(_ window: NSWindow) {
        print("DEBUG: configureWindow() called for: \(window.identifier?.rawValue ?? "nil")")
        
        // Ensure delegate is set
        window.delegate = FloatingWindowDelegate.shared
        FloatingWindowDelegate.shared.setAllowClose(false)
        
        // Completely borderless window - no system container, no title bar
        window.styleMask = [.borderless, .fullSizeContentView]
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.titlebarSeparatorStyle = .none
        
        // Basic window setup
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.isReleasedWhenClosed = false
        
        // Hide all standard window buttons
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        
        // Remove any content view insets - content should fill entire window
        // Apply corner radius directly to content view layer
        if let contentView = window.contentView {
            contentView.autoresizingMask = [.width, .height]
            contentView.wantsLayer = true
            contentView.layer?.cornerRadius = 12
            contentView.layer?.masksToBounds = true // Clip content to rounded corners
            // Shadow is handled by window.hasShadow, not contentView
        }
        
        // Prevent window from resizing dynamically - keep fixed size
        window.setContentSize(NSSize(width: 380, height: 220))
        window.contentMinSize = NSSize(width: 380, height: 220)
        window.contentMaxSize = NSSize(width: 380, height: 220)
        
        // Position window in center of screen if not already positioned
        if window.frame.origin.x == 0 && window.frame.origin.y == 0 {
            if let screen = NSScreen.main {
                let screenRect = screen.visibleFrame
                let windowRect = window.frame
                let x = screenRect.midX - windowRect.width / 2
                let y = screenRect.midY - windowRect.height / 2
                window.setFrameOrigin(NSPoint(x: x, y: y))
            }
        }
        
        // Ensure visibility
        window.orderFrontRegardless()
        print("DEBUG: configureWindow() - completed. Window visible: \(window.isVisible)")
    }
}

// Helper view to set up global shortcut
struct MenuBarViewWrapper: View {
    @EnvironmentObject var speechManager: SpeechManager
    @EnvironmentObject var textCapture: TextCaptureManager
    @EnvironmentObject var shortcutManager: GlobalShortcutManager
    @EnvironmentObject var windowManager: FloatingWindowManager
    @Environment(\.openWindow) private var openWindow
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        MenuBarView()
            .onAppear {
                // Set up auto-read callback for selection activation
                print("DEBUG: Setting up auto-read callback")
                textCapture.setAutoReadCallback { text in
                    print("DEBUG: Auto-read callback invoked with text: '\(text.prefix(50))...'")
                    speechManager.speak(text)
                }
                
                // Set up callback to check if speech is active (prevents infinite loops)
                textCapture.setIsSpeechActiveCallback {
                    return speechManager.isSpeaking
                }
                
                // Clear tracking when speech finishes so the same text can be read again if selected
                speechManager.onSpeechFinished = {
                    textCapture.clearLastScheduledAutoReadText()
                }
                
                // Set up global shortcut handler
                shortcutManager.startMonitoring {
                    // Trigger read selection action
                    if let text = textCapture.captureSelectedText() {
                        speechManager.speak(text)
                    }
                }
                
                // TEMPORARILY DISABLED - Testing if settings window causes control window issues
                // Show settings window on first launch after a delay
                // if !hasSeenOnboarding {
                //     DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                //         openWindow(id: "settings")
                //     }
                //                 }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ShowSettings"))) { _ in
                print("DEBUG: ShowSettings notification received")
                openWindow(id: "settings")
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("CreateFloatingWindow"))) { _ in
                print("DEBUG: ====== CreateFloatingWindow notification received ======")
                // #region agent log
                writeDebugLog([
                    "sessionId": "debug-session",
                    "runId": "run1",
                    "hypothesisId": "A",
                    "location": "TextListenerApp.swift:404",
                    "message": "CreateFloatingWindow notification received",
                    "data": ["totalWindows": NSApplication.shared.windows.count],
                    "timestamp": Int(Date().timeIntervalSince1970 * 1000)
                ])
                // #endregion
                
                // Check if window doesn't exist before creating
                // SwiftUI appends "-AppWindow-N" to identifiers, so match by prefix
                let existingWindow = NSApplication.shared.windows.first(where: { win in
                    let identifier = win.identifier?.rawValue ?? ""
                    let title = win.title
                    return (identifier == "floating-control" || identifier.hasPrefix("floating-control-")) ||
                           (title == "floating-control" || title.hasPrefix("floating-control-"))
                })
                
                print("DEBUG: Existing window check - found: \(existingWindow != nil)")
                // #region agent log
                writeDebugLog([
                    "sessionId": "debug-session",
                    "runId": "run1",
                    "hypothesisId": "A,C",
                    "location": "TextListenerApp.swift:410",
                    "message": "Before openWindow call",
                    "data": ["existingWindowFound": existingWindow != nil, "totalWindows": NSApplication.shared.windows.count],
                    "timestamp": Int(Date().timeIntervalSince1970 * 1000)
                ])
                // #endregion
                
                if existingWindow == nil {
                    print("DEBUG: No existing floating-control window found, calling openWindow(id: floating-control)")
                    // #region agent log
                    writeDebugLog([
                        "sessionId": "debug-session",
                        "runId": "run1",
                        "hypothesisId": "B",
                        "location": "TextListenerApp.swift:412",
                        "message": "Calling openWindow(id: floating-control)",
                        "data": [:],
                        "timestamp": Int(Date().timeIntervalSince1970 * 1000)
                    ])
                    // #endregion
                    // CRITICAL: Must call openWindow() here, not windowManager.showWindow() to avoid recursion
                    let windowIdToOpen = "floating-control"
                    print("DEBUG: About to call openWindow(id: '\(windowIdToOpen)')")
                    openWindow(id: windowIdToOpen)
                    print("DEBUG: openWindow(id: '\(windowIdToOpen)') called, windows count now: \(NSApplication.shared.windows.count)")
                    
                    // Check what windows were created after openWindow call
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        let newWindows = NSApplication.shared.windows.enumerated().map { idx, win in
                            [
                                "index": idx,
                                "identifier": win.identifier?.rawValue ?? "nil",
                                "title": win.title,
                                "size": "\(win.frame.width)x\(win.frame.height)"
                            ]
                        }
                        print("DEBUG: After openWindow(id: '\(windowIdToOpen)') - windows: \(newWindows.map { "id=\($0["identifier"] ?? "nil"), title=\($0["title"] ?? "nil")" }.joined(separator: "; "))")
                        writeDebugLog([
                            "sessionId": "debug-session",
                            "runId": "run1",
                            "hypothesisId": "B",
                            "location": "TextListenerApp.swift:770",
                            "message": "After openWindow(id: floating-control) call",
                            "data": ["totalWindows": NSApplication.shared.windows.count, "windows": newWindows],
                            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
                        ])
                    }
                } else {
                    print("DEBUG: Existing floating-control window found, bringing to front")
                    existingWindow?.orderFrontRegardless()
                    NSApp.activate(ignoringOtherApps: true)
                    // Update window manager state
                    windowManager.isVisible = true
                }
            }
    }
}

