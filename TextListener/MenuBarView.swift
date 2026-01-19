//
//  MenuBarView.swift
//  TextListener
//
//  Main menu bar interface following Nielsen's heuristics
//

import SwiftUI
import AppKit

struct MenuBarView: View {
    @EnvironmentObject var speechManager: SpeechManager
    @EnvironmentObject var textCapture: TextCaptureManager
    @EnvironmentObject var windowManager: FloatingWindowManager
    @EnvironmentObject var shortcutManager: GlobalShortcutManager
    @Environment(\.openWindow) private var openWindow
    
    // Unique scene identifiers used by App for windows
    private let floatingControlSceneID = "floating-control"
    private let settingsSceneID = "settings"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack(spacing: 8) {
                SVGImage("MenuBarLogo", size: CGSize(width: 16, height: 16))
                Text("TextListener")
                    .font(.headline)
                
                Spacer()
                
                Button(action: showSettings) {
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            
            Divider()
            
            // Read Selection Button (Primary Action)
            Button(action: readSelection) {
                HStack {
                    Label("Read Selection", systemImage: "play.fill")
                    Spacer()
                    Text(shortcutManager.getShortcutDisplayString())
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.secondary.opacity(0.1))
                        )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.accentColor.opacity(0.1))
            )
            .padding(.horizontal, 8)
            
            // Speed Control
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Speed")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(String(format: "%.1fx", speechManager.speechRate))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 12)
                
                Slider(
                    value: Binding(
                        get: { Double(speechManager.speechRate) },
                        set: { speechManager.speechRate = Float($0) }
                    ),
                    in: 0.0...2.0,
                    step: 0.1
                )
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 4)
            
            Divider()
            
            // Playback Controls
            if speechManager.isSpeaking {
                HStack(spacing: 20) {
                    Spacer()
                    
                    if speechManager.isPaused {
                        Button(action: { speechManager.resume() }) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .buttonStyle(.plain)
                        .help("Resume Playback")
                    } else {
                        Button(action: { speechManager.pause() }) {
                            Image(systemName: "pause.fill")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .buttonStyle(.plain)
                        .help("Pause Playback")
                    }
                    
                    Button(action: { speechManager.stop() }) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .buttonStyle(.plain)
                    .help("Stop Playback")
                    
                    Spacer()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.05))
                )
                .padding(.horizontal, 8)
            }
            
            Divider()
            
            // Floating Window Toggle
            Button(action: toggleFloatingWindow) {
                HStack {
                    Label(
                        windowManager.isVisible ? "Hide Control Window" : "Show Control Window",
                        systemImage: windowManager.isVisible ? "xmark.circle.fill" : "rectangle.portrait.and.arrow.right"
                    )
                    Spacer()
                }
                .contentShape(Rectangle())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            
            Divider()
            
            // Status/Error Messages
            if let error = textCapture.captureError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)
            }
            
            // Quit
            Button(action: quitApp) {
                HStack {
                    Label("Quit", systemImage: "power")
                    Spacer()
                }
                .contentShape(Rectangle())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 8)
        }
        .frame(width: 280)
        .padding(.vertical, 4)
    }
    
    private func readSelection() {
        // Clear any previous errors
        textCapture.captureError = nil
        
        guard let text = textCapture.captureSelectedText(), !text.isEmpty else {
            // Error message is already set by captureSelectedText()
            return
        }
        speechManager.speak(text)
    }
    
    private func toggleFloatingWindow() {
        print("DEBUG: ====== toggleFloatingWindow() CALLED ======")
        let currentVisibility = windowManager.isVisible
        print("DEBUG: toggleFloatingWindow - isVisible: \(currentVisibility)")
        
        // Prevent double-triggering by checking actual window state
        let actualWindowExists = NSApplication.shared.windows.contains { win in
            let identifier = win.identifier?.rawValue ?? ""
            let title = win.title
            // Match only floating control windows, exclude settings
            let isFloatingById = identifier == floatingControlSceneID || identifier.hasPrefix("\(floatingControlSceneID)-")
            let isFloatingByTitle = title == floatingControlSceneID || title.hasPrefix("\(floatingControlSceneID)-")
            return (isFloatingById || isFloatingByTitle) && win.isVisible
        }
        
        print("DEBUG: Actual window visible state: \(actualWindowExists)")
        
        // #region agent log
        writeDebugLog([
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "A",
            "location": "MenuBarView.swift:170",
            "message": "toggleFloatingWindow() called",
            "data": ["isVisible": currentVisibility, "actualWindowExists": actualWindowExists, "totalWindows": NSApplication.shared.windows.count],
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ])
        // #endregion
        
        if currentVisibility && actualWindowExists {
            print("DEBUG: Hiding window")
            windowManager.hideWindow()
        } else if !currentVisibility {
            print("DEBUG: Showing window - delegating to windowManager.showWindow() and avoiding openWindow(id:)")

            // Activate app to ensure window shows in front
            NSApp.activate(ignoringOtherApps: true)

            // Close any duplicate floating windows if somehow present
            let floatingWindows = NSApplication.shared.windows.filter { win in
                let identifier = win.identifier?.rawValue ?? ""
                let title = win.title
                let isFloatingById = identifier == floatingControlSceneID || identifier.hasPrefix("\(floatingControlSceneID)-")
                let isFloatingByTitle = title == floatingControlSceneID || title.hasPrefix("\(floatingControlSceneID)-")
                return isFloatingById || isFloatingByTitle
            }
            if floatingWindows.count > 1 {
                print("DEBUG: Closing \(floatingWindows.count - 1) duplicate floating windows before showing")
                for window in floatingWindows.dropFirst() {
                    window.delegate = nil
                    window.close()
                }
            }

            // Directly ask the window manager to show/create the control window.
            // This avoids any scene id mix-ups that could route to Settings.
            windowManager.showWindow()
        } else {
            print("DEBUG: toggleFloatingWindow - state mismatch, ignoring. isVisible: \(currentVisibility), actualWindowExists: \(actualWindowExists)")
        }
    }
    
    private func showSettings() {
        print("DEBUG: ====== showSettings() CALLED ======")
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
            "hypothesisId": "A,B,D",
            "location": "MenuBarView.swift:230",
            "message": "showSettings() called",
            "data": ["totalWindows": NSApplication.shared.windows.count, "allWindows": allWindowsInfo],
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ])
        // #endregion
        
        // Activate the app first
        NSApp.activate(ignoringOtherApps: true)
        
        // Check if window already exists
        // SwiftUI appends "-AppWindow-N" to identifiers, so match by prefix
        let existingWindow = NSApplication.shared.windows.first(where: { win in
            let identifier = win.identifier?.rawValue ?? ""
            let title = win.title
            let isSettingsById = identifier == settingsSceneID || identifier.hasPrefix("\(settingsSceneID)-")
            let isSettingsByTitle = title == settingsSceneID || title.hasPrefix("\(settingsSceneID)-")
            return isSettingsById || isSettingsByTitle
        })
        
        // #region agent log
        writeDebugLog([
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "A,B",
            "location": "MenuBarView.swift:240",
            "message": "Existing window check",
            "data": ["existingWindowFound": existingWindow != nil, "identifier": existingWindow?.identifier?.rawValue ?? "nil"],
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ])
        // #endregion
        
        if let existingWindow = existingWindow {
            // Window exists, bring it to front
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            // #region agent log
            writeDebugLog([
                "sessionId": "debug-session",
                "runId": "run1",
                "hypothesisId": "A",
                "location": "MenuBarView.swift:247",
                "message": "Existing window found, bringing to front",
                "data": [:],
                "timestamp": Int(Date().timeIntervalSince1970 * 1000)
            ])
            // #endregion
            return
        }
        
        // Window doesn't exist, create it
        // #region agent log
        writeDebugLog([
            "sessionId": "debug-session",
            "runId": "run1",
            "hypothesisId": "A,D,E",
            "location": "MenuBarView.swift:255",
            "message": "Calling openWindow(id: settings)",
            "data": ["windowCountBefore": NSApplication.shared.windows.count],
            "timestamp": Int(Date().timeIntervalSince1970 * 1000)
        ])
        // #endregion
        openWindow(id: settingsSceneID)
        
        // Ensure window appears and is activated with retries
        var retryCount = 0
        let maxRetries = 10
        
        func tryShowWindow() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // Check all windows - sometimes identifier isn't set immediately
                let allWindowsInfo: [[String: Any]] = NSApplication.shared.windows.enumerated().map { idx, win in
                    [
                        "index": idx,
                        "identifier": win.identifier?.rawValue ?? "nil",
                        "title": win.title,
                        "isVisible": win.isVisible
                    ] as [String: Any]
                }
                // #region agent log
                writeDebugLog([
                    "sessionId": "debug-session",
                    "runId": "run1",
                    "hypothesisId": "A,B,C",
                    "location": "MenuBarView.swift:260",
                    "message": "tryShowWindow retry",
                    "data": ["retryCount": retryCount, "totalWindows": NSApplication.shared.windows.count, "allWindows": allWindowsInfo],
                    "timestamp": Int(Date().timeIntervalSince1970 * 1000)
                ])
                // #endregion
                
                // SwiftUI appends "-AppWindow-N" to identifiers, so match by prefix
                let window = NSApplication.shared.windows.first(where: { win in
                    let identifier = win.identifier?.rawValue ?? ""
                    let title = win.title
                    let isSettingsById = identifier == settingsSceneID || identifier.hasPrefix("\(settingsSceneID)-")
                    let isSettingsByTitle = title == settingsSceneID || title.hasPrefix("\(settingsSceneID)-")
                    return isSettingsById || isSettingsByTitle
                })
                
                if let window = window {
                    // Set identifier if not set (shouldn't be needed but just in case)
                    if window.identifier == nil {
                        window.identifier = NSUserInterfaceItemIdentifier(settingsSceneID)
                    }
                    window.makeKeyAndOrderFront(nil)
                    NSApp.activate(ignoringOtherApps: true)
                    // #region agent log
                    writeDebugLog([
                        "sessionId": "debug-session",
                        "runId": "run1",
                        "hypothesisId": "A",
                        "location": "MenuBarView.swift:275",
                        "message": "Window found and configured",
                        "data": ["identifier": window.identifier?.rawValue ?? "nil"],
                        "timestamp": Int(Date().timeIntervalSince1970 * 1000)
                    ])
                    // #endregion
                } else if retryCount < maxRetries {
                    retryCount += 1
                    tryShowWindow()
                }
            }
        }
        
        tryShowWindow()
    }
    
    private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
}

