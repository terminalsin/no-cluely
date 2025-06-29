package io.github.terminalsin.nocluely;

import org.jetbrains.annotations.NotNull;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

/**
 * Cluely Detection Library for Java
 * 
 * Detects Cluely employee monitoring software and its specific evasion
 * techniques.
 * This class provides a Java interface to a high-performance Rust-based
 * detection engine.
 * 
 * <p>
 * All methods are thread-safe and can be called from any thread.
 * </p>
 * 
 * <p>
 * <strong>Platform Support:</strong> macOS only (Cluely is macOS-specific)
 * </p>
 * 
 * <h3>Basic Usage:</h3>
 * 
 * <pre>{@code
 * // Simple check
 * if (ClueLyDetector.isClueLyRunning()) {
 *     System.out.println("⚠️ Employee monitoring detected!");
 * }
 * 
 * // Detailed analysis
 * ClueLyDetection detection = ClueLyDetector.detectClueLyDetailed();
 * System.out.println("Severity: " + detection.getSeverityLevel());
 * System.out.println("Techniques: " + detection.getEvasionTechniques());
 * }</pre>
 * 
 * @since 1.0.0
 */
public final class CluelyDetector {

    private static final String LIBRARY_NAME = "no_cluely_driver";
    private static final String LIBRARY_FILE = "libno_cluely_driver.dylib";

    private static boolean libraryLoaded = false;
    private static Exception loadException = null;

    // JNI Structure for detection results
    private static class RawDetectionResult {
        boolean isDetected;
        int windowCount;
        int screenCaptureEvasionCount;
        int elevatedLayerCount;
        int maxLayerDetected;
    }

    static {
        loadNativeLibrary();
    }

    /**
     * Load the native library from resources or system path.
     */
    private static void loadNativeLibrary() {
        try {
            // Check if we're on macOS
            String osName = System.getProperty("os.name").toLowerCase();
            if (!osName.contains("mac")) {
                throw new UnsupportedOperationException("Cluely Detector is only supported on macOS");
            }

            // Try loading from system path first
            try {
                System.loadLibrary(LIBRARY_NAME);
                libraryLoaded = true;
                return;
            } catch (UnsatisfiedLinkError e) {
                // Fall back to loading from resources
            }

            // Extract and load from resources
            loadLibraryFromResources();
            libraryLoaded = true;

        } catch (Exception e) {
            loadException = e;
            libraryLoaded = false;
        }
    }

    /**
     * Extract the native library from JAR resources and load it.
     */
    private static void loadLibraryFromResources() throws IOException {
        String resourcePath = "/native/" + LIBRARY_FILE;

        try (InputStream in = CluelyDetector.class.getResourceAsStream(resourcePath)) {
            if (in == null) {
                throw new IOException("Native library not found in resources: " + resourcePath);
            }

            // Create temporary file
            Path tempFile = Files.createTempFile("libno_cluely_driver", ".dylib");
            tempFile.toFile().deleteOnExit();

            // Copy library to temporary file
            Files.copy(in, tempFile, StandardCopyOption.REPLACE_EXISTING);

            // Load the library
            System.load(tempFile.toAbsolutePath().toString());
        }
    }

    /**
     * Ensures the native library is loaded.
     * 
     * @throws RuntimeException if the library could not be loaded
     */
    private static void ensureLibraryLoaded() {
        if (!libraryLoaded) {
            if (loadException != null) {
                throw new RuntimeException("Failed to load native library: " + loadException.getMessage(),
                        loadException);
            } else {
                throw new RuntimeException("Native library is not loaded");
            }
        }
    }

    // Native method declarations
    private static native int nativeIsClueLyRunning();

    private static native RawDetectionResult nativeDetectClueLy();

    private static native String nativeGetClueLyReport();

    private static native int nativeGetClueLyWindowCount();

    /**
     * Simple check if Cluely monitoring software is running.
     * 
     * @return true if Cluely is detected, false otherwise
     * @throws RuntimeException if the native library could not be loaded
     * 
     * @since 1.0.0
     */
    public static boolean isClueLyRunning() {
        ensureLibraryLoaded();
        return nativeIsClueLyRunning() != 0;
    }

    /**
     * Basic detection with window count.
     * 
     * @return DetectionResult with basic information
     * @throws RuntimeException if the native library could not be loaded
     * 
     * @since 1.0.0
     */
    public static @NotNull DetectionResult detectClueLy() {
        ensureLibraryLoaded();
        RawDetectionResult raw = nativeDetectClueLy();
        return new DetectionResult(raw.isDetected, raw.windowCount);
    }

    /**
     * Detailed detection with evasion technique analysis.
     * 
     * @return ClueLyDetection object with comprehensive information
     * @throws RuntimeException if the native library could not be loaded
     * 
     * @since 1.0.0
     */
    public static @NotNull CluelyDetection detectClueLyDetailed() {
        ensureLibraryLoaded();

        RawDetectionResult raw = nativeDetectClueLy();
        String report = nativeGetClueLyReport();

        // Calculate severity level
        int techniqueCount = 0;
        if (raw.screenCaptureEvasionCount > 0)
            techniqueCount++;
        if (raw.elevatedLayerCount > 0)
            techniqueCount++;

        CluelyDetection.SeverityLevel severityLevel;
        if (!raw.isDetected) {
            severityLevel = CluelyDetection.SeverityLevel.NONE;
        } else {
            switch (techniqueCount) {
                case 0:
                    severityLevel = CluelyDetection.SeverityLevel.LOW;
                    break;
                case 1:
                    severityLevel = CluelyDetection.SeverityLevel.MEDIUM;
                    break;
                default:
                    severityLevel = CluelyDetection.SeverityLevel.HIGH;
                    break;
            }
        }

        // Build evasion techniques list
        List<String> evasionTechniques = new ArrayList<>();
        if (raw.screenCaptureEvasionCount > 0) {
            evasionTechniques.add("Screen capture evasion (" + raw.screenCaptureEvasionCount + " windows)");
        }
        if (raw.elevatedLayerCount > 0) {
            evasionTechniques.add("Elevated layer positioning (" + raw.elevatedLayerCount + " windows)");
        }

        return new CluelyDetection(
                raw.isDetected,
                raw.windowCount,
                raw.screenCaptureEvasionCount,
                raw.elevatedLayerCount,
                raw.maxLayerDetected,
                severityLevel,
                evasionTechniques,
                report != null ? report : "No detailed report available",
                Instant.now());
    }

    /**
     * Get detailed text report of detection results.
     * 
     * @return Detailed text report explaining what was found
     * @throws RuntimeException if the native library could not be loaded
     * 
     * @since 1.0.0
     */
    public static @NotNull String getClueLyReport() {
        ensureLibraryLoaded();
        String report = nativeGetClueLyReport();
        return report != null ? report : "No report available";
    }

    /**
     * Get the number of Cluely windows detected.
     * 
     * @return Number of Cluely windows
     * @throws RuntimeException if the native library could not be loaded
     * 
     * @since 1.0.0
     */
    public static int getClueLyWindowCount() {
        ensureLibraryLoaded();
        return nativeGetClueLyWindowCount();
    }

    /**
     * Checks if the native library is loaded and available.
     * 
     * @return true if the library is loaded and ready to use
     * 
     * @since 1.0.0
     */
    public static boolean isLibraryLoaded() {
        return libraryLoaded;
    }

    /**
     * Gets the exception that occurred during library loading, if any.
     * 
     * @return Exception that occurred during loading, or null if none
     * 
     * @since 1.0.0
     */
    public static Exception getLoadException() {
        return loadException;
    }

    /**
     * Simple detection result containing basic information.
     */
    public static final class DetectionResult {
        private final boolean detected;
        private final int windowCount;

        DetectionResult(boolean detected, int windowCount) {
            this.detected = detected;
            this.windowCount = windowCount;
        }

        /**
         * @return true if Cluely is detected
         */
        public boolean isDetected() {
            return detected;
        }

        /**
         * @return number of Cluely windows
         */
        public int getWindowCount() {
            return windowCount;
        }

        @Override
        public String toString() {
            return "DetectionResult{detected=" + detected + ", windowCount=" + windowCount + '}';
        }
    }

    // Private constructor to prevent instantiation
    private CluelyDetector() {
        throw new UnsupportedOperationException("This is a utility class and cannot be instantiated");
    }
}