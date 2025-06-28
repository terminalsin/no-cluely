# Cluely Detector CLI 🎯

A command-line tool for detecting Cluely employee monitoring software and its evasion techniques.

## Installation

### From Source
```bash
git clone <repository>
cd no-cluely-driver/bindings/cli
cargo build --release
```

### Using Cargo
```bash
cargo install cluely-detector-cli
```

## Usage

### Quick Check
```bash
# Simple detection check
cluely-detector
# or
cluely-detector check
```

### Detailed Report
```bash
# Get comprehensive analysis with evasion techniques
cluely-detector report
```

### Continuous Monitoring
```bash
# Monitor for Cluely every 10 seconds (default)
cluely-detector monitor

# Custom interval (30 seconds)
cluely-detector monitor --interval 30
```

### JSON Output
```bash
# Machine-readable output for scripts/automation
cluely-detector json
```

### Statistics
```bash
# Show detection statistics and technique breakdown
cluely-detector stats
```

## Examples

### Basic Detection
```bash
$ cluely-detector
🎯 Cluely Detection
=================

✅ NO CLUELY DETECTED
No employee monitoring software found.
```

### When Cluely is Detected
```bash
$ cluely-detector
🎯 Cluely Detection
=================

🚨 CLUELY DETECTED
Employee monitoring software is running on this system.

💡 Use 'cluely-detector report' for detailed analysis
```

### Detailed Report
```bash
$ cluely-detector report
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
```

### JSON Output
```bash
$ cluely-detector json
{
  "detected": true,
  "window_count": 2,
  "screen_capture_evasion_count": 2,
  "elevated_layer_count": 1,
  "max_layer_detected": 3,
  "severity": "High",
  "evasion_techniques": [
    "Screen capture evasion (2 windows)",
    "Elevated layer positioning (1 windows)"
  ],
  "timestamp": "2024-06-28T17:30:45.123Z"
}
```

### Statistics View
```bash
$ cluely-detector stats
📊 Detection Statistics
======================

Detection Status:          DETECTED
Total Windows:             2
Screen Capture Evasion:    2
Elevated Layer Usage:      1
Max Layer Detected:        3
Severity Level:            High

Evasion Techniques:
  • Screen capture evasion (2 windows)
  • Elevated layer positioning (1 windows)
```

### Continuous Monitoring
```bash
$ cluely-detector monitor
🔍 Monitoring for Cluely (Press Ctrl+C to stop)
=============================================

[2024-06-28 17:30:00 UTC] Status: NOT DETECTED
[2024-06-28 17:30:45 UTC] 🚨 CLUELY DETECTED - Monitoring software started!
[2024-06-28 17:31:00 UTC] Status: DETECTED
[2024-06-28 17:32:15 UTC] ✅ Cluely monitoring stopped
^C
👋 Monitoring stopped
```

## Exit Codes

- `0`: No Cluely detected (success)
- `1`: Cluely detected or error occurred

## Integration with Scripts

### Shell Script
```bash
#!/bin/bash
if cluely-detector check; then
    echo "System is clean"
else
    echo "⚠️ Monitoring detected!"
    # Send alert, log, etc.
fi
```

### With jq for JSON Processing
```bash
# Get severity level
SEVERITY=$(cluely-detector json | jq -r '.severity')
echo "Detection severity: $SEVERITY"

# Check if screen capture evasion is being used
EVASION=$(cluely-detector json | jq -r '.screen_capture_evasion_count')
if [ "$EVASION" -gt 0 ]; then
    echo "⚠️ Screen capture evasion detected!"
fi
```

### Automation Example
```bash
#!/bin/bash
# Daily monitoring script

LOG_FILE="/var/log/cluely-detection.log"
RESULT=$(cluely-detector json)
TIMESTAMP=$(date)

echo "[$TIMESTAMP] $RESULT" >> "$LOG_FILE"

# Send alert if detected
if echo "$RESULT" | jq -e '.detected' > /dev/null; then
    # Send notification (email, Slack, etc.)
    echo "Cluely monitoring detected at $TIMESTAMP" | mail -s "Security Alert" admin@company.com
fi
```

## Requirements

- macOS 10.15+ (Catalina or later)
- May require accessibility permissions for full detection

## License

MIT License 