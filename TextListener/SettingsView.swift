//
//  SettingsView.swift
//  TextListener
//
//  Settings and onboarding view - Nielsen Heuristic Compliant
//

import SwiftUI
import AppKit
import ApplicationServices

// Visual Effect View for blur background
struct SettingsVisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var shortcutManager: GlobalShortcutManager
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var showingAccessibilityHelp = false
    @EnvironmentObject var speechManager: SpeechManager
    @State private var isRecordingShortcut = false
    @State private var tempShortcutKey: String = ""
    @State private var tempShortcutModifiers: NSEvent.ModifierFlags = []
    @State private var shortcutMonitor: Any? = nil
    @State private var hasAccessibilityPermission = false
    @State private var showingResetConfirmation = false
    @State private var shortcutError: String? = nil
    @State private var lastSavedShortcutKey: String = ""
    @State private var lastSavedShortcutModifiers: NSEvent.ModifierFlags = []
    @State private var showSaveFeedback = false
    @State private var permissionCheckTimer: Timer?
    
    // Default values
    private let defaultSpeechRate: Float = 0.5
    private let defaultShortcutKey = "R"
    private let defaultShortcutModifiers: NSEvent.ModifierFlags = [.command, .shift]
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Welcome Section (only on first launch)
                    if !hasSeenOnboarding {
                        WelcomeSection()
                            .padding(.top, 8)
                    }
                    
                    // Quick Start Guide
                    SectionView(title: "Quick Start", icon: "play.circle.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            StepView(number: 1, text: "Select text in any application")
                            StepView(number: 2, text: "Press \(shortcutManager.getShortcutDisplayString()) or click the menu bar icon")
                            StepView(number: 3, text: "Click 'Read Selection' to hear the text")
                            StepView(number: 4, text: "Use controls to pause, resume, or adjust speed")
                        }
                    }
                    
                    // Permissions Section
                    SectionView(title: "Permissions", icon: "lock.shield.fill") {
                        VStack(alignment: .leading, spacing: 12) {
                            // Permission Status Indicator (Heuristic 1: Visibility of system status)
                            HStack(spacing: 8) {
                                Image(systemName: hasAccessibilityPermission ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(hasAccessibilityPermission ? .green : .orange)
                                    .font(.title3)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(hasAccessibilityPermission ? "Accessibility Permission Granted" : "Accessibility Permission Required")
                                        .font(.headline)
                                    Text("TextListener needs Accessibility permissions to capture selected text.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.bottom, 4)
                            
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Button(action: {
                                        requestAccessibilityPermission()
                                    }) {
                                        Label("Request Permission", systemImage: "hand.raised.fill")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .controlSize(.large)
                                    .help("Request accessibility permission (may show system prompt)")
                                    
                                    Button(action: {
                                        checkAccessibilityPermission()
                                    }) {
                                        Image(systemName: "arrow.clockwise")
                                            .frame(width: 32, height: 32)
                                    }
                                    .buttonStyle(.bordered)
                                    .help("Refresh permission status")
                                }
                                
                                Button(action: {
                                    openAccessibilitySettings()
                                }) {
                                    Label("Open System Settings", systemImage: "gear")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.bordered)
                                .controlSize(.regular)
                                .help("Opens System Settings to Privacy & Security > Accessibility")
                            }
                            
                            // Important note about rebuilds
                            if !hasAccessibilityPermission {
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                            .font(.caption)
                                        Text("Permission Issue After Rebuild")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("After rebuilding from Xcode:")
                                            .font(.caption2)
                                            .fontWeight(.medium)
                                        Text("1. The old TextListener entry in System Settings may still show as ON")
                                        Text("2. Toggle it OFF to remove the old entry")
                                        Text("3. Then toggle the new TextListener entry ON")
                                        Text("4. Or click 'Request Permission' to add it automatically")
                                    }
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color.orange.opacity(0.1))
                                )
                            }
                            
                            // Always show instructions, but make them collapsible (Heuristic 10: Help)
                            DisclosureGroup(isExpanded: $showingAccessibilityHelp) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("How to enable:")
                                        .font(.headline)
                                    Text("1. Go to System Settings > Privacy & Security")
                                    Text("2. Click on Accessibility")
                                    Text("3. Find TextListener and toggle it ON")
                                    Text("4. If TextListener isn't listed, click the + button and add it")
                                    Text("5. Return here and check if permission is granted")
                                    
                                    Divider()
                                        .padding(.vertical, 4)
                                    
                                    Text("After rebuilding from Xcode:")
                                        .font(.headline)
                                        .padding(.top, 4)
                                    Text("• macOS treats each rebuild as a new app")
                                    Text("• The old entry in System Settings may still show as ON")
                                    Text("• Toggle the old entry OFF, then toggle the new entry ON")
                                    Text("• Or remove the old entry and add the new one")
                                    Text("• This is normal during development")
                                    Text("• Production builds with consistent signing won't have this issue")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                            } label: {
                                Text(showingAccessibilityHelp ? "Hide Instructions" : "Show Instructions")
                                    .font(.caption)
                            }
                        }
                    }
                    
                    // Settings Section
                    SectionView(title: "Settings", icon: "slider.horizontal.3") {
                        VStack(alignment: .leading, spacing: 20) {
                            // Speech Speed with better visual feedback
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Speech Speed")
                                        .font(.headline)
                                    Spacer()
                                    // More prominent value display (Heuristic 1: Visibility)
                                    Text(String(format: "%.1fx", speechManager.speechRate))
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.accentColor)
                                        .monospacedDigit()
                                }
                                
                                Slider(
                                    value: Binding(
                                        get: { Double(speechManager.speechRate) },
                                        set: { 
                                            speechManager.speechRate = Float($0)
                                            // Show save feedback
                                            withAnimation {
                                                showSaveFeedback = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                                showSaveFeedback = false
                                            }
                                        }
                                    ),
                                    in: 0.0...2.0,
                                    step: 0.1
                                )
                                .help("Adjust reading speed from 0.0x (slowest) to 2.0x (fastest)")
                                
                                HStack {
                                    Text("0.0x")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("2.0x")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Divider()
                            
                            // Keyboard Shortcut Configuration with better UX
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Text("Keyboard Shortcut")
                                        .font(.headline)
                                    Spacer()
                                    // Current shortcut display (Heuristic 6: Recognition)
                                    HStack(spacing: 4) {
                                        if isRecordingShortcut {
                                            Image(systemName: "record.circle.fill")
                                                .foregroundColor(.red)
                                                .modifier(PulseEffectModifier(isActive: isRecordingShortcut))
                                        }
                                        Text(shortcutManager.getShortcutDisplayString())
                                            .font(.system(.body, design: .monospaced))
                                            .fontWeight(.medium)
                                            .foregroundColor(isRecordingShortcut ? .red : .primary)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(
                                                RoundedRectangle(cornerRadius: 6)
                                                    .fill(isRecordingShortcut ? Color.red.opacity(0.1) : Color.secondary.opacity(0.1))
                                            )
                                    }
                                }
                                
                                if let error = shortcutError {
                                    HStack(spacing: 6) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                        Text(error)
                                            .font(.caption)
                                            .foregroundColor(.orange)
                                    }
                                    .padding(.vertical, 4)
                                }
                                
                                if isRecordingShortcut {
                                    HStack(spacing: 8) {
                                        Image(systemName: "record.circle.fill")
                                            .foregroundColor(.red)
                                            .modifier(PulseEffectModifier(isActive: isRecordingShortcut))
                                        Text("Press your desired key combination...")
                                            .font(.subheadline)
                                            .foregroundColor(.red)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.red.opacity(0.1))
                                    )
                                }
                                
                                HStack(spacing: 8) {
                                    Button(action: {
                                        if isRecordingShortcut {
                                            cancelShortcutRecording()
                                        } else {
                                            startRecordingShortcut()
                                        }
                                    }) {
                                        HStack {
                                            Image(systemName: isRecordingShortcut ? "xmark.circle.fill" : "keyboard")
                                            Text(isRecordingShortcut ? "Cancel" : "Change Shortcut")
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.regular)
                                    .disabled(isRecordingShortcut && tempShortcutKey.isEmpty)
                                    
                                    // Reset to default button (Heuristic 3: User control)
                                    Button(action: {
                                        resetShortcutToDefault()
                                    }) {
                                        HStack {
                                            Image(systemName: "arrow.counterclockwise")
                                            Text("Reset")
                                        }
                                    }
                                    .buttonStyle(.bordered)
                                    .controlSize(.regular)
                                    .disabled(isRecordingShortcut)
                                    .help("Reset to default shortcut: ⌘⇧R")
                                }
                            }
                            
                            Divider()
                            
                            // Auto-read toggle with better description
                            VStack(alignment: .leading, spacing: 8) {
                                Toggle("Auto-read on selection", isOn: Binding(
                                    get: { UserDefaults.standard.bool(forKey: "autoReadOnSelection") },
                                    set: { 
                                        UserDefaults.standard.set($0, forKey: "autoReadOnSelection")
                                        // Show feedback
                                        withAnimation {
                                            showSaveFeedback = true
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                            showSaveFeedback = false
                                        }
                                    }
                                ))
                                .font(.subheadline)
                                .help("Automatically start reading when text is selected")
                                
                                Text("Automatically start reading when text is selected and cursor is released")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.leading, 24)
                            }
                            
                            Divider()
                            
                            // Reset All Settings button (Heuristic 3: User control)
                            Button(action: {
                                showingResetConfirmation = true
                            }) {
                                Label("Reset All Settings to Defaults", systemImage: "arrow.counterclockwise.circle")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.regular)
                            .help("Reset all settings to their default values")
                        }
                    }
                    
                    // About Section
                    SectionView(title: "About", icon: "info.circle.fill") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("TextListener v1.0")
                                .font(.headline)
                            Text("A macOS utility that reads selected text aloud using text-to-speech.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Divider()
                            
                            HStack {
                                Text("Made with")
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                                Text("for macOS")
                            }
                            .font(.caption)
                            .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
            }
            
            Divider()
            
            // Footer with save feedback (Heuristic 1: Visibility)
            VStack(spacing: 8) {
                if showSaveFeedback {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Settings saved")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .transition(.opacity.combined(with: .scale))
                }
                
                HStack {
                    if !hasSeenOnboarding {
                        Button("Get Started") {
                            hasSeenOnboarding = true
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .keyboardShortcut(.defaultAction)
                    }
                    
                    Spacer()
                    
                    Button("Close") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .keyboardShortcut(.cancelAction)
                    .help("Close Settings (⌘W)")
                }
            }
            .padding()
        }
        .frame(width: 600, height: 700)
        .background(
            SettingsVisualEffectView(material: .windowBackground, blendingMode: .behindWindow)
        )
        .onAppear {
            checkAccessibilityPermission()
            lastSavedShortcutKey = shortcutManager.shortcutKey
            lastSavedShortcutModifiers = shortcutManager.shortcutModifiers
            
            // Start periodic permission check while settings window is visible
            // This ensures the UI updates when permission is granted without restarting the app
            permissionCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                checkAccessibilityPermission()
            }
        }
        .onDisappear {
            // Stop the timer when settings window closes
            permissionCheckTimer?.invalidate()
            permissionCheckTimer = nil
        }
        .onChange(of: hasSeenOnboarding) { _ in
            checkAccessibilityPermission()
        }
        .alert("Reset All Settings?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllSettings()
            }
        } message: {
            Text("This will reset all settings to their default values. This action cannot be undone.")
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            // Re-check permissions when app becomes active
            checkAccessibilityPermission()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { _ in
            // Re-check permissions when window becomes key (focused)
            checkAccessibilityPermission()
        }
    }
    
    // MARK: - Helper Functions
    
    private func checkAccessibilityPermission() {
        // Check if we have accessibility permissions
        // Use kAXTrustedCheckOptionPrompt: false to avoid showing system prompt
        let checkOptions = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        var trusted = AXIsProcessTrustedWithOptions(checkOptions as CFDictionary)
        
        // macOS sometimes caches the permission status incorrectly, especially after rebuilds
        // Try to verify by actually using the Accessibility API
        // This forces macOS to re-evaluate the permission status
        if trusted {
            // Verify by attempting a real accessibility API call
            // This helps catch cases where the flag is cached incorrectly
            // This is critical after rebuilds when System Settings might show the old entry as ON
            // but the new build doesn't actually have permission
            if let frontmostApp = NSWorkspace.shared.frontmostApplication {
                let pid = frontmostApp.processIdentifier
                let appElement = AXUIElementCreateApplication(pid)
                var focusedElement: AnyObject?
                let result = AXUIElementCopyAttributeValue(
                    appElement,
                    kAXFocusedUIElementAttribute as CFString,
                    &focusedElement
                )
                
                // Check for permission-related errors
                // .apiDisabled means accessibility is disabled for this app
                // .cannotComplete might also indicate permission issues
                if result == .apiDisabled {
                    // Definitely no permission
                    trusted = false
                } else if result == .cannotComplete {
                    // This often happens when permission was revoked but System Settings hasn't updated
                    // Try one more check with a different API call to be sure
                    var windows: AnyObject?
                    let windowsResult = AXUIElementCopyAttributeValue(
                        appElement,
                        kAXWindowsAttribute as CFString,
                        &windows
                    )
                    // If we can't even get windows, we definitely don't have permission
                    if windowsResult == .apiDisabled || windowsResult == .cannotComplete {
                        trusted = false
                    }
                }
            } else {
                // Can't get frontmost app - this shouldn't happen, but if it does,
                // we can't verify permission, so trust the system check
            }
        }
        
        // Update the permission status
        // Use withAnimation to ensure UI updates smoothly
        let newPermissionStatus = trusted
        if hasAccessibilityPermission != newPermissionStatus {
            withAnimation {
                hasAccessibilityPermission = newPermissionStatus
            }
        } else {
            // Even if the value is the same, ensure the UI is updated
            // This helps with cases where the binding might not have triggered
            hasAccessibilityPermission = newPermissionStatus
        }
    }
    
    private func requestAccessibilityPermission() {
        // Request accessibility permission by calling AXIsProcessTrustedWithOptions with prompt enabled
        // Note: macOS may not show the prompt if it was already shown before
        // In that case, the user needs to manually add the app in System Settings
        let requestOptions = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(requestOptions as CFDictionary)
        
        // Update the permission status immediately (synchronously)
        hasAccessibilityPermission = trusted
        
        // If still not trusted, open System Settings after a short delay
        // This gives the system prompt time to appear if it will
        if !trusted {
            Task { @MainActor in
                // Wait a bit for system prompt to appear
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
                // Re-check permission status
                checkAccessibilityPermission()
                
                // If still not granted, open System Settings
                if !hasAccessibilityPermission {
                    try? await Task.sleep(nanoseconds: 500_000_000) // Another 0.5 seconds
                    openAccessibilitySettings()
                }
            }
        } else {
            // Permission was granted, refresh the check to ensure UI updates
            checkAccessibilityPermission()
        }
    }
    
    private func openAccessibilitySettings() {
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }
    
    private func startRecordingShortcut() {
        shortcutError = nil
        tempShortcutKey = ""
        tempShortcutModifiers = []
        isRecordingShortcut = true
        
        // Save current shortcut in case user cancels
        lastSavedShortcutKey = shortcutManager.shortcutKey
        lastSavedShortcutModifiers = shortcutManager.shortcutModifiers
        
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            guard self.isRecordingShortcut else {
                return event
            }
            
            let keyChar = event.charactersIgnoringModifiers?.uppercased() ?? ""
            let modifiers = event.modifierFlags.intersection([.command, .shift, .option, .control])
            
            // Ignore modifier-only keys
            if !keyChar.isEmpty && keyChar.count == 1 {
                // Validate shortcut (Heuristic 5: Error prevention)
                if self.validateShortcut(key: keyChar, modifiers: modifiers) {
                    DispatchQueue.main.async {
                        self.tempShortcutKey = keyChar
                        self.tempShortcutModifiers = modifiers
                        
                        // Update shortcut immediately
                        self.shortcutManager.updateShortcut(key: self.tempShortcutKey, modifiers: self.tempShortcutModifiers)
                        
                        // Stop recording after capturing
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.isRecordingShortcut = false
                            self.stopRecordingShortcut()
                            // Show save feedback
                            withAnimation {
                                self.showSaveFeedback = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                self.showSaveFeedback = false
                            }
                        }
                    }
                    
                    return nil // Consume the event
                }
            }
            return event
        }
        
        shortcutMonitor = monitor
    }
    
    private func cancelShortcutRecording() {
        stopRecordingShortcut()
        // Restore previous shortcut
        if !lastSavedShortcutKey.isEmpty {
            shortcutManager.updateShortcut(key: lastSavedShortcutKey, modifiers: lastSavedShortcutModifiers)
        }
        shortcutError = nil
    }
    
    private func stopRecordingShortcut() {
        if let monitor = shortcutMonitor {
            NSEvent.removeMonitor(monitor)
            shortcutMonitor = nil
        }
        isRecordingShortcut = false
        
        if !tempShortcutKey.isEmpty {
            shortcutManager.updateShortcut(key: tempShortcutKey, modifiers: tempShortcutModifiers)
        }
    }
    
    private func validateShortcut(key: String, modifiers: NSEvent.ModifierFlags) -> Bool {
        // Check for common system shortcuts (Heuristic 5: Error prevention)
        let systemShortcuts: [(String, NSEvent.ModifierFlags)] = [
            ("Q", [.command]), // Quit
            ("W", [.command]), // Close window
            ("M", [.command]), // Minimize
            ("H", [.command]), // Hide
            ("TAB", [.command]), // Switch windows
        ]
        
        for (sysKey, sysModifiers) in systemShortcuts {
            if key == sysKey && modifiers == sysModifiers {
                shortcutError = "This shortcut conflicts with a system shortcut. Please choose another."
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    shortcutError = nil
                }
                return false
            }
        }
        
        // Require at least one modifier key
        if modifiers.isEmpty {
            shortcutError = "Please include at least one modifier key (⌘, ⇧, ⌥, or ⌃)."
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                shortcutError = nil
            }
            return false
        }
        
        shortcutError = nil
        return true
    }
    
    private func resetShortcutToDefault() {
        shortcutManager.updateShortcut(key: defaultShortcutKey, modifiers: defaultShortcutModifiers)
        withAnimation {
            showSaveFeedback = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showSaveFeedback = false
        }
    }
    
    private func resetAllSettings() {
        // Reset speech rate
        speechManager.speechRate = defaultSpeechRate
        
        // Reset shortcut
        resetShortcutToDefault()
        
        // Reset auto-read
        UserDefaults.standard.set(false, forKey: "autoReadOnSelection")
        
        // Show feedback
        withAnimation {
            showSaveFeedback = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showSaveFeedback = false
        }
    }
}

struct WelcomeSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome to TextListener!")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("TextListener helps you listen to selected text from any application on your Mac.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.accentColor.opacity(0.1))
        )
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    
    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.accentColor)
                    .font(.title3)
                Text(title)
                    .font(.headline)
            }
            
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.secondary.opacity(0.05))
        )
    }
}

struct StepView: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 24, height: 24)
                Text("\(number)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Text(text)
                .font(.subheadline)
        }
    }
}

// Helper modifier to conditionally apply pulse effect based on macOS version
struct PulseEffectModifier: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        if #available(macOS 14.0, *) {
            content
                .symbolEffect(.pulse, isActive: isActive)
        } else {
            content
        }
    }
}
