import Foundation
import CNoClueLyDriver

/// Detailed information about Cluely detection results
public struct ClueLyDetection {
    /// True if Cluely monitoring software is detected
    public let isDetected: Bool
    
    /// Total number of Cluely windows found
    public let windowCount: UInt32
    
    /// Number of windows using screen capture evasion (sharing_state = 0)
    public let screenCaptureEvasionCount: UInt32
    
    /// Number of windows using elevated layer positioning (layer > 0)
    public let elevatedLayerCount: UInt32
    
    /// Highest layer number detected
    public let maxLayerDetected: Int32
    
    /// Human-readable severity level
    public let severityLevel: SeverityLevel
    
    /// Array of detected evasion techniques
    public let evasionTechniques: [String]
    
    /// Detailed text report
    public let report: String
    
    /// Detection timestamp
    public let timestamp: Date
    
    /// Severity levels for Cluely detection
    public enum SeverityLevel: String, CaseIterable, Codable {
        case none = "None"
        case low = "Low"
        case medium = "Medium"
        case high = "High"
    }
    
    /// Gets a human-readable summary of the detection
    public var summary: String {
        if !isDetected {
            return "No Cluely monitoring detected"
        }
        
        var components = ["Cluely detected (\(severityLevel.rawValue) severity)"]
        
        if windowCount > 0 {
            components.append("\(windowCount) window(s)")
        }
        
        if !evasionTechniques.isEmpty {
            components.append("using \(evasionTechniques.count) evasion technique(s)")
        }
        
        return components.joined(separator: " - ")
    }
    
    /// True if any evasion techniques were detected
    public var hasEvasionTechniques: Bool {
        return !evasionTechniques.isEmpty
    }
}

/// Main class for detecting Cluely employee monitoring software
public class ClueLyDetector {
    
    /// Simple check if Cluely monitoring software is running
    /// - Returns: true if Cluely is detected, false otherwise
    public static func isClueLyRunning() -> Bool {
        return is_cluely_running() != 0
    }
    
    /// Basic detection with window count
    /// - Returns: Tuple of (isDetected, windowCount)
    public static func detectClueLy() -> (isDetected: Bool, windowCount: UInt32) {
        let result = detect_cluely()
        return (result.is_detected, result.window_count)
    }
    
    /// Detailed detection with comprehensive evasion technique analysis
    /// - Returns: ClueLyDetection object with full analysis
    public static func detectClueLyDetailed() -> ClueLyDetection {
        let result = detect_cluely()
        let reportPtr = get_cluely_report()
        
        // Convert C string to Swift String
        let report: String
        if let ptr = reportPtr {
            report = String(cString: ptr)
            free_cluely_report(ptr)
        } else {
            report = "No detailed report available"
        }
        
        // Calculate severity level
        let techniqueCount = (result.screen_capture_evasion_count > 0 ? 1 : 0) +
                           (result.elevated_layer_count > 0 ? 1 : 0)
        
        let severityLevel: ClueLyDetection.SeverityLevel
        if !result.is_detected {
            severityLevel = .none
        } else {
            switch techniqueCount {
            case 0:
                severityLevel = .low
            case 1:
                severityLevel = .medium
            default:
                severityLevel = .high
            }
        }
        
        // Build evasion techniques array
        var evasionTechniques: [String] = []
        if result.screen_capture_evasion_count > 0 {
            evasionTechniques.append("Screen capture evasion (\(result.screen_capture_evasion_count) windows)")
        }
        if result.elevated_layer_count > 0 {
            evasionTechniques.append("Elevated layer positioning (\(result.elevated_layer_count) windows)")
        }
        
        return ClueLyDetection(
            isDetected: result.is_detected,
            windowCount: result.window_count,
            screenCaptureEvasionCount: result.screen_capture_evasion_count,
            elevatedLayerCount: result.elevated_layer_count,
            maxLayerDetected: result.max_layer_detected,
            severityLevel: severityLevel,
            evasionTechniques: evasionTechniques,
            report: report,
            timestamp: Date()
        )
    }
    
    /// Get detailed text report of detection results
    /// - Returns: Detailed text report explaining what was found
    public static func getClueLyReport() -> String {
        guard let reportPtr = get_cluely_report() else {
            return "No report available"
        }
        
        let report = String(cString: reportPtr)
        free_cluely_report(reportPtr)
        return report
    }
    
    /// Get the number of Cluely windows detected
    /// - Returns: Number of Cluely windows
    public static func getClueLyWindowCount() -> UInt32 {
        return get_cluely_window_count()
    }
}

/// Monitor for Cluely detection changes with delegate callbacks
public class ClueLyMonitor {
    
    /// Delegate protocol for monitoring events
    public protocol Delegate: AnyObject {
        /// Called when Cluely is first detected
        func clueLyMonitor(_ monitor: ClueLyMonitor, didDetect detection: ClueLyDetection)
        
        /// Called when Cluely monitoring stops
        func clueLyMonitorDidRemoveDetection(_ monitor: ClueLyMonitor)
        
        /// Called on every detection check (optional)
        func clueLyMonitor(_ monitor: ClueLyMonitor, didUpdate detection: ClueLyDetection)
    }
    
    public weak var delegate: Delegate?
    
    private var timer: Timer?
    private var lastDetection: ClueLyDetection?
    
    /// Start monitoring for Cluely detection changes
    /// - Parameters:
    ///   - interval: Check interval in seconds (default: 10.0)
    ///   - delegate: Delegate to receive callbacks
    public func startMonitoring(interval: TimeInterval = 10.0, delegate: Delegate? = nil) {
        stopMonitoring() // Stop any existing monitoring
        
        self.delegate = delegate ?? self.delegate
        
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkDetection()
        }
        
        // Perform initial check
        checkDetection()
    }
    
    /// Stop monitoring
    public func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Get the last detection result
    public var lastDetectionResult: ClueLyDetection? {
        return lastDetection
    }
    
    /// Check if monitoring is currently active
    public var isMonitoring: Bool {
        return timer?.isValid ?? false
    }
    
    private func checkDetection() {
        let detection = ClueLyDetector.detectClueLyDetailed()
        
        // Check for state changes
        if let last = lastDetection {
            if detection.isDetected && !last.isDetected {
                delegate?.clueLyMonitor(self, didDetect: detection)
            } else if !detection.isDetected && last.isDetected {
                delegate?.clueLyMonitorDidRemoveDetection(self)
            }
        } else if detection.isDetected {
            delegate?.clueLyMonitor(self, didDetect: detection)
        }
        
        // Always call update
        delegate?.clueLyMonitor(self, didUpdate: detection)
        
        lastDetection = detection
    }
    
    deinit {
        stopMonitoring()
    }
}

// MARK: - SwiftUI Integration

#if canImport(SwiftUI)
import SwiftUI
import Combine

/// SwiftUI ObservableObject for reactive detection monitoring
@available(macOS 11.0, *)
public class ClueLyDetectionMonitor: ObservableObject {
    
    @Published public private(set) var detection: ClueLyDetection?
    @Published public private(set) var isMonitoring = false
    
    private var monitor = ClueLyMonitor()
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        monitor.delegate = self
    }
    
    /// Start monitoring with SwiftUI reactivity
    public func startMonitoring(interval: TimeInterval = 10.0) {
        monitor.startMonitoring(interval: interval)
        isMonitoring = true
    }
    
    /// Stop monitoring
    public func stopMonitoring() {
        monitor.stopMonitoring()
        isMonitoring = false
    }
    
    /// Perform a single detection check
    public func checkOnce() {
        detection = ClueLyDetector.detectClueLyDetailed()
    }
}

@available(macOS 11.0, *)
extension ClueLyDetectionMonitor: ClueLyMonitor.Delegate {
    public func clueLyMonitor(_ monitor: ClueLyMonitor, didDetect detection: ClueLyDetection) {
        DispatchQueue.main.async {
            self.detection = detection
        }
    }
    
    public func clueLyMonitorDidRemoveDetection(_ monitor: ClueLyMonitor) {
        DispatchQueue.main.async {
            self.detection = nil
        }
    }
    
    public func clueLyMonitor(_ monitor: ClueLyMonitor, didUpdate detection: ClueLyDetection) {
        DispatchQueue.main.async {
            self.detection = detection
        }
    }
}

/// SwiftUI View for displaying detection status
@available(macOS 11.0, *)
public struct ClueLyDetectionView: View {
    @StateObject private var monitor = ClueLyDetectionMonitor()
    
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🎯 Cluely Detection")
                    .font(.headline)
                Spacer()
                
                Button(monitor.isMonitoring ? "Stop" : "Start") {
                    if monitor.isMonitoring {
                        monitor.stopMonitoring()
                    } else {
                        monitor.startMonitoring()
                    }
                }
            }
            
            if let detection = monitor.detection {
                if detection.isDetected {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("🚨 DETECTED")
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                            Spacer()
                            Text(detection.severityLevel.rawValue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(severityColor(detection.severityLevel))
                                .foregroundColor(.white)
                                .cornerRadius(4)
                        }
                        
                        Text("Windows: \(detection.windowCount)")
                        
                        if !detection.evasionTechniques.isEmpty {
                            Text("Evasion Techniques:")
                                .fontWeight(.medium)
                            
                            ForEach(detection.evasionTechniques, id: \.self) { technique in
                                Text("• \(technique)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                } else {
                    HStack {
                        Text("✅ NOT DETECTED")
                            .foregroundColor(.green)
                            .fontWeight(.bold)
                        Spacer()
                        Text("System Clean")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                }
            } else {
                Button("Check Now") {
                    monitor.checkOnce()
                }
            }
        }
        .padding()
        .onAppear {
            monitor.checkOnce()
        }
    }
    
    private func severityColor(_ severity: ClueLyDetection.SeverityLevel) -> Color {
        switch severity {
        case .none:
            return .green
        case .low:
            return .yellow
        case .medium:
            return .orange
        case .high:
            return .red
        }
    }
}
#endif

// MARK: - Convenience Extensions

extension ClueLyDetection: Codable {
    enum CodingKeys: String, CodingKey {
        case isDetected, windowCount, screenCaptureEvasionCount
        case elevatedLayerCount, maxLayerDetected, severityLevel
        case evasionTechniques, report, timestamp
    }
} 