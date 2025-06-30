# NoCluely 🎯

Detect Cluely cheating software and its evasion techniques from Node.js,
Electron, and TypeScript applications.

## Installation

```bash
npm install no-cluely
```

## Quick Start

### TypeScript/ES Modules

```typescript
import { NoCluely } from "no-cluely";

// Simple check
if (NoCluely.isCluelyRunning()) {
  console.log("⚠️ Employee monitoring detected!");
}

// Detailed analysis
const detection = CluelyDetector.detectCluelyDetailed();
console.log(`Severity: ${detection.severityLevel}`);
console.log(`Techniques: ${detection.evasionTechniques.join(", ")}`);
```

### CommonJS/Node.js

```javascript
const { NoCluely } = require("no-cluely");

// Simple check
if (NoCluely.isCluelyRunning()) {
  console.log("⚠️ Employee monitoring detected!");
}
```

### Electron Main Process

```typescript
import { app, BrowserWindow, ipcMain } from "electron";
import { NoCluely } from "no-cluely";

app.whenReady().then(() => {
  // Check for monitoring software on startup
  const detection = CluelyDetector.detectCluelyDetailed();
  if (detection.isDetected) {
    console.log("⚠️ Employee monitoring detected in Electron app");
  }
});

// Expose detection to renderer process
ipcMain.handle("check-cluely", () => {
  return CluelyDetector.detectCluelyDetailed();
});
```

## API Reference

### NoCluely Class

#### `NoCluely.isCluelyRunning(): boolean`

Simple check if Cluely is running.

```typescript
const isDetected = CluelyDetector.isCluelyRunning();
```

#### `CluelyDetector.detectCluely(): { isDetected: boolean; windowCount: number }`

Basic detection with window count.

```typescript
const { isDetected, windowCount } = CluelyDetector.detectCluely();
```

#### `CluelyDetector.detectCluelyDetailed(): CluelyDetection`

Comprehensive detection with evasion analysis.

```typescript
const detection = CluelyDetector.detectCluelyDetailed();
// Returns: CluelyDetection object with full details
```

#### `CluelyDetector.getCluelyReport(): string`

Get detailed text report.

```typescript
const report = CluelyDetector.getCluelyReport();
console.log(report);
```

#### `CluelyDetector.getCluelyWindowCount(): number`

Get number of Cluely windows.

```typescript
const count = CluelyDetector.getCluelyWindowCount();
```

### CluelyDetection Interface

```typescript
interface CluelyDetection {
  readonly isDetected: boolean;
  readonly windowCount: number;
  readonly screenCaptureEvasionCount: number;
  readonly elevatedLayerCount: number;
  readonly maxLayerDetected: number;
  readonly severityLevel: "None" | "Low" | "Medium" | "High";
  readonly evasionTechniques: string[];
  readonly report: string;
  readonly timestamp: Date;
}
```

### CluelyMonitor Class

Monitor for detection changes with event callbacks.

```typescript
import { CluelyMonitor } from "@no-cluely/detector";

const monitor = new CluelyMonitor();
monitor.start(5000, {
  onDetected: (detection) => {
    console.log("🚨 Cluely detected!", detection);
  },
  onRemoved: () => {
    console.log("✅ Cluely monitoring stopped");
  },
  onChange: (detection) => {
    // Called on every check
  },
});

// Stop monitoring
monitor.stop();
```

## Usage Examples

### Express.js Server

```typescript
import express from "express";
import { CluelyDetector } from "@no-cluely/detector";

const app = express();

app.get("/security/check", (req, res) => {
  const detection = CluelyDetector.detectCluelyDetailed();
  res.json({
    monitoring_detected: detection.isDetected,
    severity: detection.severityLevel,
    evasion_techniques: detection.evasionTechniques,
    timestamp: detection.timestamp,
  });
});

app.listen(3000);
```

### Electron Renderer (with IPC)

```typescript
// In preload.js
import { contextBridge, ipcRenderer } from "electron";

contextBridge.exposeInMainWorld("cluely", {
  checkMonitoring: () => ipcRenderer.invoke("check-cluely"),
});

// In renderer
window.cluely.checkMonitoring().then((detection) => {
  if (detection.isDetected) {
    showWarning("Employee monitoring detected!");
  }
});
```

### React Component

```tsx
import React, { useEffect, useState } from "react";
import { CluelyDetection, CluelyDetector } from "@no-cluely/detector";

export const MonitoringAlert: React.FC = () => {
  const [detection, setDetection] = useState<CluelyDetection | null>(null);

  useEffect(() => {
    const checkMonitoring = () => {
      setDetection(CluelyDetector.detectCluelyDetailed());
    };

    checkMonitoring();
    const interval = setInterval(checkMonitoring, 10000);

    return () => clearInterval(interval);
  }, []);

  if (!detection?.isDetected) return null;

  return (
    <div className="alert alert-warning">
      <h4>⚠️ Employee Monitoring Detected</h4>
      <p>Severity: {detection.severityLevel}</p>
      <p>Techniques: {detection.evasionTechniques.join(", ")}</p>
    </div>
  );
};
```

### Vue.js Component

```vue
<template>
  <div v-if="detection?.isDetected" class="monitoring-alert">
    <h3>⚠️ Employee Monitoring Detected</h3>
    <p>Severity: {{ detection.severityLevel }}</p>
    <ul>
      <li v-for="technique in detection.evasionTechniques" :key="technique">
        {{ technique }}
      </li>
    </ul>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue';
import { CluelyDetector, type CluelyDetection } from '@no-cluely/detector';

const detection = ref<CluelyDetection | null>(null);
let interval: NodeJS.Timeout;

onMounted(() => {
  const checkMonitoring = () => {
    detection.value = CluelyDetector.detectCluelyDetailed();
  };
  
  checkMonitoring();
  interval = setInterval(checkMonitoring, 10000);
});

onUnmounted(() => {
  if (interval) clearInterval(interval);
});
</script>
```

### Background Monitoring Service

```typescript
import { CluelyMonitor } from "@no-cluely/detector";
import { EventEmitter } from "events";

class SecurityService extends EventEmitter {
  private monitor = new CluelyMonitor();

  start() {
    this.monitor.start(5000, {
      onDetected: (detection) => {
        this.emit("threat-detected", {
          type: "employee-monitoring",
          severity: detection.severityLevel,
          details: detection,
        });

        // Log to security system
        this.logSecurityEvent("MONITORING_DETECTED", detection);
      },

      onRemoved: () => {
        this.emit("threat-removed", {
          type: "employee-monitoring",
        });
      },
    });
  }

  stop() {
    this.monitor.stop();
  }

  private logSecurityEvent(event: string, data: any) {
    console.log(`[SECURITY] ${event}:`, data);
    // Send to logging service, SIEM, etc.
  }
}

const security = new SecurityService();
security.start();
```

### CLI Wrapper

```typescript
#!/usr/bin/env node
import { CluelyDetector } from "@no-cluely/detector";

const args = process.argv.slice(2);

switch (args[0]) {
  case "check":
    const isDetected = CluelyDetector.isCluelyRunning();
    console.log(isDetected ? "🚨 DETECTED" : "✅ NOT DETECTED");
    process.exit(isDetected ? 1 : 0);
    break;

  case "report":
    console.log(CluelyDetector.getCluelyReport());
    break;

  case "json":
    console.log(JSON.stringify(CluelyDetector.detectCluelyDetailed(), null, 2));
    break;

  default:
    console.log("Usage: npx @no-cluely/detector [check|report|json]");
}
```

## Webpack Configuration (for Browser Builds)

If you need to bundle this for browser use (note: this only works in Electron,
not web browsers):

```javascript
// webpack.config.js
module.exports = {
  target: "electron-main", // or 'electron-renderer'
  externals: {
    "ffi-napi": "commonjs ffi-napi",
    "ref-napi": "commonjs ref-napi",
    "ref-struct-di": "commonjs ref-struct-di",
  },
};
```

## Error Handling

```typescript
import { CluelyDetector } from "@no-cluely/detector";

try {
  const detection = CluelyDetector.detectCluelyDetailed();
  // Process detection...
} catch (error) {
  if (error.message.includes("only supported on macOS")) {
    console.log("This library only works on macOS");
  } else {
    console.error("Detection failed:", error);
  }
}
```

## Performance Considerations

- Detection is fast (< 50ms typically)
- Minimal memory footprint (< 1MB)
- Thread-safe: can be called from any Node.js thread
- No network requests or external dependencies

## Requirements

- **Node.js**: 16.0.0 or later
- **Platform**: macOS only (Darwin)
- **Architecture**: x64 (Intel/Apple Silicon)

## Platform Support

| Platform | Supported | Notes                |
| -------- | --------- | -------------------- |
| macOS    | ✅        | Primary platform     |
| Windows  | ❌        | Cluely is macOS-only |
| Linux    | ❌        | Cluely is macOS-only |

## License

MIT License

## Contributing

Don't