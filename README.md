# TextListener

A native macOS utility that captures selected text from any application and reads it aloud using TTS (Text-to-Speech).

## Features

- 🎯 **Menu Bar Only**: Runs exclusively in the menu bar (no Dock icon)
- 🎤 **Text Capture**: Uses Accessibility API to capture selected text globally
- 🔊 **Speech Synthesis**: Utilizes AVSpeechSynthesizer for text-to-speech
- ⚡ **Speed Controls**: Slider to adjust reading speed
- 🎛️ **Floating Window**: Always-on-top control window with reading progress
- 🎨 **Modern UI**: Interface following Nielsen's heuristic principles with blur effects

## Requirements

- macOS 13.0+ (Ventura or later)
- Xcode 14.0+
- Swift 5.7+

## Project Structure

```
TextListener/
├── TextListenerApp.swift          # Main app with MenuBarExtra
├── SpeechManager.swift            # Speech synthesis manager
├── TextCaptureManager.swift       # Text capture via Accessibility API
├── MenuBarView.swift              # Menu bar interface
├── FloatingControlWindow.swift    # Floating control window
├── FloatingWindowModifier.swift   # Modifier to configure floating window
└── Info.plist                     # Configuration (LSUIElement = true)
```

## Setup

### 1. Create Project in Xcode

1. Open Xcode
2. Create a new macOS App project
3. Select SwiftUI as the interface
4. Copy the files from this repository to the project

### 2. Configure Info.plist

The `Info.plist` file is already configured with:
- `LSUIElement = true` - Removes Dock icon
- High-resolution settings

### 3. Accessibility Permissions

The app requires accessibility permissions to capture selected text:

1. Go to **System Settings > Privacy & Security > Accessibility**
2. Add TextListener to the list of allowed apps
3. Restart the app after granting permissions

## Usage

1. **Launch App**: Run the app - it will appear only in the menu bar
2. **Select Text**: Select text in any application
3. **Read Text**: Click the icon in the menu bar and select "Read Selection"
4. **Controls**: Use the pause/resume/stop buttons to control reading
5. **Speed**: Adjust the speed slider as needed
6. **Floating Window**: Enable the floating window to see reading progress

## Technical Features

### SpeechManager
- Manages speech synthesis using `AVSpeechSynthesizer`
- Supports play, pause, resume, and stop
- Controls speech speed
- Tracks reading progress (approximate)

### TextCaptureManager
- Uses `AXUIElement` (Accessibility API) to capture selected text
- Recursively searches for selected text in UI hierarchy
- Falls back to clipboard if Accessibility API fails

### Floating Window
- Always-on-top window (`.floating` level)
- Blur effect using `NSVisualEffectView`
- Shows reading progress in real-time
- Integrated playback controls

## Implementation Notes

### Accessibility API
Text capture uses macOS Accessibility API. Some applications may not expose selected text through this API. In these cases, the app uses the clipboard as a fallback (requires the user to copy the text manually).

### Reading Progress
`AVSpeechSynthesizer` does not provide exact reading progress. The current implementation uses a time-based estimate. For a more precise implementation, it would be necessary to track word/character positions manually.

## Design Principles

The interface follows Nielsen's heuristic principles:
1. **Visibility of System Status**: Progress and state always visible
2. **Match Between System and Real World**: Familiar controls (play, pause, stop)
3. **User Control**: Clear controls for all actions
4. **Consistency**: macOS UI patterns
5. **Error Prevention**: Validation before actions
6. **Recognition**: Clear icons and labels
7. **Flexibility**: Multiple access methods (menu bar and floating window)
8. **Minimalist Design**: Clean and focused interface

## License

Copyright © 2024. All rights reserved.

