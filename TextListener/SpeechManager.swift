//
//  SpeechManager.swift
//  TextListener
//
//  Speech synthesis manager using AVSpeechSynthesizer
//

import AVFoundation
import Combine
import Foundation

@MainActor
class SpeechManager: NSObject, ObservableObject {
    private let synthesizer = AVSpeechSynthesizer()
    private var currentUtterance: AVSpeechUtterance?
    
    @Published var isSpeaking = false
    @Published var isPaused = false
    
    /// Callback to be called when speech finishes or is cancelled
    var onSpeechFinished: (() -> Void)?
    // Speech rate multiplier (0.0x to 2.0x, where 1.0x is normal speed)
    @Published var speechRate: Float = 1.0 {
        didSet {
            // Save to UserDefaults
            UserDefaults.standard.set(Double(speechRate), forKey: "speechRate")
            // Update current utterance if speaking
            if let utterance = currentUtterance {
                utterance.rate = rateForUtterance
            }
        }
    }
    
    // Convert speech rate multiplier (0.0-2.0) to AVSpeechUtterance rate (0.0-1.0)
    // 0.0x → 0.0 (minimum), 1.0x → 0.5 (normal), 2.0x → 1.0 (maximum)
    private var rateForUtterance: Float {
        return speechRate * 0.5
    }
    @Published var progress: Double = 0.0
    @Published var currentText: String = ""
    
    private var progressTimer: Timer?
    
    override init() {
        super.init()
        configureAudioSession()
        synthesizer.delegate = self
        // Load saved speech rate from UserDefaults
        let savedRate = UserDefaults.standard.double(forKey: "speechRate")
        if savedRate > 0 {
            speechRate = Float(savedRate)
        } else {
            // Default to 1.0x (normal speed) if no saved value
            speechRate = 1.0
        }
    }
    
    private func configureAudioSession() {
        #if os(iOS)
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .spokenAudio, options: [.mixWithOthers, .duckOthers])
            try audioSession.setActive(true)
        } catch {
            // Log error but don't fail - speech synthesis will still work
            print("Failed to configure audio session: \(error.localizedDescription)")
        }
        #elseif os(macOS)
        // On macOS, audio session configuration is handled automatically
        // The warnings are typically harmless and related to internal audio unit management
        // AVSpeechSynthesizer handles audio routing automatically on macOS
        #endif
    }
    
    func speak(_ text: String) {
        stop()
        
        guard !text.isEmpty else { return }
        
        // Clean up any previous state
        currentText = text
        progress = 0.0
        
        let utterance = AVSpeechUtterance(string: text)
        
        // Configure utterance with proper rate (clamped to valid range)
        utterance.rate = max(0.0, min(1.0, rateForUtterance))
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0
        
        // Use system default voice or preferred voice
        // Prefer the default voice, but fall back to any available voice
        if let defaultVoice = AVSpeechSynthesisVoice(language: nil) {
            utterance.voice = defaultVoice
        } else if let voice = AVSpeechSynthesisVoice(language: "en-US") {
            utterance.voice = voice
        }
        
        currentUtterance = utterance
        
        // Ensure we're on the main thread for UI updates
        synthesizer.speak(utterance)
        isSpeaking = true
        isPaused = false
        
        startProgressTracking()
    }
    
    func pause() {
        guard isSpeaking && !isPaused else { return }
        synthesizer.pauseSpeaking(at: .immediate)
        isPaused = true
        stopProgressTracking()
    }
    
    func resume() {
        guard isSpeaking && isPaused else { return }
        synthesizer.continueSpeaking()
        isPaused = false
        startProgressTracking()
    }
    
    func stop() {
        stopProgressTracking()
        synthesizer.stopSpeaking(at: .immediate)
        
        // Clear state
        isSpeaking = false
        isPaused = false
        progress = 0.0
        currentText = ""
        currentUtterance = nil
    }
    
    deinit {
        // Cleanup - timer will be invalidated automatically when deallocated
        synthesizer.stopSpeaking(at: .immediate)
        synthesizer.delegate = nil
    }
    
    private func startProgressTracking() {
        stopProgressTracking()
        
        // Estimate progress based on time (simplified approach)
        // Note: AVSpeechSynthesizer doesn't provide direct progress tracking
        // This is an approximation based on utterance duration
        progressTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // Approximate progress (this is a simplified calculation)
            // Note: AVSpeechSynthesizer doesn't provide direct progress tracking
            // This is an approximation based on utterance duration
            Task { @MainActor in
                // Progress estimation based on time elapsed vs estimated duration
                // This is approximate since AVSpeechSynthesizer doesn't expose exact progress
                if self.isSpeaking && !self.isPaused {
                    // Increment progress slowly (this is a placeholder)
                    // Real implementation would require tracking actual speech position
                    self.progress = min(self.progress + 0.01, 1.0)
                }
            }
        }
    }
    
    private func stopProgressTracking() {
        progressTimer?.invalidate()
        progressTimer = nil
    }
}

extension SpeechManager: AVSpeechSynthesizerDelegate {
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = true
            isPaused = false
            progress = 0.0
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
            isPaused = false
            progress = 1.0
            currentText = ""
            currentUtterance = nil
            stopProgressTracking()
            onSpeechFinished?()
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isSpeaking = false
            isPaused = false
            progress = 0.0
            currentText = ""
            currentUtterance = nil
            stopProgressTracking()
            onSpeechFinished?()
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPaused = true
        }
    }
    
    nonisolated func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        Task { @MainActor in
            isPaused = false
        }
    }
}

