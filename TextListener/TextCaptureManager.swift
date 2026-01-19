//
//  TextCaptureManager.swift
//  TextListener
//
//  Captures selected text using Accessibility API (AXUIElement)
//

import AppKit
import ApplicationServices

@MainActor
class TextCaptureManager: ObservableObject {
    @Published var lastCapturedText: String = ""
    @Published var captureError: String?
    @Published var autoCapturedText: String = ""
    
    private var selectionMonitor: Any?
    private var mouseEventMonitor: Any?
    private var lastSelectionTime: Date = Date()
    private let selectionDebounceInterval: TimeInterval = 0.1 // 100ms debounce
    private let autoReadDelay: TimeInterval = 0.15 // Small delay after selection stabilizes to ensure cursor is released
    private var autoReadCallback: ((String) -> Void)?
    private var pendingAutoReadText: String?
    private var autoReadWorkItem: DispatchWorkItem?
    private var lastScheduledAutoReadText: String? // Track the last text we scheduled to prevent infinite loops
    private var isSpeechActiveCallback: (() -> Bool)? // Callback to check if speech is currently active
    private var isMouseButtonPressed: Bool = false // Track if mouse button is currently pressed
    private var pendingSelectionForAutoRead: String? // Text selection waiting for mouse release
    private var keyboardSelectionTimer: Timer? // Timer to detect stable keyboard selections
    private let keyboardSelectionStableDelay: TimeInterval = 0.5 // Wait 500ms for keyboard selection to stabilize
    
    /// Clears the last scheduled auto-read text (called when speech finishes)
    func clearLastScheduledAutoReadText() {
        lastScheduledAutoReadText = nil
    }
    
    init() {
        startSelectionMonitoring()
        startMouseMonitoring()
    }
    
    deinit {
        // Direct cleanup without main actor isolation
        if let timer = selectionMonitor as? Timer {
            timer.invalidate()
        }
        selectionMonitor = nil
        
        // Clean up mouse event monitor
        if let monitor = mouseEventMonitor {
            NSEvent.removeMonitor(monitor)
            mouseEventMonitor = nil
        }
        
        keyboardSelectionTimer?.invalidate()
        keyboardSelectionTimer = nil
        autoReadWorkItem?.cancel()
        autoReadWorkItem = nil
    }
    
    /// Sets a callback to be called when text is auto-captured (for auto-read functionality)
    func setAutoReadCallback(_ callback: @escaping (String) -> Void) {
        autoReadCallback = callback
    }
    
    /// Sets a callback to check if speech is currently active (to prevent infinite loops)
    func setIsSpeechActiveCallback(_ callback: @escaping () -> Bool) {
        isSpeechActiveCallback = callback
    }
    
    /// Schedules auto-read with a delay to ensure cursor/mouse is released
    private func scheduleAutoRead(_ text: String) {
        // Prevent infinite loops: don't schedule if we're already reading or have scheduled the same text
        if let isActive = isSpeechActiveCallback, isActive() {
            print("DEBUG: Auto-read skipped - speech is already active")
            return
        }
        
        // Don't re-schedule if we've already scheduled/read this exact text
        if text == lastScheduledAutoReadText {
            print("DEBUG: Auto-read skipped - same text already scheduled/read: '\(text.prefix(30))...'")
            return
        }
        
        // Cancel any pending auto-read
        autoReadWorkItem?.cancel()
        pendingAutoReadText = text
        lastScheduledAutoReadText = text // Track that we've scheduled this text
        
        // Ensure callback is set before scheduling
        guard autoReadCallback != nil else {
            print("DEBUG: Auto-read callback not set, skipping auto-read")
            return
        }
        
        print("DEBUG: Scheduling auto-read for text: '\(text.prefix(50))...' (length: \(text.count))")
        
        // Create a work item for the auto-read
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            // Verify we still have text to read and callback is still set
            guard let textToRead = self.pendingAutoReadText,
                  !textToRead.isEmpty,
                  let callbackToCall = self.autoReadCallback else {
                print("DEBUG: Auto-read cancelled - text cleared or callback removed")
                return
            }
            
            // Verify the text still matches what we captured (selection hasn't changed)
            // Only check if autoCapturedText is not empty (selection still exists)
            if !self.autoCapturedText.isEmpty && textToRead != self.autoCapturedText {
                print("DEBUG: Auto-read cancelled - selection changed from '\(textToRead.prefix(30))...' to '\(self.autoCapturedText.prefix(30))...'")
                return
            }
            
            print("DEBUG: Executing auto-read callback for text: '\(textToRead.prefix(50))...'")
            // Call the callback
            callbackToCall(textToRead)
            self.pendingAutoReadText = nil
            // Keep lastScheduledAutoReadText set so we don't re-schedule for the same text
        }
        
        // Store the work item for potential cancellation
        autoReadWorkItem = workItem
        
        // Schedule the work item after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + autoReadDelay, execute: workItem)
    }
    
    /// Starts monitoring for text selection changes across all applications
    private func startSelectionMonitoring() {
        // Use a timer to periodically check for selection changes
        // This is more reliable than trying to set up AX notifications for all apps
        selectionMonitor = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.checkForSelectionChange()
            }
        }
    }
    
    /// Stops monitoring for text selection changes
    private func stopSelectionMonitoring() {
        if let timer = selectionMonitor as? Timer {
            timer.invalidate()
        }
        selectionMonitor = nil
    }
    
    /// Starts monitoring mouse button events to detect when selection is complete (mouse release)
    private func startMouseMonitoring() {
        // Monitor for left mouse button down and up events
        mouseEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .leftMouseUp]) { [weak self] event in
            Task { @MainActor in
                self?.handleMouseEvent(event)
            }
        }
    }
    
    /// Stops monitoring mouse events
    private func stopMouseMonitoring() {
        if let monitor = mouseEventMonitor {
            NSEvent.removeMonitor(monitor)
            mouseEventMonitor = nil
        }
    }
    
    /// Handles mouse button events to detect when selection is complete
    private func handleMouseEvent(_ event: NSEvent) {
        switch event.type {
        case .leftMouseDown:
            isMouseButtonPressed = true
            // Cancel any pending auto-read when mouse button is pressed (user is making a new selection)
            autoReadWorkItem?.cancel()
            pendingAutoReadText = nil
            pendingSelectionForAutoRead = nil
            print("DEBUG: Mouse button pressed - cancelling pending auto-read")
            
        case .leftMouseUp:
            isMouseButtonPressed = false
            print("DEBUG: Mouse button released - checking for selection to auto-read")
            
            // When mouse is released, check if we have a pending selection and trigger auto-read
            if let selectionText = pendingSelectionForAutoRead, !selectionText.isEmpty {
                let autoReadEnabled = UserDefaults.standard.bool(forKey: "autoReadOnSelection")
                if autoReadEnabled {
                    print("DEBUG: Mouse released with pending selection, triggering auto-read")
                    scheduleAutoRead(selectionText)
                }
                pendingSelectionForAutoRead = nil
            } else {
                // Check current selection immediately after mouse release
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    Task { @MainActor in
                        self?.checkSelectionAfterMouseRelease()
                    }
                }
            }
            
        default:
            break
        }
    }
    
    /// Checks for selection after mouse release and triggers auto-read if enabled
    private func checkSelectionAfterMouseRelease() {
        // Only proceed if mouse is still released (not pressed again)
        guard !isMouseButtonPressed else {
            print("DEBUG: Mouse button pressed again, skipping auto-read check")
            return
        }
        
        // Get current selection
        guard let text = getCurrentSelection(), !text.isEmpty else {
            print("DEBUG: No selection found after mouse release")
            return
        }
        
        // Only trigger if auto-read is enabled
        let autoReadEnabled = UserDefaults.standard.bool(forKey: "autoReadOnSelection")
        if autoReadEnabled {
            print("DEBUG: Selection found after mouse release, triggering auto-read")
            scheduleAutoRead(text)
        }
    }
    
    /// Handles keyboard-based selections (when mouse is not pressed)
    /// Uses a timer to wait for selection to stabilize before triggering auto-read
    private func handleKeyboardSelection(_ text: String) {
        // Cancel any existing timer
        keyboardSelectionTimer?.invalidate()
        
        // Store the selection for potential auto-read
        pendingSelectionForAutoRead = text
        
        // Create a timer to check if selection is stable (user finished selecting)
        keyboardSelectionTimer = Timer.scheduledTimer(withTimeInterval: keyboardSelectionStableDelay, repeats: false) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                
                // Only proceed if mouse is still not pressed (still keyboard selection)
                guard !self.isMouseButtonPressed else {
                    print("DEBUG: Mouse pressed during keyboard selection timer - cancelling")
                    return
                }
                
                // Check if we still have the same selection
                guard let pendingText = self.pendingSelectionForAutoRead,
                      pendingText == self.autoCapturedText,
                      !pendingText.isEmpty else {
                    print("DEBUG: Selection changed during keyboard timer - cancelling auto-read")
                    return
                }
                
                // Trigger auto-read for stable keyboard selection
                let autoReadEnabled = UserDefaults.standard.bool(forKey: "autoReadOnSelection")
                if autoReadEnabled {
                    print("DEBUG: Keyboard selection stabilized, triggering auto-read")
                    self.scheduleAutoRead(pendingText)
                }
                
                self.pendingSelectionForAutoRead = nil
            }
        }
    }
    
    /// Gets the current selected text without updating internal state
    private func getCurrentSelection() -> String? {
        // Check accessibility permissions first
        let checkOptions = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let hasPermission = AXIsProcessTrustedWithOptions(checkOptions as CFDictionary)
        
        if !hasPermission {
            return nil
        }
        
        // Get the currently focused application
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            return nil
        }
        
        let pid = frontmostApp.processIdentifier
        let appElement = AXUIElementCreateApplication(pid)
        
        // Try to get the focused UI element
        var focusedElement: AnyObject?
        let focusedResult = AXUIElementCopyAttributeValue(
            appElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )
        
        if focusedResult == .success,
           let element = focusedElement as! AXUIElement? {
            
            // Try to get selected text from the focused element
            var selectedText: AnyObject?
            let textResult = AXUIElementCopyAttributeValue(
                element,
                kAXSelectedTextAttribute as CFString,
                &selectedText
            )
            
            if textResult == .success,
               let text = selectedText as? String,
               !text.isEmpty {
                return text
            }
        }
        
        // Alternative: Try to get selected text from any text area
        return tryGetSelectedTextFromAnyElement(appElement)
    }
    
    /// Checks if the selected text has changed and captures it automatically
    private func checkForSelectionChange() {
        // Check accessibility permissions first
        let checkOptions = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let hasPermission = AXIsProcessTrustedWithOptions(checkOptions as CFDictionary)
        
        if !hasPermission {
            // Clear auto-captured text if permissions are lost
            if !autoCapturedText.isEmpty {
                autoCapturedText = ""
            }
            return
        }
        
        // Get the currently focused application
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            return
        }
        
        let pid = frontmostApp.processIdentifier
        let appElement = AXUIElementCreateApplication(pid)
        
        // Try to get the focused UI element
        var focusedElement: AnyObject?
        let focusedResult = AXUIElementCopyAttributeValue(
            appElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )
        
        if focusedResult == .success,
           let element = focusedElement as! AXUIElement? {
            
            // Try to get selected text from the focused element
            var selectedText: AnyObject?
            let textResult = AXUIElementCopyAttributeValue(
                element,
                kAXSelectedTextAttribute as CFString,
                &selectedText
            )
            
            if textResult == .success,
               let text = selectedText as? String,
               !text.isEmpty {
                // Debounce rapid selection changes
                let now = Date()
                if now.timeIntervalSince(lastSelectionTime) >= selectionDebounceInterval {
                    // Only update if text actually changed
                    let textChanged = text != autoCapturedText
                    if textChanged {
                        autoCapturedText = text
                        lastCapturedText = text
                        lastSelectionTime = now
                        captureError = nil
                        // Clear last scheduled text when selection changes to allow new reads
                        lastScheduledAutoReadText = nil
                        
                        // If mouse button is pressed, store the selection for auto-read after release
                        if isMouseButtonPressed {
                            pendingSelectionForAutoRead = text
                            print("DEBUG: Selection changed while mouse pressed - storing for auto-read after release")
                            // Cancel keyboard selection timer since we're using mouse
                            keyboardSelectionTimer?.invalidate()
                            keyboardSelectionTimer = nil
                        } else {
                            // Mouse is not pressed - this might be keyboard selection
                            // Use a timer to wait for selection to stabilize before auto-reading
                            handleKeyboardSelection(text)
                        }
                    }
                }
                return
            }
        }
        
        // Alternative: Try to get selected text from any text area
        if let text = tryGetSelectedTextFromAnyElement(appElement),
           !text.isEmpty {
            let now = Date()
            if now.timeIntervalSince(lastSelectionTime) >= selectionDebounceInterval {
                // Only update if text actually changed
                let textChanged = text != autoCapturedText
                if textChanged {
                    autoCapturedText = text
                    lastCapturedText = text
                    lastSelectionTime = now
                    captureError = nil
                    // Clear last scheduled text when selection changes to allow new reads
                    lastScheduledAutoReadText = nil
                    
                    // If mouse button is pressed, store the selection for auto-read after release
                    if isMouseButtonPressed {
                        pendingSelectionForAutoRead = text
                        print("DEBUG: Selection changed while mouse pressed - storing for auto-read after release")
                        // Cancel keyboard selection timer since we're using mouse
                        keyboardSelectionTimer?.invalidate()
                        keyboardSelectionTimer = nil
                    } else {
                        // Mouse is not pressed - this might be keyboard selection
                        // Use a timer to wait for selection to stabilize before auto-reading
                        handleKeyboardSelection(text)
                    }
                }
            }
        } else {
            // Clear auto-captured text if no selection found
            if !autoCapturedText.isEmpty {
                autoCapturedText = ""
                // Also clear last scheduled text when selection is cleared
                lastScheduledAutoReadText = nil
            }
        }
    }
    
    /// Attempts to capture selected text using Accessibility API
    /// Uses auto-captured text if available, otherwise tries to capture fresh
    /// Falls back to clipboard if Accessibility API fails
    func captureSelectedText() -> String? {
        captureError = nil
        
        // First, try to use auto-captured text (captured when selection was made)
        if !autoCapturedText.isEmpty {
            return autoCapturedText
        }
        
        // Check if we have accessibility permissions first
        let checkOptions = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: false]
        let hasPermission = AXIsProcessTrustedWithOptions(checkOptions as CFDictionary)
        
        if !hasPermission {
            captureError = "Accessibility permission required. Please enable TextListener in System Settings > Privacy & Security > Accessibility."
            return nil
        }
        
        // Get the currently focused application
        guard let frontmostApp = NSWorkspace.shared.frontmostApplication else {
            captureError = "Could not access frontmost application. Please ensure TextListener has Accessibility permissions."
            return fallbackToClipboard()
        }
        
        let pid = frontmostApp.processIdentifier
        let appElement = AXUIElementCreateApplication(pid)
        
        // Try to get the focused UI element
        var focusedElement: AnyObject?
        let focusedResult = AXUIElementCopyAttributeValue(
            appElement,
            kAXFocusedUIElementAttribute as CFString,
            &focusedElement
        )
        
        if focusedResult == .success,
           let element = focusedElement as! AXUIElement? {
            
            // Try to get selected text from the focused element
            var selectedText: AnyObject?
            let textResult = AXUIElementCopyAttributeValue(
                element,
                kAXSelectedTextAttribute as CFString,
                &selectedText
            )
            
            if textResult == .success,
               let text = selectedText as? String,
               !text.isEmpty {
                autoCapturedText = text
                lastCapturedText = text
                captureError = nil
                return text
            }
            
            // Alternative: Try to get the value attribute (for text fields)
            var value: AnyObject?
            let valueResult = AXUIElementCopyAttributeValue(
                element,
                kAXValueAttribute as CFString,
                &value
            )
            
            if valueResult == .success,
               let text = value as? String,
               !text.isEmpty {
                autoCapturedText = text
                lastCapturedText = text
                captureError = nil
                return text
            }
        }
        
        // Fallback: Try to get selected text from any text area
        // This is a more aggressive approach that searches for text selections
        if let text = tryGetSelectedTextFromAnyElement(appElement) {
            autoCapturedText = text
            lastCapturedText = text
            captureError = nil
            return text
        }
        
        // Final fallback: Use clipboard
        captureError = "No text selected. Please select text first, or copy text to clipboard."
        return fallbackToClipboard()
    }
    
    /// Attempts to find selected text by searching through UI elements
    private func tryGetSelectedTextFromAnyElement(_ appElement: AXUIElement) -> String? {
        var windows: AnyObject?
        let windowsResult = AXUIElementCopyAttributeValue(
            appElement,
            kAXWindowsAttribute as CFString,
            &windows
        )
        
        guard windowsResult == .success,
              let windowList = windows as? [AXUIElement] else {
            return nil
        }
        
        // Search through windows for selected text
        for window in windowList {
            if let text = searchForSelectedText(in: window) {
                return text
            }
        }
        
        return nil
    }
    
    /// Recursively searches for selected text in a UI element hierarchy
    private func searchForSelectedText(in element: AXUIElement) -> String? {
        // Check if this element has selected text
        var selectedText: AnyObject?
        let textResult = AXUIElementCopyAttributeValue(
            element,
            kAXSelectedTextAttribute as CFString,
            &selectedText
        )
        
        if textResult == .success,
           let text = selectedText as? String,
           !text.isEmpty {
            return text
        }
        
        // Recursively check children
        var children: AnyObject?
        let childrenResult = AXUIElementCopyAttributeValue(
            element,
            kAXChildrenAttribute as CFString,
            &children
        )
        
        if childrenResult == .success,
           let childList = children as? [AXUIElement] {
            for child in childList {
                if let text = searchForSelectedText(in: child) {
                    return text
                }
            }
        }
        
        return nil
    }
    
    /// Fallback method: Returns text from clipboard
    /// Note: This requires the user to manually copy the text first
    private func fallbackToClipboard() -> String? {
        let pasteboard = NSPasteboard.general
        guard let text = pasteboard.string(forType: .string),
              !text.isEmpty else {
            captureError = "No text found in clipboard. Please copy text first or select text in an accessible application."
            return nil
        }
        
        lastCapturedText = text
        return text
    }
}

