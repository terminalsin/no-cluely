# No-Cluely Driver SDK 🎯

**Complete Multi-Language SDK for Detecting Cluely Employee Monitoring Software**

This comprehensive SDK provides detection libraries for Cluely employee monitoring software across multiple programming languages and platforms. Built on a high-performance Rust core, it offers consistent APIs and functionality across all supported languages.

## 🚀 Quick Start

### CLI (Command Line)
```bash
# Download and install
./build-all.sh --only-cli

# Quick check
./packages/cluely-detector check

# Continuous monitoring
./packages/cluely-detector monitor --interval 30
```

### Node.js/TypeScript
```bash
npm install @no-cluely/detector
```
```javascript
import { ClueLyDetector } from '@no-cluely/detector';

if (ClueLyDetector.isClueLyRunning()) {
  console.log('⚠️ Employee monitoring detected!');
}
```

### Python
```bash
pip install no-cluely-detector
```
```python
from no_cluely_detector import ClueLyDetector

if ClueLyDetector.is_cluely_running():
    print("⚠️ Employee monitoring detected!")
```

### Java
```xml
<dependency>
    <groupId>com.nocluely</groupId>
    <artifactId>cluely-detector</artifactId>
    <version>1.0.0</version>
</dependency>
```
```java
import com.nocluely.ClueLyDetector;

if (ClueLyDetector.isClueLyRunning()) {
    System.out.println("⚠️ Employee monitoring detected!");
}
```

### Swift
```swift
import ClueLyDetector

if ClueLyDetector.isClueLyRunning() {
    print("⚠️ Employee monitoring detected!")
}
```

### C/C++
```c
#include "no_cluely_driver.h"

if (is_cluely_running()) {
    printf("⚠️ Employee monitoring detected!\n");
}
```

## 📦 What's Included

This SDK provides **7 different ways** to detect Cluely monitoring software:

| Component           | Language              | Use Case                               | Package                        |
| ------------------- | --------------------- | -------------------------------------- | ------------------------------ |
| **CLI App**         | Rust                  | Command line, scripts, automation      | `cluely-detector` binary       |
| **Node.js Library** | TypeScript/JavaScript | Web apps, Electron, Node.js services   | `@no-cluely/detector`          |
| **Python Library**  | Python                | Data science, automation, Django/Flask | `no-cluely-detector`           |
| **Java Library**    | Java                  | Enterprise apps, Spring, Android       | `com.nocluely:cluely-detector` |
| **Swift Package**   | Swift                 | iOS/macOS apps, SwiftUI                | `ClueLyDetector`               |
| **C Library**       | C/C++                 | System integration, embedded           | `libno_cluely_driver.dylib`    |
| **Rust Library**    | Rust                  | High-performance applications          | `no-cluely-driver` crate       |

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                        │
├─────────────┬─────────────┬─────────────┬─────────────┬─────┤
│   Node.js   │   Python    │    Java     │   Swift     │ CLI │
│  TypeScript │   bindings  │     JNI     │   Package   │ App │
├─────────────┼─────────────┼─────────────┼─────────────┼─────┤
│             │             │   C Headers │             │     │
│    FFI      │   ctypes    │  (JNI impl) │ C Bindings  │     │
├─────────────┴─────────────┴─────────────┴─────────────┴─────┤
│                   Rust Core Library                        │
│          (libno_cluely_driver.dylib)                       │
├─────────────────────────────────────────────────────────────┤
│               macOS Core Graphics API                      │
│          (CGWindowListCopyWindowInfo, etc.)                │
└─────────────────────────────────────────────────────────────┘
```

## 🔍 Detection Capabilities

### Evasion Techniques Detected

1. **Screen Capture Evasion** (`sharing_state = 0`)
   - Windows configured to avoid screen capture
   - Invisible during screen sharing sessions

2. **Elevated Layer Positioning** (`layer > 0`)
   - Windows positioned above normal application layers
   - Potential overlay techniques

3. **Process Analysis**
   - Identifies Cluely-related processes
   - Detects monitoring software signatures

### Detection Levels

- **None**: No monitoring detected
- **Low**: Basic detection without evasion techniques
- **Medium**: Some evasion techniques detected
- **High**: Multiple evasion techniques in use

## 🛠️ Building from Source

### Prerequisites

- **macOS**: 10.15+ (Catalina or later)
- **Rust**: 1.70+ with Cargo
- **Node.js**: 16+ (for Node.js bindings)
- **Python**: 3.8+ (for Python bindings)
- **Java**: 11+ with Maven (for Java bindings)
- **Swift**: 5.7+ (for Swift bindings)

### Build All Languages

```bash
# Build everything
./build-all.sh

# Build specific components
./build-all.sh --only-python
./build-all.sh --only-node
./build-all.sh --no-java --no-swift

# Clean and rebuild
./build-all.sh --clean

# See all options
./build-all.sh --help
```

### Build Individual Components

```bash
# Rust library only
cargo build --lib --release

# CLI application
cd bindings/cli && cargo build --release

# Node.js bindings
cd bindings/node && npm install && npm run build

# Python bindings
cd bindings/python && python3 setup.py build

# Java bindings
cd bindings/java && mvn clean package

# Swift package
cd bindings/swift && swift build -c release
```

## 📚 Language-Specific Documentation

Each language binding has comprehensive documentation with examples:

- **[CLI README](bindings/cli/README.md)** - Command line usage, scripting, automation
- **[Node.js README](bindings/node/README.md)** - TypeScript/JavaScript, Electron, React, Vue
- **[Python README](bindings/python/README.md)** - Flask/Django, data science, automation
- **[Java README](bindings/java/README.md)** - Spring Boot, Android, enterprise applications
- **[Swift README](bindings/swift/README.md)** - iOS/macOS apps, SwiftUI integration
- **[C Integration](include/no_cluely_driver.h)** - C/C++ header file with API documentation

## 🔧 API Reference

All language bindings provide consistent core functionality:

### Basic Detection
```
isClueLyRunning() -> boolean
```

### Detailed Detection
```
detectClueLyDetailed() -> DetectionResult {
    isDetected: boolean
    windowCount: number
    screenCaptureEvasionCount: number
    elevatedLayerCount: number
    maxLayerDetected: number
    severityLevel: string
    evasionTechniques: string[]
    report: string
    timestamp: date
}
```

### Monitoring
```
startMonitoring(interval, callbacks)
stopMonitoring()
```

## 🌐 Integration Examples

### Web Applications

**Express.js + Node.js**
```javascript
app.get('/api/security/check', (req, res) => {
  const detection = ClueLyDetector.detectClueLyDetailed();
  res.json(detection);
});
```

**Flask + Python**
```python
@app.route('/api/security/check')
def check_security():
    detection = ClueLyDetector.detect_cluely_detailed()
    return jsonify(detection.__dict__)
```

**Spring Boot + Java**
```java
@GetMapping("/api/security/check")
public ResponseEntity<ClueLyDetection> checkSecurity() {
    return ResponseEntity.ok(ClueLyDetector.detectClueLyDetailed());
}
```

### Desktop Applications

**Electron (Renderer Process)**
```javascript
const detection = await window.electronAPI.checkCluely();
if (detection.isDetected) {
  showSecurityWarning(detection);
}
```

**SwiftUI (macOS)**
```swift
struct SecurityView: View {
    @StateObject private var monitor = ClueLyDetectionMonitor()
    
    var body: some View {
        ClueLyDetectionView()
            .onAppear { monitor.startMonitoring() }
    }
}
```

**JavaFX (Desktop)**
```java
SecurityMonitorTask task = new SecurityMonitorTask();
task.setOnSucceeded(e -> {
    ClueLyDetection detection = task.getValue();
    if (detection.isDetected()) {
        showAlert("Security Warning", detection.getSummary());
    }
});
```

### Mobile Applications

**React Native + Node.js Backend**
```javascript
// Backend API
app.get('/security/check', (req, res) => {
  res.json(ClueLyDetector.detectClueLyDetailed());
});

// React Native App
const checkSecurity = async () => {
  const response = await fetch('/security/check');
  const detection = await response.json();
  if (detection.isDetected) {
    Alert.alert('Security Warning', detection.summary);
  }
};
```

### Automation & Monitoring

**Shell Script with CLI**
```bash
#!/bin/bash
while true; do
  if cluely-detector check; then
    echo "$(date): System clean"
  else
    echo "$(date): ⚠️ Monitoring detected!" | mail admin@company.com
  fi
  sleep 300  # Check every 5 minutes
done
```

**Python Monitoring Service**
```python
import schedule
from no_cluely_detector import ClueLyMonitor

def alert_detected(detection):
    send_email(f"Security Alert: {detection.severity_level}")

monitor = ClueLyMonitor()
monitor.start(interval=60.0, on_detected=alert_detected)

# Keep running
while True:
    time.sleep(1)
```

**Java Background Service**
```java
@Service
public class SecurityService {
    @Scheduled(fixedRate = 60000)
    public void checkSecurity() {
        ClueLyDetection detection = ClueLyDetector.detectClueLyDetailed();
        if (detection.isDetected()) {
            alertService.sendAlert(detection);
        }
    }
}
```

## 🚨 Security Considerations

### Privacy & Ethics
- This tool is designed for **transparency and employee awareness**
- Should be used to **inform employees** about monitoring, not hide detection
- Respects legitimate business needs while protecting employee privacy rights

### Usage Guidelines
- ✅ Employee awareness and transparency tools
- ✅ Privacy auditing and compliance checking
- ✅ Security research and education
- ❌ Circumventing legitimate business monitoring
- ❌ Violating employment agreements
- ❌ Malicious or unauthorized use

### Detection Accuracy
- **Low false positives**: Conservative detection algorithms
- **Specific signatures**: Targets known Cluely evasion techniques
- **Regular updates**: Detection patterns updated as software evolves

## 📊 Performance

| Metric          | Value                      |
| --------------- | -------------------------- |
| Detection Speed | < 50ms per check           |
| Memory Usage    | < 5MB (varies by language) |
| CPU Usage       | < 0.1% during checks       |
| Thread Safety   | ✅ All languages            |
| Library Size    | 395KB (Rust dylib)         |

## 🔧 Troubleshooting

### Common Issues

**Library Not Found**
```bash
# macOS: Add to library path
export DYLD_LIBRARY_PATH=/usr/local/lib:$DYLD_LIBRARY_PATH

# Or copy to system location
sudo cp libno_cluely_driver.dylib /usr/local/lib/
```

**Permission Denied**
```bash
# Make CLI executable
chmod +x cluely-detector

# Grant accessibility permissions if needed
# System Preferences > Security & Privacy > Accessibility
```

**Build Failures**
```bash
# Clean and retry
./build-all.sh --clean
cargo clean

# Check dependencies
rustc --version  # Should be 1.70+
node --version   # Should be 16+
python3 --version  # Should be 3.8+
```

### Platform Support

| Platform                | Status            | Notes                   |
| ----------------------- | ----------------- | ----------------------- |
| **macOS Intel**         | ✅ Fully Supported | Primary target platform |
| **macOS Apple Silicon** | ✅ Fully Supported | Native ARM64 support    |
| **Windows**             | ❌ Not Supported   | Cluely is macOS-only    |
| **Linux**               | ❌ Not Supported   | Cluely is macOS-only    |

## 🤝 Contributing

We welcome contributions to improve detection accuracy and add new language bindings!

### Development Setup
```bash
git clone <repository-url>
cd no-cluely-driver
./build-all.sh --clean
./build-all.sh
```

### Adding New Language Bindings
1. Create `bindings/{language}/` directory
2. Implement core API functions
3. Add to `build-all.sh`
4. Create comprehensive README
5. Add tests and examples

### Reporting Issues
- **Detection Issues**: False positives/negatives
- **Build Problems**: Platform-specific build failures  
- **Performance**: Unexpectedly slow detection
- **Feature Requests**: New language bindings, API improvements

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Documentation**: Language-specific READMEs in `bindings/` directories
- **Examples**: See each language's README for comprehensive examples
- **Issues**: [Report bugs and feature requests](https://github.com/your-org/no-cluely-driver/issues)
- **Discussions**: [Community discussions](https://github.com/your-org/no-cluely-driver/discussions)

---

**🎯 Empowering employee privacy awareness through transparency.**

*Built with ❤️ for workplace transparency and employee rights.* 