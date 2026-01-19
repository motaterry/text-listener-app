//
//  FloatingWindowModifier.swift
//  TextListener
//
//  Modifier to configure floating window properties
//

import SwiftUI
import AppKit
import Foundation

struct FloatingWindowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(WindowAccessor())
    }
}

struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        print("DEBUG: WindowAccessor.makeNSView called")
        DispatchQueue.main.async {
            print("DEBUG: WindowAccessor.makeNSView async - checking for window")
            if let window = view.window {
                print("DEBUG: WindowAccessor found window, calling configureFloatingWindow")
                configureFloatingWindow(window)
            } else {
                print("DEBUG: WindowAccessor.makeNSView - view.window is nil")
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {
        print("DEBUG: WindowAccessor.updateNSView called")
        DispatchQueue.main.async {
            print("DEBUG: WindowAccessor.updateNSView async - checking for window")
            if let window = nsView.window {
                print("DEBUG: WindowAccessor.updateNSView found window, calling configureFloatingWindow")
                configureFloatingWindow(window)
            } else {
                print("DEBUG: WindowAccessor.updateNSView - view.window is nil")
            }
        }
    }
    
    private func configureFloatingWindow(_ window: NSWindow) {
        // #region agent log
        print("DEBUG: FloatingWindowModifier.configureFloatingWindow called - id: \(window.identifier?.rawValue ?? "nil")")
        // #endregion
        
        // Set window identifier if not set
        if window.identifier == nil {
            window.identifier = NSUserInterfaceItemIdentifier("floating-control")
        }
        
        // Ensure a unique, explicit title for matching and to avoid collisions
        if window.title != "floating-control" {
            window.title = "floating-control"
        }
        
        // Set delegate to prevent auto-closing
        if window.delegate == nil {
            window.delegate = FloatingWindowDelegate.shared
        }
        
        // Ensure delegate doesn't allow closing
        FloatingWindowDelegate.shared.setAllowClose(false)
        
        // Prevent window from auto-closing when it loses focus
        window.isReleasedWhenClosed = false
        window.hidesOnDeactivate = false
        window.canHide = false
        
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = true
        window.backgroundColor = .clear
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true
        
        // TEMPORARILY DISABLED - Changing styleMask on an existing window can cause it to disappear in SwiftUI
        // window.styleMask = [.borderless, .fullSizeContentView]
        // window.isOpaque = false
        
        // #region agent log
        print("DEBUG: FloatingWindowModifier.configureFloatingWindow completed - id: \(window.identifier?.rawValue ?? "nil"), borderless: \(window.styleMask.contains(.borderless)), level: \(window.level)")
        // #endregion
        
        // Configure content view
        if let contentView = window.contentView {
            contentView.wantsLayer = true
            contentView.layer?.masksToBounds = true
            // Ensure content starts at the very top - remove any insets
            let contentRect = window.contentRect(forFrameRect: window.frame)
            contentView.frame = contentRect
        }
        
        // Ensure window stays visible
        // Use orderFrontRegardless() instead of makeKeyAndOrderFront() 
        // because borderless windows cannot become key windows
        window.orderFrontRegardless()
        
        // Force window to update its layout
        window.invalidateShadow()
        window.displayIfNeeded()
    }
}

extension View {
    func floatingWindowStyle() -> some View {
        modifier(FloatingWindowModifier())
    }
}

