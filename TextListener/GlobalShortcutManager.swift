//
//  GlobalShortcutManager.swift
//  TextListener
//
//  Manages global keyboard shortcuts for quick actions
//

import AppKit
import Combine

class GlobalShortcutManager: ObservableObject {
    private var eventMonitor: Any?
    private var readAction: (() -> Void)?
    
    // Default shortcut: Cmd+Shift+R
    @Published var shortcutKey: String = "R"
    @Published var shortcutModifiers: NSEvent.ModifierFlags = [.command, .shift]
    
    init() {
        // Load saved shortcut from UserDefaults
        if let savedKey = UserDefaults.standard.string(forKey: "shortcutKey") {
            shortcutKey = savedKey
        }
        
        let savedModifiers = UserDefaults.standard.integer(forKey: "shortcutModifiers")
        if savedModifiers != 0 {
            shortcutModifiers = NSEvent.ModifierFlags(rawValue: UInt(savedModifiers))
        }
    }
    
    func startMonitoring(readAction: @escaping () -> Void) {
        self.readAction = readAction
        stopMonitoring() // Stop any existing monitor
        
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleKeyEvent(event)
        }
    }
    
    func stopMonitoring() {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) {
        // Check if the key matches our shortcut
        guard let keyChar = event.charactersIgnoringModifiers?.uppercased(),
              keyChar == shortcutKey.uppercased() else {
            return
        }
        
        // Check if modifiers match
        let pressedModifiers = event.modifierFlags.intersection([.command, .shift, .option, .control])
        if pressedModifiers == shortcutModifiers.intersection([.command, .shift, .option, .control]) {
            readAction?()
        }
    }
    
    func updateShortcut(key: String, modifiers: NSEvent.ModifierFlags) {
        shortcutKey = key
        shortcutModifiers = modifiers
        
        // Save to UserDefaults
        UserDefaults.standard.set(key, forKey: "shortcutKey")
        UserDefaults.standard.set(Int(modifiers.rawValue), forKey: "shortcutModifiers")
        
        // Restart monitoring with new shortcut
        if let action = readAction {
            startMonitoring(readAction: action)
        }
    }
    
    func getShortcutDisplayString() -> String {
        var parts: [String] = []
        
        if shortcutModifiers.contains(.command) {
            parts.append("⌘")
        }
        if shortcutModifiers.contains(.shift) {
            parts.append("⇧")
        }
        if shortcutModifiers.contains(.option) {
            parts.append("⌥")
        }
        if shortcutModifiers.contains(.control) {
            parts.append("⌃")
        }
        
        parts.append(shortcutKey.uppercased())
        return parts.joined(separator: "")
    }
    
    deinit {
        stopMonitoring()
    }
}

