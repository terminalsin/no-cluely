package com.nocluely;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;
import org.jetbrains.annotations.NotNull;

import java.time.Instant;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

/**
 * Detailed information about Cluely detection results.
 * 
 * This immutable class contains comprehensive information about detected
 * Cluely employee monitoring software and its evasion techniques.
 * 
 * @since 1.0.0
 */
public final class ClueLyDetection {

    /** True if Cluely monitoring software is detected */
    @JsonProperty("isDetected")
    private final boolean isDetected;

    /** Total number of Cluely windows found */
    @JsonProperty("windowCount")
    private final int windowCount;

    /** Number of windows using screen capture evasion */
    @JsonProperty("screenCaptureEvasionCount")
    private final int screenCaptureEvasionCount;

    /** Number of windows using elevated layer positioning */
    @JsonProperty("elevatedLayerCount")
    private final int elevatedLayerCount;

    /** Highest layer number detected */
    @JsonProperty("maxLayerDetected")
    private final int maxLayerDetected;

    /** Human-readable severity level */
    @JsonProperty("severityLevel")
    private final @NotNull SeverityLevel severityLevel;

    /** List of detected evasion techniques */
    @JsonProperty("evasionTechniques")
    private final @NotNull List<String> evasionTechniques;

    /** Detailed text report */
    @JsonProperty("report")
    private final @NotNull String report;

    /** Detection timestamp */
    @JsonProperty("timestamp")
    private final @NotNull Instant timestamp;

    /**
     * Severity levels for Cluely detection.
     */
    public enum SeverityLevel {
        /** No detection */
        NONE,
        /** Low severity - basic detection */
        LOW,
        /** Medium severity - some evasion techniques */
        MEDIUM,
        /** High severity - multiple evasion techniques */
        HIGH
    }

    /**
     * Creates a new ClueLyDetection instance.
     * 
     * @param isDetected                True if Cluely is detected
     * @param windowCount               Total number of Cluely windows
     * @param screenCaptureEvasionCount Number of windows using screen capture
     *                                  evasion
     * @param elevatedLayerCount        Number of windows using elevated layer
     *                                  positioning
     * @param maxLayerDetected          Highest layer number detected
     * @param severityLevel             Severity level of the detection
     * @param evasionTechniques         List of detected evasion techniques
     * @param report                    Detailed text report
     * @param timestamp                 Detection timestamp
     */
    @JsonCreator
    public ClueLyDetection(
            @JsonProperty("isDetected") boolean isDetected,
            @JsonProperty("windowCount") int windowCount,
            @JsonProperty("screenCaptureEvasionCount") int screenCaptureEvasionCount,
            @JsonProperty("elevatedLayerCount") int elevatedLayerCount,
            @JsonProperty("maxLayerDetected") int maxLayerDetected,
            @JsonProperty("severityLevel") @NotNull SeverityLevel severityLevel,
            @JsonProperty("evasionTechniques") @NotNull List<String> evasionTechniques,
            @JsonProperty("report") @NotNull String report,
            @JsonProperty("timestamp") @NotNull Instant timestamp) {

        this.isDetected = isDetected;
        this.windowCount = windowCount;
        this.screenCaptureEvasionCount = screenCaptureEvasionCount;
        this.elevatedLayerCount = elevatedLayerCount;
        this.maxLayerDetected = maxLayerDetected;
        this.severityLevel = Objects.requireNonNull(severityLevel, "severityLevel cannot be null");
        this.evasionTechniques = Collections.unmodifiableList(
                Objects.requireNonNull(evasionTechniques, "evasionTechniques cannot be null"));
        this.report = Objects.requireNonNull(report, "report cannot be null");
        this.timestamp = Objects.requireNonNull(timestamp, "timestamp cannot be null");
    }

    /**
     * @return True if Cluely monitoring software is detected
     */
    public boolean isDetected() {
        return isDetected;
    }

    /**
     * @return Total number of Cluely windows found
     */
    public int getWindowCount() {
        return windowCount;
    }

    /**
     * @return Number of windows using screen capture evasion
     */
    public int getScreenCaptureEvasionCount() {
        return screenCaptureEvasionCount;
    }

    /**
     * @return Number of windows using elevated layer positioning
     */
    public int getElevatedLayerCount() {
        return elevatedLayerCount;
    }

    /**
     * @return Highest layer number detected
     */
    public int getMaxLayerDetected() {
        return maxLayerDetected;
    }

    /**
     * @return Human-readable severity level
     */
    public @NotNull SeverityLevel getSeverityLevel() {
        return severityLevel;
    }

    /**
     * @return Immutable list of detected evasion techniques
     */
    public @NotNull List<String> getEvasionTechniques() {
        return evasionTechniques;
    }

    /**
     * @return Detailed text report
     */
    public @NotNull String getReport() {
        return report;
    }

    /**
     * @return Detection timestamp
     */
    public @NotNull Instant getTimestamp() {
        return timestamp;
    }

    /**
     * Checks if any evasion techniques were detected.
     * 
     * @return True if evasion techniques are present
     */
    public boolean hasEvasionTechniques() {
        return !evasionTechniques.isEmpty();
    }

    /**
     * Gets a summary string of the detection.
     * 
     * @return Summary string
     */
    public @NotNull String getSummary() {
        if (!isDetected) {
            return "No Cluely monitoring detected";
        }

        StringBuilder summary = new StringBuilder();
        summary.append("Cluely detected (").append(severityLevel).append(" severity)");

        if (windowCount > 0) {
            summary.append(" - ").append(windowCount).append(" window(s)");
        }

        if (hasEvasionTechniques()) {
            summary.append(" using ").append(evasionTechniques.size()).append(" evasion technique(s)");
        }

        return summary.toString();
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null || getClass() != obj.getClass())
            return false;

        ClueLyDetection that = (ClueLyDetection) obj;
        return isDetected == that.isDetected &&
                windowCount == that.windowCount &&
                screenCaptureEvasionCount == that.screenCaptureEvasionCount &&
                elevatedLayerCount == that.elevatedLayerCount &&
                maxLayerDetected == that.maxLayerDetected &&
                severityLevel == that.severityLevel &&
                Objects.equals(evasionTechniques, that.evasionTechniques) &&
                Objects.equals(report, that.report) &&
                Objects.equals(timestamp, that.timestamp);
    }

    @Override
    public int hashCode() {
        return Objects.hash(isDetected, windowCount, screenCaptureEvasionCount,
                elevatedLayerCount, maxLayerDetected, severityLevel,
                evasionTechniques, report, timestamp);
    }

    @Override
    public @NotNull String toString() {
        return "ClueLyDetection{" +
                "isDetected=" + isDetected +
                ", windowCount=" + windowCount +
                ", screenCaptureEvasionCount=" + screenCaptureEvasionCount +
                ", elevatedLayerCount=" + elevatedLayerCount +
                ", maxLayerDetected=" + maxLayerDetected +
                ", severityLevel=" + severityLevel +
                ", evasionTechniques=" + evasionTechniques +
                ", timestamp=" + timestamp +
                '}';
    }
}