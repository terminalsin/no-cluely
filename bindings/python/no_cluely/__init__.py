"""
No-Cluely Detector - Python Library

Detect Cluely employee monitoring software and its evasion techniques.
This library provides Python bindings to a fast Rust-based detection engine.

Basic Usage:
    >>> from no_cluely_detector import ClueLyDetector
    >>> if ClueLyDetector.is_cluely_running():
    ...     print("⚠️ Employee monitoring detected!")

Advanced Usage:
    >>> detection = ClueLyDetector.detect_cluely_detailed()
    >>> print(f"Severity: {detection.severity_level}")
    >>> print(f"Techniques: {', '.join(detection.evasion_techniques)}")
"""

import ctypes
import platform
import os
from pathlib import Path
from typing import List, Optional, NamedTuple, Union
from dataclasses import dataclass
from datetime import datetime
import threading
import time

# Ensure we're on macOS
if platform.system() != "Darwin":
    raise RuntimeError("Cluely Detector is only supported on macOS")


# Locate the dynamic library
def _find_library() -> str:
    """Find the Rust dynamic library."""
    # Try relative to this package first
    current_dir = Path(__file__).parent
    lib_paths = [
        # First try in the package directory (bundled with the package)
        current_dir / "libno_cluely_driver.dylib",
        # Then try in the parent directory (build script puts it here)
        current_dir / ".." / "libno_cluely_driver.dylib",
        # Then try development locations
        current_dir
        / ".."
        / ".."
        / ".."
        / "target"
        / "release"
        / "libno_cluely_driver.dylib",
        current_dir / ".." / ".." / "target" / "release" / "libno_cluely_driver.dylib",
        # Finally try system locations
        Path("/usr/local/lib/libno_cluely_driver.dylib"),
        Path("/opt/homebrew/lib/libno_cluely_driver.dylib"),
    ]

    for lib_path in lib_paths:
        lib_path = lib_path.resolve()
        if lib_path.exists():
            return str(lib_path)

    raise FileNotFoundError(
        "Could not find libno_cluely_driver.dylib. "
        "Please ensure the Rust library is built: cargo build --lib --release"
    )


# Load the library
_lib_path = _find_library()
_lib = ctypes.CDLL(_lib_path)


# Define C structures
class _ClueLyDetectionResult(ctypes.Structure):
    """C structure for detection results."""

    _fields_ = [
        ("is_detected", ctypes.c_bool),
        ("window_count", ctypes.c_uint32),
        ("screen_capture_evasion_count", ctypes.c_uint32),
        ("elevated_layer_count", ctypes.c_uint32),
        ("max_layer_detected", ctypes.c_int32),
    ]


# Define function signatures
_lib.is_cluely_running.argtypes = []
_lib.is_cluely_running.restype = ctypes.c_int

_lib.detect_cluely.argtypes = []
_lib.detect_cluely.restype = _ClueLyDetectionResult

_lib.get_cluely_report.argtypes = []
_lib.get_cluely_report.restype = ctypes.c_char_p

_lib.free_cluely_report.argtypes = [ctypes.c_char_p]
_lib.free_cluely_report.restype = None

_lib.get_cluely_window_count.argtypes = []
_lib.get_cluely_window_count.restype = ctypes.c_uint32


@dataclass(frozen=True)
class CluelyDetection:
    """
    Detailed information about Cluely detection.

    Attributes:
        is_detected: True if Cluely monitoring software is detected
        window_count: Total number of Cluely windows found
        screen_capture_evasion_count: Number of windows using screen capture evasion
        elevated_layer_count: Number of windows using elevated layer positioning
        max_layer_detected: Highest layer number detected
        severity_level: Human-readable severity level ('None', 'Low', 'Medium', 'High')
        evasion_techniques: List of detected evasion techniques
        report: Detailed text report
        timestamp: Detection timestamp
    """

    is_detected: bool
    window_count: int
    screen_capture_evasion_count: int
    elevated_layer_count: int
    max_layer_detected: int
    severity_level: str
    evasion_techniques: List[str]
    report: str
    timestamp: datetime


class NoCluely:
    """
    Cluely Detection Library

    Detects Cluely employee monitoring software and its specific evasion techniques.
    All methods are thread-safe and can be called from any thread.
    """

    @staticmethod
    def is_cluely_running() -> bool:
        """
        Simple check if Cluely monitoring software is running.

        Returns:
            True if Cluely is detected, False otherwise

        Example:
            >>> if ClueLyDetector.is_cluely_running():
            ...     print("⚠️ Employee monitoring detected!")
        """
        return _lib.is_cluely_running() != 0

    @staticmethod
    def detect_cluely() -> tuple[bool, int]:
        """
        Basic detection with window count.

        Returns:
            Tuple of (is_detected, window_count)

        Example:
            >>> is_detected, window_count = ClueLyDetector.detect_cluely()
            >>> print(f"Detected: {is_detected}, Windows: {window_count}")
        """
        result = _lib.detect_cluely()
        return result.is_detected, result.window_count

    @staticmethod
    def detect_cluely_detailed() -> CluelyDetection:
        """
        Detailed detection with evasion technique analysis.

        Returns:
            ClueLyDetection object with comprehensive information

        Example:
            >>> detection = ClueLyDetector.detect_cluely_detailed()
            >>> if detection.is_detected:
            ...     print(f"Severity: {detection.severity_level}")
            ...     print(f"Techniques: {', '.join(detection.evasion_techniques)}")
        """
        result = _lib.detect_cluely()

        # Get the detailed report
        report_ptr = _lib.get_cluely_report()
        try:
            if report_ptr:
                report = report_ptr.decode("utf-8")
            else:
                report = "No detailed report available"
        finally:
            if report_ptr:
                _lib.free_cluely_report(report_ptr)

        # Calculate severity level
        technique_count = 0
        if result.screen_capture_evasion_count > 0:
            technique_count += 1
        if result.elevated_layer_count > 0:
            technique_count += 1

        if not result.is_detected:
            severity_level = "None"
        elif technique_count == 0:
            severity_level = "Low"
        elif technique_count == 1:
            severity_level = "Medium"
        else:
            severity_level = "High"

        # Build evasion techniques list
        evasion_techniques = []
        if result.screen_capture_evasion_count > 0:
            evasion_techniques.append(
                f"Screen capture evasion ({result.screen_capture_evasion_count} windows)"
            )
        if result.elevated_layer_count > 0:
            evasion_techniques.append(
                f"Elevated layer positioning ({result.elevated_layer_count} windows)"
            )

        return CluelyDetection(
            is_detected=result.is_detected,
            window_count=result.window_count,
            screen_capture_evasion_count=result.screen_capture_evasion_count,
            elevated_layer_count=result.elevated_layer_count,
            max_layer_detected=result.max_layer_detected,
            severity_level=severity_level,
            evasion_techniques=evasion_techniques,
            report=report,
            timestamp=datetime.now(),
        )

    @staticmethod
    def get_cluely_report() -> str:
        """
        Get detailed text report of detection results.

        Returns:
            Detailed text report explaining what was found

        Example:
            >>> report = ClueLyDetector.get_cluely_report()
            >>> print(report)
        """
        report_ptr = _lib.get_cluely_report()
        try:
            if report_ptr:
                return report_ptr.decode("utf-8")
            else:
                return "No report available"
        finally:
            if report_ptr:
                _lib.free_cluely_report(report_ptr)

    @staticmethod
    def get_cluely_window_count() -> int:
        """
        Get the number of Cluely windows detected.

        Returns:
            Number of Cluely windows

        Example:
            >>> count = ClueLyDetector.get_cluely_window_count()
            >>> print(f"Found {count} Cluely windows")
        """
        return _lib.get_cluely_window_count()


class ClueLyMonitor:
    """
    Monitor for Cluely detection changes with event callbacks.

    This class provides continuous monitoring with callbacks for detection events.
    It runs in a separate thread to avoid blocking the main application.
    """

    def __init__(self):
        self._running = False
        self._thread: Optional[threading.Thread] = None
        self._last_detection: Optional[CluelyDetection] = None
        self._callbacks = {}

    def start(
        self,
        interval: float = 10.0,
        on_detected: Optional[callable] = None,
        on_removed: Optional[callable] = None,
        on_change: Optional[callable] = None,
    ) -> None:
        """
        Start monitoring for Cluely detection changes.

        Args:
            interval: Check interval in seconds (default: 10.0)
            on_detected: Callback when Cluely is first detected
            on_removed: Callback when Cluely monitoring stops
            on_change: Callback on every detection check

        Example:
            >>> def alert(detection):
            ...     print(f"🚨 Cluely detected! Severity: {detection.severity_level}")
            >>>
            >>> monitor = ClueLyMonitor()
            >>> monitor.start(interval=5.0, on_detected=alert)
        """
        if self._running:
            raise RuntimeError("Monitor is already running")

        self._callbacks = {
            "on_detected": on_detected,
            "on_removed": on_removed,
            "on_change": on_change,
        }

        self._running = True
        self._thread = threading.Thread(target=self._monitor_loop, args=(interval,))
        self._thread.daemon = True
        self._thread.start()

    def stop(self) -> None:
        """
        Stop monitoring.

        Example:
            >>> monitor.stop()
        """
        self._running = False
        if self._thread:
            self._thread.join(timeout=5.0)
            self._thread = None

    def get_last_detection(self) -> Optional[CluelyDetection]:
        """
        Get the last detection result.

        Returns:
            Last ClueLyDetection result or None if no detection has been performed

        Example:
            >>> last = monitor.get_last_detection()
            >>> if last and last.is_detected:
            ...     print("Still detected")
        """
        return self._last_detection

    def _monitor_loop(self, interval: float) -> None:
        """Internal monitoring loop."""
        while self._running:
            try:
                detection = NoCluely.detect_cluely_detailed()

                # Check for state changes
                if self._last_detection:
                    if detection.is_detected and not self._last_detection.is_detected:
                        # Just detected
                        if self._callbacks["on_detected"]:
                            self._callbacks["on_detected"](detection)
                    elif not detection.is_detected and self._last_detection.is_detected:
                        # Just stopped
                        if self._callbacks["on_removed"]:
                            self._callbacks["on_removed"]()
                else:
                    # First check
                    if detection.is_detected and self._callbacks["on_detected"]:
                        self._callbacks["on_detected"](detection)

                # Always call on_change if provided
                if self._callbacks["on_change"]:
                    self._callbacks["on_change"](detection)

                self._last_detection = detection

            except Exception as e:
                # Log error but continue monitoring
                print(f"Monitoring error: {e}")

            if self._running:
                time.sleep(interval)


# Convenience functions for quick access
def is_cluely_running() -> bool:
    """Convenience function: Check if Cluely is running."""
    return NoCluely.is_cluely_running()


def detect_cluely() -> tuple[bool, int]:
    """Convenience function: Basic detection with window count."""
    return NoCluely.detect_cluely()


def detect_cluely_detailed() -> CluelyDetection:
    """Convenience function: Detailed detection with evasion analysis."""
    return NoCluely.detect_cluely_detailed()


def get_cluely_report() -> str:
    """Convenience function: Get detailed text report."""
    return NoCluely.get_cluely_report()


# Export public API
__all__ = [
    "NoCluely",
    "CluelyDetection",
    "CluelyMonitor",
    "is_cluely_running",
    "detect_cluely",
    "detect_cluely_detailed",
    "get_cluely_report",
]

# Version information
__version__ = "1.0.0"
__author__ = "No-Cluely Team"
