//
//  FloatingControlWindow.swift
//  TextListener
//
//  Floating control window with reading progress timeline
//

import SwiftUI
import AppKit

struct FloatingControlWindow: View {
    @EnvironmentObject var speechManager: SpeechManager
    @EnvironmentObject var textCapture: TextCaptureManager
    @EnvironmentObject var windowManager: FloatingWindowManager
    
    var body: some View {
        ZStack {
            // Darker semi-transparent background for better contrast on white surfaces
            // Similar to macOS menu bar popover styling
            Color.black.opacity(0.4)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
            
            // Background fills entire frame - corner radius handled by window layer
            // Using .popover material for darker, more opaque appearance like menu bar dropdowns
            VisualEffectView(material: .popover, blendingMode: .withinWindow)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                // Title Bar Area - Control buttons positioned where macOS title bar buttons would be
                HStack {
                    Spacer()
                    
                    // Title Bar Control Buttons (positioned like macOS window controls)
                    HStack(spacing: 6) {
                        // Settings button
                        Button(action: { 
                            NSApp.activate(ignoringOtherApps: true)
                            NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 11))
                                .frame(width: 14, height: 14)
                        }
                        .buttonStyle(.plain)
                        .help("Settings")

                        // Hide window button
                        Button(action: { windowManager.hideWindow() }) {
                            Image(systemName: "minus")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 11, weight: .semibold))
                                .frame(width: 14, height: 14)
                        }
                        .buttonStyle(.plain)
                        .help("Hide Window")
                        
                        // Exit/Quit button
                        Button(action: { NSApplication.shared.terminate(nil) }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.white.opacity(0.9))
                                .font(.system(size: 11, weight: .semibold))
                                .frame(width: 14, height: 14)
                        }
                        .buttonStyle(.plain)
                        .help("Quit TextListener")
                    }
                    .padding(.trailing, 10)
                    .padding(.top, 7)
                }
                .frame(height: 22) // Standard macOS title bar height
                
                // Compact Header with Status Indicator (Heuristic 1: Visibility of system status)
                HStack(spacing: 12) {
                    // Brand logo and Title
                    HStack(spacing: 6) {
                        SVGImage("MenuBarLogo", size: CGSize(width: 14, height: 14))
                            .opacity(0.8)
                        Text("TextListener")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    // Status indicator badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 6, height: 6)
                        Text(statusText)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    Spacer()
                    
                    // Speed indicator (Heuristic 7: Flexibility and efficiency)
                    HStack(spacing: 4) {
                        Image(systemName: "speedometer")
                            .font(.system(size: 10))
                            .foregroundColor(.white.opacity(0.9))
                        Text(String(format: "%.1fx", speechManager.speechRate))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 8)
                
                Divider()
                    .background(Color.white.opacity(0.2))
                
                // Main Content Area - Fixed height with clipping to prevent window expansion
                VStack(spacing: 12) {
                    // Progress Bar (Heuristic 1: Visibility of system status)
                    VStack(spacing: 4) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                Capsule()
                                    .fill(Color.white.opacity(0.2))
                                    .frame(height: 6)
                                
                                // Progress fill with smooth animation
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geometry.size.width * CGFloat(speechManager.progress), height: 6)
                                    .animation(.easeInOut(duration: 0.2), value: speechManager.progress)
                            }
                        }
                        .frame(height: 6)
                        
                        // Progress percentage (Heuristic 6: Recognition rather than recall)
                        HStack {
                            Spacer()
                            Text("\(Int(speechManager.progress * 100))%")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Speed Control (Heuristic 7: Flexibility and efficiency)
                    VStack(spacing: 6) {
                        HStack {
                            Image(systemName: "tortoise")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.9))
                            Slider(
                                value: Binding(
                                    get: { Double(speechManager.speechRate) },
                                    set: { speechManager.speechRate = Float($0) }
                                ),
                                in: 0.0...2.0,
                                step: 0.1
                            )
                            .tint(.white)
                            Image(systemName: "hare")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.9))
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // Primary Action Button (Heuristic 3: User control and freedom)
                    Button(action: readSelection) {
                        Image(systemName: primaryActionIcon)
                            .font(.system(size: 18, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .disabled(speechManager.isSpeaking && !speechManager.isPaused) // Heuristic 5: Error prevention
                    .help(primaryActionText)
                    .padding(.horizontal, 16)
                    
                    // Secondary Controls (Heuristic 4: Consistency and standards - media player pattern)
                    if speechManager.isSpeaking {
                        HStack(spacing: 8) {
                            Button(action: { speechManager.isPaused ? speechManager.resume() : speechManager.pause() }) {
                                Image(systemName: speechManager.isPaused ? "play.fill" : "pause.fill")
                                    .font(.system(size: 12))
                                    .frame(width: 32, height: 32)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                            
                            Button(action: { speechManager.stop() }) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 12))
                                    .frame(width: 32, height: 32)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Error Messages (Heuristic 1: Visibility of system status) - Clipped if too long
                    if let error = textCapture.captureError {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.orange)
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.orange.opacity(0.1))
                        )
                        .padding(.horizontal, 16)
                    }
                }
                .padding(.top, 8)
                .padding(.bottom, 12)
                .frame(maxHeight: .infinity)
                .clipped()
            }
        }
        .frame(width: 380, height: 220)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        // Corner radius and shadow handled by window layer configuration
    }
    
    // Heuristic 1: Visibility of system status
    private var statusColor: Color {
        if speechManager.isSpeaking {
            return speechManager.isPaused ? .orange : .green
        }
        return .white.opacity(0.6)
    }
    
    private var statusText: String {
        if speechManager.isSpeaking {
            return speechManager.isPaused ? "Paused" : "Playing"
        }
        return "Ready"
    }
    
    // Heuristic 6: Recognition rather than recall
    private var primaryActionIcon: String {
        if speechManager.isSpeaking && speechManager.isPaused {
            return "play.fill"
        }
        return "play.fill"
    }
    
    private var primaryActionText: String {
        if speechManager.isSpeaking && speechManager.isPaused {
            return "Resume"
        }
        return "Read Selection"
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
}

// Visual Effect View for blur background (similar to expo-blur)
struct VisualEffectView: NSViewRepresentable {
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

