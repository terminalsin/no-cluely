import Foundation

// MARK: - C Library Interface

// Simple boolean check
@_silgen_name("is_cluely_running")
func is_cluely_running() -> Int32

// Detailed detection with evasion analysis
@_silgen_name("detect_cluely")
func detect_cluely() -> ClueLyDetectionResult

// Get window count only
@_silgen_name("get_cluely_window_count")
func get_cluely_window_count() -> UInt32

// Get detailed text report
@_silgen_name("get_cluely_report")
func get_cluely_report() -> UnsafeMutablePointer<CChar>?

// Free report memory
@_silgen_name("free_cluely_report")
func free_cluely_report(_ report: UnsafeMutablePointer<CChar>?)

// Detection result structure (must match C struct)
struct ClueLyDetectionResult {
    let is_detected: Bool
    let window_count: UInt32
    let screen_capture_evasion_count: UInt32
    let elevated_layer_count: UInt32
    let max_layer_detected: Int32
}

// MARK: - Swift Data Structures

/// Detailed information about Cluely detection
public struct ClueLyDetection {
    public let isDetected: Bool
    public let windowCount: UInt32
    public let screenCaptureEvasionCount: UInt32
    public let elevatedLayerCount: UInt32
    public let maxLayerDetected: Int32
    public let report: String
    
    /// Summary of detected evasion techniques
    public var evasionTechniques: [String] {
        var techniques: [String] = []
        if screenCaptureEvasionCount > 0 {
            techniques.append("Screen capture evasion (\(screenCaptureEvasionCount) windows)")
        }
        if elevatedLayerCount > 0 {
            techniques.append("Elevated layer positioning (\(elevatedLayerCount) windows)")
        }
        return techniques
    }
    
    /// Human-readable severity level
    public var severityLevel: String {
        if !isDetected { return "None" }
        
        let techniqueCount = (screenCaptureEvasionCount > 0 ? 1 : 0) + (elevatedLayerCount > 0 ? 1 : 0)
        switch techniqueCount {
        case 0: return "Low"
        case 1: return "Medium"
        default: return "High"
        }
    }
}

// MARK: - Swift Wrapper Class

public class ClueLyDetector {
    
    /// Simplest check - just returns true/false
    public static func isClueLyRunning() -> Bool {
        return is_cluely_running() != 0
    }
    
    /// Basic detection with window count
    public static func detectClueLy() -> (isDetected: Bool, windowCount: UInt32) {
        let result = detect_cluely()
        return (result.is_detected, result.window_count)
    }
    
    /// Detailed detection with evasion technique analysis
    public static func detectClueLyDetailed() -> ClueLyDetection {
        let result = detect_cluely()
        
        // Get the detailed text report
        let reportPtr = get_cluely_report()
        let reportString: String
        if let ptr = reportPtr {
            reportString = String(cString: ptr)
            free_cluely_report(ptr)
        } else {
            reportString = "Failed to generate report"
        }
        
        return ClueLyDetection(
            isDetected: result.is_detected,
            windowCount: result.window_count,
            screenCaptureEvasionCount: result.screen_capture_evasion_count,
            elevatedLayerCount: result.elevated_layer_count,
            maxLayerDetected: result.max_layer_detected,
            report: reportString
        )
    }
    
    /// Get just the text report
    public static func getClueLyReport() -> String {
        let reportPtr = get_cluely_report()
        defer {
            if let ptr = reportPtr {
                free_cluely_report(ptr)
            }
        }
        
        if let ptr = reportPtr {
            return String(cString: ptr)
        } else {
            return "Failed to generate report"
        }
    }
    
    /// Get number of Cluely windows
    public static func getClueLyWindowCount() -> UInt32 {
        return get_cluely_window_count()
    }
}

// MARK: - Usage Examples

// Example 1: Simple boolean check
func exampleSimpleCheck() {
    if ClueLyDetector.isClueLyRunning() {
        print("⚠️ Cluely is running - employee monitoring detected!")
    } else {
        print("✅ No Cluely detected")
    }
}

// Example 2: Detailed analysis with evasion techniques
func exampleDetailedAnalysis() {
    let detection = ClueLyDetector.detectClueLyDetailed()
    
    if detection.isDetected {
        print("🚨 Cluely Detection Results:")
        print("   Status: DETECTED")
        print("   Windows: \(detection.windowCount)")
        print("   Severity: \(detection.severityLevel)")
        print("   Evasion Techniques: \(detection.evasionTechniques.joined(separator: ", "))")
        
        if detection.screenCaptureEvasionCount > 0 {
            print("   ⚠️ \(detection.screenCaptureEvasionCount) windows avoiding screen capture")
        }
        if detection.elevatedLayerCount > 0 {
            print("   ⚠️ \(detection.elevatedLayerCount) windows using elevated layers (max: \(detection.maxLayerDetected))")
        }
    } else {
        print("✅ No employee monitoring software detected")
    }
}

// Example 3: Full text report
func exampleTextReport() {
    let report = ClueLyDetector.getClueLyReport()
    print(report)
}

// Example 4: Monitoring with detailed alerts
class ClueLyMonitor {
    private var timer: Timer?
    private var lastDetection: ClueLyDetection?
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
            let detection = ClueLyDetector.detectClueLyDetailed()
            
            if detection.isDetected {
                self.handleDetection(detection)
            } else if self.lastDetection?.isDetected == true {
                // Cluely was removed
                self.handleClueLyRemoved()
            }
            
            self.lastDetection = detection
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func handleDetection(_ detection: ClueLyDetection) {
        NotificationCenter.default.post(
            name: Notification.Name("ClueLyDetected"),
            object: detection
        )
        
        // Log the specific evasion techniques
        if !detection.evasionTechniques.isEmpty {
            print("🚨 Cluely evasion techniques: \(detection.evasionTechniques.joined(separator: ", "))")
        }
    }
    
    private func handleClueLyRemoved() {
        NotificationCenter.default.post(
            name: Notification.Name("ClueLyRemoved"),
            object: nil
        )
        print("✅ Cluely monitoring appears to have been removed")
    }
}

// Example 5: SwiftUI Integration with detailed information
import SwiftUI

struct ClueLyStatusView: View {
    @State private var detection: ClueLyDetection?
    @State private var showingReport = false
    
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
                            showingReport = true
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
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
            } else {
                ProgressView("Checking...")
            }
            
            Button("Refresh") {
                checkClueLy()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .onAppear {
            checkClueLy()
        }
        .sheet(isPresented: $showingReport) {
            if let detection = detection {
                ClueLyReportView(report: detection.report)
            }
        }
    }
    
    private func checkClueLy() {
        detection = ClueLyDetector.detectClueLyDetailed()
    }
}

struct ClueLyReportView: View {
    let report: String
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(report)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .navigationTitle("Cluely Detection Report")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
} 