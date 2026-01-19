#!/bin/bash

# Script to automatically create Xcode project for TextListener
# This script creates a complete Xcode project structure

set -e

PROJECT_NAME="TextListener"
WORKSPACE_DIR="$(pwd)"
PROJECT_DIR="$WORKSPACE_DIR/$PROJECT_NAME.xcodeproj"
CONTENTS_DIR="$PROJECT_DIR/project.xcworkspace/xcshareddata/swiftpm"

echo "🚀 Creating Xcode project for $PROJECT_NAME..."

# Create project directory structure
mkdir -p "$PROJECT_DIR"
mkdir -p "$CONTENTS_DIR"

# Create project.pbxproj file
cat > "$PROJECT_DIR/project.pbxproj" << 'PROJECT_EOF'
// !$*UTF8*$!
{
	archiveVersion = 1;
	classes = {
	};
	objectVersion = 56;
	objects = {
/* Begin PBXBuildFile section */
		TEXT001 /* TextListenerApp.swift */ = {isa = PBXBuildFile; fileRef = TEXT002 /* TextListenerApp.swift */; };
		TEXT003 /* SpeechManager.swift */ = {isa = PBXBuildFile; fileRef = TEXT004 /* SpeechManager.swift */; };
		TEXT005 /* TextCaptureManager.swift */ = {isa = PBXBuildFile; fileRef = TEXT006 /* TextCaptureManager.swift */; };
		TEXT007 /* MenuBarView.swift */ = {isa = PBXBuildFile; fileRef = TEXT008 /* MenuBarView.swift */; };
		TEXT009 /* FloatingControlWindow.swift */ = {isa = PBXBuildFile; fileRef = TEXT010 /* FloatingControlWindow.swift */; };
		TEXT011 /* FloatingWindowModifier.swift */ = {isa = PBXBuildFile; fileRef = TEXT012 /* FloatingWindowModifier.swift */; };
		TEXT013 /* Assets.xcassets */ = {isa = PBXBuildFile; fileRef = TEXT014 /* Assets.xcassets */; };
		TEXT015 /* Info.plist */ = {isa = PBXBuildFile; fileRef = TEXT016 /* Info.plist */; };
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
		TEXT017 /* TextListener.app */ = {isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = TextListener.app; sourceTree = BUILT_PRODUCTS_DIR; };
		TEXT002 /* TextListenerApp.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TextListenerApp.swift; sourceTree = "<group>"; };
		TEXT004 /* SpeechManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = SpeechManager.swift; sourceTree = "<group>"; };
		TEXT006 /* TextCaptureManager.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = TextCaptureManager.swift; sourceTree = "<group>"; };
		TEXT008 /* MenuBarView.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = MenuBarView.swift; sourceTree = "<group>"; };
		TEXT010 /* FloatingControlWindow.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FloatingControlWindow.swift; sourceTree = "<group>"; };
		TEXT012 /* FloatingWindowModifier.swift */ = {isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = FloatingWindowModifier.swift; sourceTree = "<group>"; };
		TEXT014 /* Assets.xcassets */ = {isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = Assets.xcassets; sourceTree = "<group>"; };
		TEXT016 /* Info.plist */ = {isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = Info.plist; sourceTree = "<group>"; };
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		TEXT018 /* Frameworks */ = {
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		TEXT019 = {
			isa = PBXGroup;
			children = (
				TEXT020 /* TextListener */,
				TEXT021 /* Products */,
			);
			sourceTree = "<group>";
		};
		TEXT020 /* TextListener */ = {
			isa = PBXGroup;
			children = (
				TEXT002 /* TextListenerApp.swift */,
				TEXT004 /* SpeechManager.swift */,
				TEXT006 /* TextCaptureManager.swift */,
				TEXT008 /* MenuBarView.swift */,
				TEXT010 /* FloatingControlWindow.swift */,
				TEXT012 /* FloatingWindowModifier.swift */,
				TEXT014 /* Assets.xcassets */,
				TEXT016 /* Info.plist */,
			);
			path = TextListener;
			sourceTree = "<group>";
		};
		TEXT021 /* Products */ = {
			isa = PBXGroup;
			children = (
				TEXT017 /* TextListener.app */,
			);
			name = Products;
			sourceTree = "<group>";
		};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		TEXT022 /* TextListener */ = {
			isa = PBXNativeTarget;
			buildConfigurationList = TEXT023 /* Build configuration list for PBXNativeTarget "TextListener" */;
			buildPhases = (
				TEXT024 /* Sources */,
				TEXT018 /* Frameworks */,
				TEXT025 /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = TextListener;
			productName = TextListener;
			productReference = TEXT017 /* TextListener.app */;
			productType = "com.apple.product-type.application";
		};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		TEXT026 /* Project object */ = {
			isa = PBXProject;
			attributes = {
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1500;
				LastUpgradeCheck = 1500;
				TargetAttributes = {
					TEXT022 = {
						CreatedOnToolsVersion = 15.0;
					};
				};
			};
			buildConfigurationList = TEXT027 /* Build configuration list for PBXProject "TextListener" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = TEXT019;
			productRefGroup = TEXT021 /* Products */;
			projectDirPath = "";
			projectRoot = "";
			targets = (
				TEXT022 /* TextListener */,
			);
		};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		TEXT025 /* Resources */ = {
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				TEXT013 /* Assets.xcassets */,
				TEXT015 /* Info.plist */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		TEXT024 /* Sources */ = {
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
				TEXT001 /* TextListenerApp.swift */,
				TEXT003 /* SpeechManager.swift */,
				TEXT005 /* TextCaptureManager.swift */,
				TEXT007 /* MenuBarView.swift */,
				TEXT009 /* FloatingControlWindow.swift */,
				TEXT011 /* FloatingWindowModifier.swift */,
			);
			runOnlyForDeploymentPostprocessing = 0;
		};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		TEXT028 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				MTL_FAST_MATH = YES;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = macosx;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = "DEBUG $(inherited)";
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			};
			name = Debug;
		};
		TEXT029 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ALWAYS_SEARCH_USER_PATHS = NO;
				ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS = YES;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;
				CLANG_CXX_LANGUAGE_STANDARD = "gnu++20";
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				CLANG_ENABLE_OBJC_WEAK = YES;
				CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING = YES;
				CLANG_WARN_BOOL_CONVERSION = YES;
				CLANG_WARN_COMMA = YES;
				CLANG_WARN_CONSTANT_CONVERSION = YES;
				CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS = YES;
				CLANG_WARN_DIRECT_OBJC_ISA_USAGE = YES_ERROR;
				CLANG_WARN_DOCUMENTATION_COMMENTS = YES;
				CLANG_WARN_EMPTY_BODY = YES;
				CLANG_WARN_ENUM_CONVERSION = YES;
				CLANG_WARN_INFINITE_RECURSION = YES;
				CLANG_WARN_INT_CONVERSION = YES;
				CLANG_WARN_NON_LITERAL_NULL_CONVERSION = YES;
				CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF = YES;
				CLANG_WARN_OBJC_LITERAL_CONVERSION = YES;
				CLANG_WARN_OBJC_ROOT_CLASS = YES_ERROR;
				CLANG_WARN_QUOTED_INCLUDE_IN_FRAMEWORK_HEADER = YES;
				CLANG_WARN_RANGE_LOOP_ANALYSIS = YES;
				CLANG_WARN_STRICT_PROTOTYPES = YES;
				CLANG_WARN_SUSPICIOUS_MOVE = YES;
				CLANG_WARN_UNGUARDED_AVAILABILITY = YES_AGGRESSIVE;
				CLANG_WARN_UNREACHABLE_CODE = YES;
				CLANG_WARN__DUPLICATE_METHOD_MATCH = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_USER_SCRIPT_SANDBOXING = YES;
				GCC_C_LANGUAGE_STANDARD = gnu17;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_WARN_64_TO_32_BIT_CONVERSION = YES;
				GCC_WARN_ABOUT_RETURN_TYPE = YES_ERROR;
				GCC_WARN_UNDECLARED_SELECTOR = YES;
				GCC_WARN_UNINITIALIZED_AUTOS = YES_AGGRESSIVE;
				GCC_WARN_UNUSED_FUNCTION = YES;
				GCC_WARN_UNUSED_VARIABLE = YES;
				LOCALIZATION_PREFERS_STRING_CATALOGS = YES;
				MACOSX_DEPLOYMENT_TARGET = 13.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				MTL_FAST_MATH = YES;
				SDKROOT = macosx;
				SWIFT_COMPILATION_MODE = wholemodule;
			};
			name = Release;
		};
		TEXT030 /* Debug */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = TextListener/TextListener.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = TextListener/Info.plist;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.textlistener.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Debug;
		};
		TEXT031 /* Release */ = {
			isa = XCBuildConfiguration;
			buildSettings = {
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_ENTITLEMENTS = TextListener/TextListener.entitlements;
				CODE_SIGN_STYLE = Automatic;
				COMBINE_HIDPI_IMAGES = YES;
				CURRENT_PROJECT_VERSION = 1;
				DEVELOPMENT_ASSET_PATHS = "";
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = TextListener/Info.plist;
				INFOPLIST_KEY_NSHumanReadableCopyright = "";
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/../Frameworks",
				);
				MARKETING_VERSION = 1.0;
				PRODUCT_BUNDLE_IDENTIFIER = com.textlistener.app;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
			};
			name = Release;
		};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		TEXT027 /* Build configuration list for PBXProject "TextListener" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				TEXT028 /* Debug */,
				TEXT029 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
		TEXT023 /* Build configuration list for PBXNativeTarget "TextListener" */ = {
			isa = XCConfigurationList;
			buildConfigurations = (
				TEXT030 /* Debug */,
				TEXT031 /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		};
/* End XCConfigurationList section */
	};
	rootObject = TEXT026 /* Project object */;
}
PROJECT_EOF

echo "✅ Created project.pbxproj"

# Create workspace settings
mkdir -p "$PROJECT_DIR/project.xcworkspace"
cat > "$PROJECT_DIR/project.xcworkspace/contents.xcworkspacedata" << 'WORKSPACE_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "self:">
   </FileRef>
</Workspace>
WORKSPACE_EOF

echo "✅ Created workspace"

# Create scheme
mkdir -p "$PROJECT_DIR/xcshareddata/xcschemes"
cat > "$PROJECT_DIR/xcshareddata/xcschemes/TextListener.xcscheme" << 'SCHEME_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<Scheme
   LastUpgradeVersion = "1500"
   version = "1.7">
   <BuildAction
      parallelizeBuildables = "YES"
      buildImplicitDependencies = "YES">
      <BuildActionEntries>
         <BuildActionEntry
            buildForTesting = "YES"
            buildForRunning = "YES"
            buildForProfiling = "YES"
            buildForArchiving = "YES"
            buildForAnalyzing = "YES">
            <BuildableReference
               BuildableIdentifier = "primary"
               BlueprintIdentifier = "TEXT022"
               BuildableName = "TextListener.app"
               BlueprintName = "TextListener"
               ReferencedContainer = "container:TextListener.xcodeproj">
            </BuildableReference>
         </BuildActionEntry>
      </BuildActionEntries>
   </BuildAction>
   <TestAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      shouldUseLaunchSchemeArgsEnv = "YES"
      shouldAutocreateTestPlan = "YES">
   </TestAction>
   <LaunchAction
      buildConfiguration = "Debug"
      selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
      selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
      launchStyle = "0"
      useCustomWorkingDirectory = "NO"
      ignoresPersistentStateOnLaunch = "NO"
      debugDocumentVersioning = "YES"
      debugServiceExtension = "internal"
      allowLocationSimulation = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "TEXT022"
            BuildableName = "TextListener.app"
            BlueprintName = "TextListener"
            ReferencedContainer = "container:TextListener.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </LaunchAction>
   <ProfileAction
      buildConfiguration = "Release"
      shouldUseLaunchSchemeArgsEnv = "YES"
      savedToolIdentifier = ""
      useCustomWorkingDirectory = "NO"
      debugDocumentVersioning = "YES">
      <BuildableProductRunnable
         runnableDebuggingMode = "0">
         <BuildableReference
            BuildableIdentifier = "primary"
            BlueprintIdentifier = "TEXT022"
            BuildableName = "TextListener.app"
            BlueprintName = "TextListener"
            ReferencedContainer = "container:TextListener.xcodeproj">
         </BuildableReference>
      </BuildableProductRunnable>
   </ProfileAction>
   <AnalyzeAction
      buildConfiguration = "Debug">
   </AnalyzeAction>
   <ArchiveAction
      buildConfiguration = "Release"
      revealArchiveInOrganizer = "YES">
   </ArchiveAction>
</Scheme>
SCHEME_EOF

echo "✅ Created scheme"

# Create entitlements file
cat > "$WORKSPACE_DIR/TextListener/TextListener.entitlements" << 'ENTITLEMENTS_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<false/>
</dict>
</plist>
ENTITLEMENTS_EOF

echo "✅ Created entitlements file"

# Create Assets.xcassets if it doesn't exist
if [ ! -d "$WORKSPACE_DIR/TextListener/Assets.xcassets" ]; then
    mkdir -p "$WORKSPACE_DIR/TextListener/Assets.xcassets/AppIcon.appiconset"
    mkdir -p "$WORKSPACE_DIR/TextListener/Assets.xcassets/AccentColor.colorset"
    
    cat > "$WORKSPACE_DIR/TextListener/Assets.xcassets/Contents.json" << 'ASSETS_EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
ASSETS_EOF

    cat > "$WORKSPACE_DIR/TextListener/Assets.xcassets/AppIcon.appiconset/Contents.json" << 'APPICON_EOF'
{
  "images" : [
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "16x16"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "16x16"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "32x32"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "32x32"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "128x128"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "128x128"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "256x256"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "256x256"
    },
    {
      "idiom" : "mac",
      "scale" : "1x",
      "size" : "512x512"
    },
    {
      "idiom" : "mac",
      "scale" : "2x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
APPICON_EOF

    cat > "$WORKSPACE_DIR/TextListener/Assets.xcassets/AccentColor.colorset/Contents.json" << 'COLOR_EOF'
{
  "colors" : [
    {
      "idiom" : "universal"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
COLOR_EOF

    echo "✅ Created Assets.xcassets"
fi

echo ""
echo "🎉 Xcode project created successfully!"
echo ""
echo "📁 Project location: $PROJECT_DIR"
echo ""
echo "🚀 Next steps:"
echo "   1. Open TextListener.xcodeproj in Xcode"
echo "   2. Build and run (⌘R)"
echo "   3. Grant Accessibility permissions in System Settings"
echo ""
echo "✨ Done! You can now open the project in Xcode."

