# no-cluely-detector 🎯

Python library for detecting Cluely employee monitoring software and its evasion techniques.

## Features

- **Fast Detection**: Built on a high-performance Rust engine
- **Thread-Safe**: Use from any thread in your Python application
- **Type-Safe**: Full type hints support with mypy compatibility
- **Event Monitoring**: Real-time callbacks for detection changes
- **Detailed Analysis**: Comprehensive evasion technique reporting
- **Easy Integration**: Simple API for any Python project

## Installation

```bash
pip install no-cluely-detector
```

### Requirements

- **Python**: 3.8 or later
- **Platform**: macOS only (Cluely is macOS-specific)
- **Architecture**: x64 (Intel/Apple Silicon)

## Quick Start

### Simple Detection
```python
from no_cluely_detector import ClueLyDetector

# Quick check
if ClueLyDetector.is_cluely_running():
    print("⚠️ Employee monitoring detected!")
else:
    print("✅ No monitoring software found")
```

### Detailed Analysis
```python
from no_cluely_detector import ClueLyDetector

detection = ClueLyDetector.detect_cluely_detailed()

if detection.is_detected:
    print(f"🚨 Cluely Detected!")
    print(f"   Severity: {detection.severity_level}")
    print(f"   Windows: {detection.window_count}")
    print(f"   Techniques: {', '.join(detection.evasion_techniques)}")
else:
    print("✅ System clean")
```

### Real-time Monitoring
```python
from no_cluely_detector import ClueLyMonitor

def on_detected(detection):
    print(f"🚨 Monitoring started! Severity: {detection.severity_level}")

def on_removed():
    print("✅ Monitoring stopped")

monitor = ClueLyMonitor()
monitor.start(
    interval=5.0,  # Check every 5 seconds
    on_detected=on_detected,
    on_removed=on_removed
)

# Your application continues...
# Call monitor.stop() when done
```

## API Reference

### ClueLyDetector

Main detection class with static methods for detecting Cluely monitoring software.

#### Methods

##### `ClueLyDetector.is_cluely_running() -> bool`
Simple boolean check for Cluely presence.

```python
detected = ClueLyDetector.is_cluely_running()
```

##### `ClueLyDetector.detect_cluely() -> tuple[bool, int]`
Basic detection returning status and window count.

```python
is_detected, window_count = ClueLyDetector.detect_cluely()
print(f"Detected: {is_detected}, Windows: {window_count}")
```

##### `ClueLyDetector.detect_cluely_detailed() -> ClueLyDetection`
Comprehensive detection with full analysis.

```python
detection = ClueLyDetector.detect_cluely_detailed()
# Returns ClueLyDetection object with all details
```

##### `ClueLyDetector.get_cluely_report() -> str`
Detailed text report of findings.

```python
report = ClueLyDetector.get_cluely_report()
print(report)
```

##### `ClueLyDetector.get_cluely_window_count() -> int`
Number of Cluely windows detected.

```python
count = ClueLyDetector.get_cluely_window_count()
```

### ClueLyDetection

Data class containing detailed detection information.

#### Attributes

- `is_detected: bool` - True if Cluely is detected
- `window_count: int` - Total number of Cluely windows
- `screen_capture_evasion_count: int` - Windows using screen capture evasion
- `elevated_layer_count: int` - Windows using elevated layer positioning
- `max_layer_detected: int` - Highest layer number found
- `severity_level: str` - Severity ('None', 'Low', 'Medium', 'High')
- `evasion_techniques: List[str]` - List of detected techniques
- `report: str` - Detailed text report
- `timestamp: datetime` - Detection timestamp

```python
detection = ClueLyDetector.detect_cluely_detailed()

print(f"Detected: {detection.is_detected}")
print(f"Severity: {detection.severity_level}")
print(f"Evasion Techniques:")
for technique in detection.evasion_techniques:
    print(f"  - {technique}")
```

### ClueLyMonitor

Event-based monitoring for detection changes.

#### Methods

##### `start(interval=10.0, on_detected=None, on_removed=None, on_change=None)`
Start monitoring with event callbacks.

- `interval: float` - Check interval in seconds
- `on_detected: callable` - Called when Cluely is first detected
- `on_removed: callable` - Called when Cluely monitoring stops
- `on_change: callable` - Called on every check

##### `stop()`
Stop monitoring and cleanup resources.

##### `get_last_detection() -> Optional[ClueLyDetection]`
Get the most recent detection result.

```python
monitor = ClueLyMonitor()

def alert(detection):
    send_email(f"Security Alert: {detection.severity_level}")

monitor.start(interval=30.0, on_detected=alert)
```

## Usage Examples

### Flask Web Application
```python
from flask import Flask, jsonify
from no_cluely_detector import ClueLyDetector

app = Flask(__name__)

@app.route('/api/security/check')
def security_check():
    detection = ClueLyDetector.detect_cluely_detailed()
    
    return jsonify({
        'monitoring_detected': detection.is_detected,
        'severity': detection.severity_level,
        'evasion_techniques': detection.evasion_techniques,
        'window_count': detection.window_count,
        'timestamp': detection.timestamp.isoformat()
    })

if __name__ == '__main__':
    app.run(debug=True)
```

### Django Integration
```python
# views.py
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from no_cluely_detector import ClueLyDetector

@require_http_methods(["GET"])
def check_monitoring(request):
    detection = ClueLyDetector.detect_cluely_detailed()
    
    return JsonResponse({
        'detected': detection.is_detected,
        'severity': detection.severity_level,
        'techniques': detection.evasion_techniques,
        'report': detection.report
    })

# urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('security/check/', views.check_monitoring, name='check_monitoring'),
]
```

### FastAPI Application
```python
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
from datetime import datetime
from no_cluely_detector import ClueLyDetector, ClueLyDetection

app = FastAPI(title="Security Monitor API")

class SecurityStatus(BaseModel):
    detected: bool
    severity: str
    evasion_techniques: List[str]
    window_count: int
    timestamp: datetime

@app.get("/security/check", response_model=SecurityStatus)
async def check_security():
    detection = ClueLyDetector.detect_cluely_detailed()
    
    return SecurityStatus(
        detected=detection.is_detected,
        severity=detection.severity_level,
        evasion_techniques=detection.evasion_techniques,
        window_count=detection.window_count,
        timestamp=detection.timestamp
    )
```

### Background Monitoring Service
```python
import time
import logging
from no_cluely_detector import ClueLyMonitor
from email.mime.text import MimeText
import smtplib

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SecurityMonitorService:
    def __init__(self, email_alerts=True):
        self.monitor = ClueLyMonitor()
        self.email_alerts = email_alerts
        
    def start(self):
        logger.info("Starting security monitoring service...")
        
        self.monitor.start(
            interval=60.0,  # Check every minute
            on_detected=self._on_threat_detected,
            on_removed=self._on_threat_removed,
            on_change=self._on_status_change
        )
        
    def stop(self):
        logger.info("Stopping security monitoring service...")
        self.monitor.stop()
        
    def _on_threat_detected(self, detection):
        logger.warning(f"🚨 SECURITY THREAT DETECTED - Severity: {detection.severity_level}")
        
        if self.email_alerts:
            self._send_alert_email(detection)
            
        # Log to security system
        self._log_security_event("THREAT_DETECTED", detection)
        
    def _on_threat_removed(self):
        logger.info("✅ Security threat removed")
        self._log_security_event("THREAT_REMOVED", None)
        
    def _on_status_change(self, detection):
        # Log periodic status (every 10 minutes)
        if int(time.time()) % 600 == 0:
            status = "DETECTED" if detection.is_detected else "CLEAN"
            logger.info(f"Security status: {status}")
            
    def _send_alert_email(self, detection):
        # Implementation depends on your email setup
        subject = f"Security Alert: Employee Monitoring Detected ({detection.severity_level})"
        body = f"""
        Security Alert: Cluely employee monitoring software detected
        
        Severity: {detection.severity_level}
        Evasion Techniques: {', '.join(detection.evasion_techniques)}
        Window Count: {detection.window_count}
        Time: {detection.timestamp}
        
        Report:
        {detection.report}
        """
        # Send email implementation here
        
    def _log_security_event(self, event_type, detection):
        # Log to your security information system
        event_data = {
            'event_type': event_type,
            'timestamp': time.time(),
            'detection': detection.__dict__ if detection else None
        }
        logger.info(f"Security event: {event_data}")

# Usage
if __name__ == "__main__":
    service = SecurityMonitorService()
    service.start()
    
    try:
        # Keep the service running
        while True:
            time.sleep(60)
    except KeyboardInterrupt:
        service.stop()
```

### Jupyter Notebook Integration
```python
# Cell 1: Setup
from no_cluely_detector import ClueLyDetector, ClueLyMonitor
import pandas as pd
from datetime import datetime
import matplotlib.pyplot as plt

# Cell 2: Single Check
detection = ClueLyDetector.detect_cluely_detailed()

print(f"🔍 Security Check Results")
print(f"========================")
print(f"Detected: {'🚨 YES' if detection.is_detected else '✅ NO'}")
if detection.is_detected:
    print(f"Severity: {detection.severity_level}")
    print(f"Techniques: {', '.join(detection.evasion_techniques)}")

# Cell 3: Historical Analysis
detection_history = []

def record_detection(detection):
    detection_history.append({
        'timestamp': detection.timestamp,
        'detected': detection.is_detected,
        'severity': detection.severity_level,
        'window_count': detection.window_count
    })

monitor = ClueLyMonitor()
monitor.start(interval=30.0, on_change=record_detection)

# Let it run for a while, then analyze
# monitor.stop()

# Cell 4: Visualization
df = pd.DataFrame(detection_history)
df['timestamp'] = pd.to_datetime(df['timestamp'])

plt.figure(figsize=(12, 6))
plt.subplot(2, 1, 1)
plt.plot(df['timestamp'], df['detected'].astype(int))
plt.title('Detection Status Over Time')
plt.ylabel('Detected (1=Yes, 0=No)')

plt.subplot(2, 1, 2)
plt.plot(df['timestamp'], df['window_count'])
plt.title('Window Count Over Time')
plt.ylabel('Window Count')
plt.xlabel('Time')

plt.tight_layout()
plt.show()
```

### Automation Script
```python
#!/usr/bin/env python3
"""
Security monitoring automation script
Usage: python security_monitor.py [--interval SECONDS] [--log-file PATH]
"""

import argparse
import sys
import time
import json
from pathlib import Path
from no_cluely_detector import ClueLyMonitor

def main():
    parser = argparse.ArgumentParser(description='Monitor for Cluely employee monitoring software')
    parser.add_argument('--interval', type=float, default=60.0, 
                       help='Check interval in seconds (default: 60)')
    parser.add_argument('--log-file', type=Path, 
                       help='JSON log file path')
    parser.add_argument('--alert-command', type=str,
                       help='Command to run when threat detected')
    
    args = parser.parse_args()
    
    def log_detection(detection):
        log_entry = {
            'timestamp': detection.timestamp.isoformat(),
            'detected': detection.is_detected,
            'severity': detection.severity_level,
            'evasion_techniques': detection.evasion_techniques,
            'window_count': detection.window_count
        }
        
        if args.log_file:
            with open(args.log_file, 'a') as f:
                f.write(json.dumps(log_entry) + '\n')
        
        # Print to console
        status = f"🚨 DETECTED ({detection.severity_level})" if detection.is_detected else "✅ CLEAN"
        print(f"[{detection.timestamp}] {status}")
        
        if detection.is_detected and detection.evasion_techniques:
            print(f"  Techniques: {', '.join(detection.evasion_techniques)}")
    
    def on_detected(detection):
        print(f"🚨 ALERT: Employee monitoring detected! Severity: {detection.severity_level}")
        
        if args.alert_command:
            import subprocess
            try:
                subprocess.run(args.alert_command.split(), check=True)
            except subprocess.CalledProcessError as e:
                print(f"Alert command failed: {e}")
    
    print(f"Starting security monitor (interval: {args.interval}s)")
    if args.log_file:
        print(f"Logging to: {args.log_file}")
    
    monitor = ClueLyMonitor()
    monitor.start(
        interval=args.interval,
        on_detected=on_detected,
        on_change=log_detection
    )
    
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\nStopping monitor...")
        monitor.stop()

if __name__ == '__main__':
    main()
```

## Error Handling

```python
from no_cluely_detector import ClueLyDetector
import platform

try:
    detection = ClueLyDetector.detect_cluely_detailed()
    # Process detection...
except RuntimeError as e:
    if "only supported on macOS" in str(e):
        print("This library only works on macOS")
    else:
        print(f"Detection error: {e}")
except FileNotFoundError as e:
    print("Rust library not found. Please install properly.")
except Exception as e:
    print(f"Unexpected error: {e}")
```

## Performance

- **Detection Speed**: < 50ms per check
- **Memory Usage**: < 2MB resident memory
- **Thread Safety**: All methods are thread-safe
- **CPU Usage**: Minimal (< 0.1% during checks)

## Testing

```python
# test_detection.py
import pytest
from no_cluely_detector import ClueLyDetector, ClueLyMonitor

def test_basic_detection():
    """Test basic detection functionality."""
    result = ClueLyDetector.is_cluely_running()
    assert isinstance(result, bool)

def test_detailed_detection():
    """Test detailed detection."""
    detection = ClueLyDetector.detect_cluely_detailed()
    
    assert hasattr(detection, 'is_detected')
    assert hasattr(detection, 'severity_level')
    assert isinstance(detection.evasion_techniques, list)
    assert detection.severity_level in ['None', 'Low', 'Medium', 'High']

def test_monitor():
    """Test monitoring functionality."""
    monitor = ClueLyMonitor()
    
    # Should start and stop without issues
    monitor.start(interval=1.0)
    time.sleep(2)
    monitor.stop()

if __name__ == '__main__':
    pytest.main([__file__])
```

Run tests:
```bash
pip install pytest
python -m pytest test_detection.py -v
```

## License

MIT License

## Contributing

Issues and pull requests welcome at: https://github.com/your-org/no-cluely-driver 