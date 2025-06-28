# No-Cluely Driver 🎯

A simple, lightweight library for detecting Cluely employee monitoring software and its **specific evasion techniques** from Swift applications on macOS.

## Overview

This library provides a **dead simple** way to detect if Cluely (or similar employee monitoring software) is running on a macOS system. It specifically detects the **exact evasion techniques** that Cluely uses to hide from screen sharing and recording software.

## ✨ New: Evasion Technique Detection

The library now detects and reports **specific techniques** Cluely uses to avoid detection:

- **🚫 Screen Capture Evasion**: Windows configured with `sharing_state = 0` to avoid screen recording
- **🔼 Elevated Layer Positioning**: Windows using elevated display layers (e.g., `layer = 3`) to stay above screen capture
- **📊 Detailed Reporting**: Comprehensive text reports explaining exactly what was found

## Features

- ✅ **Ultra Simple API** - Just one function call to detect Cluely
- ✅ **Evasion Analysis** - Detects specific techniques Cluely uses to hide
- ✅ **Detailed Reports** - Text reports explaining what evasion techniques were found
- ✅ **Swift-Friendly** - Native Swift wrapper with modern syntax
- ✅ **Zero Dependencies** - Uses only macOS system frameworks
- ✅ **Lightweight** - Minimal performance impact
- ✅ **Thread Safe** - Can be called from any thread

## Quick Start

### 1. Build the Library

```bash
git clone <repository>
cd no-cluely-driver
./install.sh
```

### 2. Add to Your Swift Project

Copy these files to your Xcode project:
- `swift-integration/libno_cluely_driver.dylib`
- `swift-integration/no_cluely_driver.h`
- `swift-integration/ClueLyDetector.swift`

### 3. Use in Your Code

```swift
import Foundation

// Simplest usage - just check if Cluely is running
if ClueLyDetector.isClueLyRunning() {
    print("⚠️ Employee monitoring detected!")
} else {
    print("✅ All clear!")
}

// Detailed analysis with evasion techniques
let detection = ClueLyDetector.detectClueLyDetailed()
if detection.isDetected {
    print("🚨 Cluely detected using: \(detection.evasionTechniques.joined(separator: ", "))")
    print("📊 Severity: \(detection.severityLevel)")
}

// Full text report
let report = ClueLyDetector.getClueLyReport()
print(report)
```

## API Reference

### Swift API

```swift
public class ClueLyDetector {
    /// Simplest check - returns true if Cluely is detected
    static func isClueLyRunning() -> Bool
    
    /// Basic detection with window count
    static func detectClueLy() -> (isDetected: Bool, windowCount: UInt32)
    
    /// 🆕 Detailed detection with evasion technique analysis
    static func detectClueLyDetailed() -> ClueLyDetection
    
    /// 🆕 Get detailed text report
    static func getClueLyReport() -> String
    
    /// Get number of Cluely windows only
    static func getClueLyWindowCount() -> UInt32
}

/// 🆕 Detailed detection result
public struct ClueLyDetection {
    public let isDetected: Bool
    public let windowCount: UInt32
    public let screenCaptureEvasionCount: UInt32  // Windows avoiding screen capture
    public let elevatedLayerCount: UInt32         // Windows using elevated layers
    public let maxLayerDetected: Int32            // Highest layer number found
    public let report: String                     // Detailed text report
    
    public var evasionTechniques: [String]        // Summary of techniques used
    public var severityLevel: String              // "Low", "Medium", "High"
}
```

### C API (if you prefer direct calls)

```c
// Enhanced detection result with evasion analysis
typedef struct {
    bool is_detected;
    uint32_t window_count;
    uint32_t screen_capture_evasion_count;   // NEW: Windows avoiding screen capture
    uint32_t elevated_layer_count;           // NEW: Windows using elevated layers
    int32_t max_layer_detected;              // NEW: Highest layer number found
} ClueLyDetectionResult;

// Simple boolean check
int is_cluely_running(void);

// Detailed detection with evasion analysis
ClueLyDetectionResult detect_cluely(void);

// NEW: Get detailed text report (must free with free_cluely_report)
char* get_cluely_report(void);
void free_cluely_report(char* report);
```

## 🎯 Evasion Techniques Detected

### Screen Capture Evasion
**What it is**: Cluely configures windows with `sharing_state = 0` to make them invisible to screen recording software.

**Why it matters**: These windows continue monitoring even during screen sharing calls, but won't appear in recordings.

### Elevated Layer Positioning  
**What it is**: Cluely places windows on elevated display layers (e.g., `layer = 3`) above normal application windows.

**Why it matters**: These windows can overlay content and remain active during screen sharing while staying hidden.

## Usage Examples

### Simple Detection
```swift
func checkForMonitoring() {
    if ClueLyDetector.isClueLyRunning() {
        showAlert("Employee monitoring software detected!")
    }
}
```

### Detailed Evasion Analysis
```swift
func analyzeEvasionTechniques() {
    let detection = ClueLyDetector.detectClueLyDetailed()
    
    if detection.isDetected {
        print("🚨 Cluely Detection Results:")
        print("   Severity: \(detection.severityLevel)")
        print("   Windows: \(detection.windowCount)")
        
        if detection.screenCaptureEvasionCount > 0 {
            print("   ⚠️ \(detection.screenCaptureEvasionCount) windows avoiding screen capture")
        }
        if detection.elevatedLayerCount > 0 {
            print("   ⚠️ \(detection.elevatedLayerCount) windows using elevated layers")
        }
        
        print("   Techniques: \(detection.evasionTechniques.joined(separator: ", "))")
    }
}
```

### Full Report Generation
```swift
func generateReport() {
    let report = ClueLyDetector.getClueLyReport()
    
    // Example output when Cluely is detected:
    /*
    🚨 CLUELY EMPLOYEE MONITORING DETECTED
    =====================================
    
    📊 Summary:
       • Total Cluely windows: 2
       • Screen capture evasion: 2
       • Elevated layer usage: 1
       • Highest layer detected: 3
    
    🔍 Evasion Techniques Detected:
       ⚠️  2 window(s) configured to avoid screen capture
       ⚠️  1 window(s) using elevated display layers
    
    📋 Window Details:
       1. Window ID: 12345 [Cluely]
          - Sharing State: 0 (avoiding screen capture)
          - Layer: 0 (normal)
          - Techniques: Screen capture evasion
    
       2. Window ID: 12346 [Cluely]
          - Sharing State: 0 (avoiding screen capture)
          - Layer: 3 (elevated - potential overlay)
          - Techniques: Screen capture evasion, Elevated layer positioning
    
    ⚠️  WARNING:
       This software is designed to monitor employee activity
       while remaining hidden during screen sharing sessions.
       Your activities may be recorded even when sharing your screen.
    */
}
```

### SwiftUI Integration with Evasion Details
```swift
struct ClueLyStatusView: View {
    @State private var detection: ClueLyDetection?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Employee Monitoring Status")
                .font(.title2)
                .fontWeight(.bold)
            
            if let detection = detection {
                if detection.isDetected {
                    VStack(spacing: 15) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 50))
                        
                        Text("Cluely Detected")
                            .font(.headline)
                            .foregroundColor(.red)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Severity: \(detection.severityLevel)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(detection.windowCount) monitoring windows")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if !detection.evasionTechniques.isEmpty {
                                Text("Techniques: \(detection.evasionTechniques.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Button("View Detailed Report") {
                            // Show full report
                        }
                    }
                } else {
                    VStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 50))
                        
                        Text("No Monitoring Detected")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .onAppear {
            detection = ClueLyDetector.detectClueLyDetailed()
        }
    }
}
```

## Library Details

### What It Detects

- **Cluely processes and windows**
- **Screen capture evasion** (`sharing_state = 0`)
- **Elevated layer positioning** (`layer > 0`)
- **Coordinated window manipulation patterns**

### What The Report Contains

- Summary of detected windows and techniques
- Detailed analysis of each Cluely window
- Specific evasion techniques being used
- Security implications and warnings

### Performance

- **Detection time**: < 50ms typical
- **Memory usage**: < 1MB
- **CPU impact**: Negligible
- **Thread safety**: Yes, call from any thread

## Building from Source

```bash
# Clone the repository
git clone <repo-url>
cd no-cluely-driver

# Build and prepare integration files
./install.sh

# The library will be ready in: swift-integration/
```

## Example Detection Output

When Cluely is detected, you'll see output like:

```
🚨 CLUELY EMPLOYEE MONITORING DETECTED
=====================================

📊 Summary:
   • Total Cluely windows: 2
   • Screen capture evasion: 2
   • Elevated layer usage: 1  
   • Highest layer detected: 3

🔍 Evasion Techniques Detected:
   ⚠️  2 window(s) configured to avoid screen capture
   ⚠️  1 window(s) using elevated display layers

⚠️  WARNING:
   This software is designed to monitor employee activity
   while remaining hidden during screen sharing sessions.
   Your activities may be recorded even when sharing your screen.
```

## Requirements

- **macOS**: 10.15+ (Catalina or later)
- **Swift**: 5.0+
- **Xcode**: 12.0+
- **Permissions**: May require accessibility permissions for full detection

## License

MIT License - See LICENSE file for details.

## Contributing

Pull requests welcome! Please ensure:
- Code is well-documented
- Tests pass
- Follows Swift style guidelines

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review the example code
3. Open an issue on GitHub 