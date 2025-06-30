# NoCluely-py

Python library for detecting Cluely employee monitoring software and its evasion
techniques.

## Installation

```bash
pip install no-cluely
```

### Requirements

- **Python**: 3.8 or later
- **Platform**: macOS only (Cluely is macOS-specific)
- **Architecture**: x64 (Intel/Apple Silicon)

## Quick Start

### Simple Detection

```python
from no_cluely import NoCluely

# Quick check
if NoCluely.is_cluely_running():
    print("⚠️ Employee monitoring detected!")
else:
    print("✅ No monitoring software found")
```

### Detailed Analysis

```python
from no_cluely import NoCluely

detection = NoCluely.detect_cluely_detailed()

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
from no_cluely import CluelyMonitor

def on_detected(detection):
    print(f"🚨 Monitoring started! Severity: {detection.severity_level}")

def on_removed():
    print("✅ Monitoring stopped")

monitor = CluelyMonitor()
monitor.start(
    interval=5.0,  # Check every 5 seconds
    on_detected=on_detected,
    on_removed=on_removed
)

# Your application continues...
# Call monitor.stop() when done
```

## License

MIT License

## Contributing

Don't