# Accessibility Permissions During Development

## Issue
When rebuilding the app from Xcode, macOS may revoke accessibility permissions because it treats each rebuild as a potentially different app. This happens because:

1. **Code Signature Changes**: Even with consistent signing, macOS tracks apps by bundle identifier + code signature + app path
2. **App Path Changes**: Xcode may build to different locations
3. **Timestamp Differences**: macOS uses various factors to identify apps

## Solution

### For Development
1. **Re-grant permission after each rebuild**:
   - Open System Settings > Privacy & Security > Accessibility
   - Find TextListener and toggle it ON (or add it if missing)
   - The app will automatically detect the permission change

2. **Use the Settings UI**:
   - Click "Request Permission" button
   - Or click "Open System Settings" to manually add the app
   - The permission status updates automatically every second

### For Production
- Use consistent code signing with a development team
- Archive and distribute through proper channels (App Store, notarization, etc.)
- Production builds with consistent signing won't have this issue

## Technical Details

The app uses `AXIsProcessTrustedWithOptions` to check permissions. The Settings view:
- Checks permissions every second while open
- Verifies permissions by attempting actual API calls
- Provides easy buttons to request or re-grant permission

## Code Signing

The project is configured with:
- **Debug builds**: Ad-hoc signing (`CODE_SIGN_IDENTITY = "-"`)
- **Release builds**: Automatic signing (should use your development team)

To use a development team for more consistent signing:
1. Open the project in Xcode
2. Select the TextListener target
3. Go to "Signing & Capabilities"
4. Select your development team
5. This will use your team's certificate for consistent signing

