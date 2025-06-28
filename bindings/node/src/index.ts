import * as koffi from 'koffi';
import * as path from 'path';
import * as os from 'os';

// Ensure we're on macOS
if (os.platform() !== 'darwin') {
    throw new Error('Cluely Detector is only supported on macOS');
}

// Define the C struct type for detection results
const ClueLyDetectionResultStruct = koffi.struct('ClueLyDetectionResult', {
    is_detected: 'bool',
    window_count: 'uint32',
    screen_capture_evasion_count: 'uint32',
    elevated_layer_count: 'uint32',
    max_layer_detected: 'int32',
});

// Locate the dynamic library
const libraryPath = path.join(__dirname, '..', '..', '..', 'target', 'release', 'libno_cluely_driver.dylib');

// Load the library
const lib = koffi.load(libraryPath);

// Define the FFI functions
const nativeIsClueLyRunning = lib.func('is_cluely_running', 'int', []);
const nativeDetectClueLy = lib.func('detect_cluely', ClueLyDetectionResultStruct, []);
const nativeGetClueLyReport = lib.func('get_cluely_report', 'str', []);
const nativeFreeClueLyReport = lib.func('free_cluely_report', 'void', ['str']);
const nativeGetClueLyWindowCount = lib.func('get_cluely_window_count', 'uint32', []);

/**
 * Detailed information about Cluely detection
 */
export interface ClueLyDetection {
    /** True if Cluely monitoring software is detected */
    readonly isDetected: boolean;

    /** Total number of Cluely windows found */
    readonly windowCount: number;

    /** Number of windows using screen capture evasion */
    readonly screenCaptureEvasionCount: number;

    /** Number of windows using elevated layer positioning */
    readonly elevatedLayerCount: number;

    /** Highest layer number detected */
    readonly maxLayerDetected: number;

    /** Human-readable severity level */
    readonly severityLevel: 'None' | 'Low' | 'Medium' | 'High';

    /** Array of detected evasion techniques */
    readonly evasionTechniques: string[];

    /** Detailed text report */
    readonly report: string;

    /** Timestamp of detection */
    readonly timestamp: Date;
}

/**
 * Cluely Detection Library
 * 
 * Detects Cluely employee monitoring software and its specific evasion techniques.
 * Works in Node.js, Electron, and TypeScript applications.
 */
export class ClueLyDetector {
    /**
     * Simple check if Cluely monitoring software is running
     * 
     * @returns true if Cluely is detected, false otherwise
     * 
     * @example
     * ```typescript
     * if (ClueLyDetector.isClueLyRunning()) {
     *   console.log('⚠️ Employee monitoring detected!');
     * }
     * ```
     */
    public static isClueLyRunning(): boolean {
        return nativeIsClueLyRunning() !== 0;
    }

    /**
     * Basic detection with window count
     * 
     * @returns Object with detection status and window count
     * 
     * @example
     * ```typescript
     * const { isDetected, windowCount } = ClueLyDetector.detectClueLy();
     * console.log(`Detected: ${isDetected}, Windows: ${windowCount}`);
     * ```
     */
    public static detectClueLy(): { isDetected: boolean; windowCount: number } {
        const result = nativeDetectClueLy();
        return {
            isDetected: result.is_detected,
            windowCount: result.window_count,
        };
    }

    /**
     * Detailed detection with evasion technique analysis
     * 
     * @returns Comprehensive detection information including evasion techniques
     * 
     * @example
     * ```typescript
     * const detection = ClueLyDetector.detectClueLyDetailed();
     * if (detection.isDetected) {
     *   console.log(`Severity: ${detection.severityLevel}`);
     *   console.log(`Techniques: ${detection.evasionTechniques.join(', ')}`);
     * }
     * ```
     */
    public static detectClueLyDetailed(): ClueLyDetection {
        const result = nativeDetectClueLy();
        const report = nativeGetClueLyReport();

        // Calculate severity level
        let techniqueCount = 0;
        if (result.screen_capture_evasion_count > 0) techniqueCount++;
        if (result.elevated_layer_count > 0) techniqueCount++;

        let severityLevel: 'None' | 'Low' | 'Medium' | 'High' = 'None';
        if (result.is_detected) {
            switch (techniqueCount) {
                case 0: severityLevel = 'Low'; break;
                case 1: severityLevel = 'Medium'; break;
                default: severityLevel = 'High'; break;
            }
        }

        // Build evasion techniques array
        const evasionTechniques: string[] = [];
        if (result.screen_capture_evasion_count > 0) {
            evasionTechniques.push(`Screen capture evasion (${result.screen_capture_evasion_count} windows)`);
        }
        if (result.elevated_layer_count > 0) {
            evasionTechniques.push(`Elevated layer positioning (${result.elevated_layer_count} windows)`);
        }

        return {
            isDetected: result.is_detected,
            windowCount: result.window_count,
            screenCaptureEvasionCount: result.screen_capture_evasion_count,
            elevatedLayerCount: result.elevated_layer_count,
            maxLayerDetected: result.max_layer_detected,
            severityLevel,
            evasionTechniques,
            report: report || 'No detailed report available',
            timestamp: new Date(),
        };
    }

    /**
     * Get detailed text report of detection results
     * 
     * @returns Detailed text report explaining what was found
     * 
     * @example
     * ```typescript
     * const report = ClueLyDetector.getClueLyReport();
     * console.log(report);
     * ```
     */
    public static getClueLyReport(): string {
        const report = nativeGetClueLyReport();
        return report || 'No report available';
    }

    /**
     * Get the number of Cluely windows detected
     * 
     * @returns Number of Cluely windows
     * 
     * @example
     * ```typescript
     * const count = ClueLyDetector.getClueLyWindowCount();
     * console.log(`Found ${count} Cluely windows`);
     * ```
     */
    public static getClueLyWindowCount(): number {
        return nativeGetClueLyWindowCount();
    }
}

/**
 * Monitor for Cluely detection changes
 */
export class ClueLyMonitor {
    private interval: NodeJS.Timeout | null = null;
    private lastDetection: ClueLyDetection | null = null;
    private callbacks: {
        onDetected?: (detection: ClueLyDetection) => void;
        onRemoved?: () => void;
        onChange?: (detection: ClueLyDetection) => void;
    } = {};

    /**
     * Start monitoring for Cluely detection changes
     * 
     * @param intervalMs Check interval in milliseconds (default: 10000)
     * @param callbacks Event callbacks
     * 
     * @example
     * ```typescript
     * const monitor = new ClueLyMonitor();
     * monitor.start(5000, {
     *   onDetected: (detection) => console.log('Cluely detected!', detection),
     *   onRemoved: () => console.log('Cluely removed'),
     * });
     * ```
     */
    public start(
        intervalMs: number = 10000,
        callbacks: {
            onDetected?: (detection: ClueLyDetection) => void;
            onRemoved?: () => void;
            onChange?: (detection: ClueLyDetection) => void;
        } = {}
    ): void {
        this.callbacks = callbacks;

        this.interval = setInterval(() => {
            const detection = ClueLyDetector.detectClueLyDetailed();

            // Check for state changes
            if (this.lastDetection) {
                if (detection.isDetected && !this.lastDetection.isDetected) {
                    this.callbacks.onDetected?.(detection);
                } else if (!detection.isDetected && this.lastDetection.isDetected) {
                    this.callbacks.onRemoved?.();
                }
            } else if (detection.isDetected) {
                this.callbacks.onDetected?.(detection);
            }

            this.callbacks.onChange?.(detection);
            this.lastDetection = detection;
        }, intervalMs);
    }

    /**
     * Stop monitoring
     */
    public stop(): void {
        if (this.interval) {
            clearInterval(this.interval);
            this.interval = null;
        }
    }

    /**
     * Get the last detection result
     */
    public getLastDetection(): ClueLyDetection | null {
        return this.lastDetection;
    }
}

// Export convenience functions for ES modules
export const isClueLyRunning = ClueLyDetector.isClueLyRunning;
export const detectClueLy = ClueLyDetector.detectClueLy;
export const detectClueLyDetailed = ClueLyDetector.detectClueLyDetailed;
export const getClueLyReport = ClueLyDetector.getClueLyReport;
export const getClueLyWindowCount = ClueLyDetector.getClueLyWindowCount;

// Default export for CommonJS
export default ClueLyDetector; 