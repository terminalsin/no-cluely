# Cluely Detector Java 🎯

Java library for detecting Cluely employee monitoring software and its evasion
techniques.

## Features

- **High Performance**: Built on a fast Rust detection engine
- **Thread-Safe**: Use from any thread in your Java application
- **Type-Safe**: Full type safety with comprehensive API
- **Easy Integration**: Simple Maven/Gradle integration
- **Detailed Analysis**: Comprehensive evasion technique reporting
- **Cross-Framework**: Works with Spring, Android, JavaFX, etc.

## Installation

### Maven

```xml
<dependency>
    <groupId>com.nocluely</groupId>
    <artifactId>cluely-detector</artifactId>
    <version>1.0.0</version>
</dependency>
```

### Gradle

```gradle
implementation 'com.nocluely:cluely-detector:1.0.0'
```

### Requirements

- **Java**: 11 or later
- **Platform**: macOS only (Cluely is macOS-specific)
- **Architecture**: x64 (Intel/Apple Silicon)

## Quick Start

### Simple Detection

```java
import com.nocluely.ClueLyDetector;

// Quick check
if (ClueLyDetector.isClueLyRunning()) {
    System.out.println("⚠️ Employee monitoring detected!");
} else {
    System.out.println("✅ No monitoring software found");
}
```

### Detailed Analysis

```java
import com.nocluely.ClueLyDetector;
import com.nocluely.ClueLyDetection;

ClueLyDetection detection = ClueLyDetector.detectClueLyDetailed();

if (detection.isDetected()) {
    System.out.println("🚨 Cluely Detected!");
    System.out.println("   Severity: " + detection.getSeverityLevel());
    System.out.println("   Windows: " + detection.getWindowCount());
    System.out.println("   Techniques: " + detection.getEvasionTechniques());
} else {
    System.out.println("✅ System clean");
}
```

## API Reference

### ClueLyDetector

Main detection class with static methods.

#### Methods

##### `ClueLyDetector.isClueLyRunning(): boolean`

Simple boolean check for Cluely presence.

```java
boolean detected = ClueLyDetector.isClueLyRunning();
```

##### `ClueLyDetector.detectClueLy(): DetectionResult`

Basic detection returning status and window count.

```java
ClueLyDetector.DetectionResult result = ClueLyDetector.detectClueLy();
System.out.println("Detected: " + result.isDetected());
System.out.println("Windows: " + result.getWindowCount());
```

##### `ClueLyDetector.detectClueLyDetailed(): ClueLyDetection`

Comprehensive detection with full analysis.

```java
ClueLyDetection detection = ClueLyDetector.detectClueLyDetailed();
// Returns ClueLyDetection object with all details
```

##### `ClueLyDetector.getClueLyReport(): String`

Detailed text report of findings.

```java
String report = ClueLyDetector.getClueLyReport();
System.out.println(report);
```

##### `ClueLyDetector.getClueLyWindowCount(): int`

Number of Cluely windows detected.

```java
int count = ClueLyDetector.getClueLyWindowCount();
```

### ClueLyDetection

Immutable data class containing detailed detection information.

#### Properties

- `isDetected(): boolean` - True if Cluely is detected
- `getWindowCount(): int` - Total number of Cluely windows
- `getScreenCaptureEvasionCount(): int` - Windows using screen capture evasion
- `getElevatedLayerCount(): int` - Windows using elevated layer positioning
- `getMaxLayerDetected(): int` - Highest layer number found
- `getSeverityLevel(): SeverityLevel` - Severity (NONE, LOW, MEDIUM, HIGH)
- `getEvasionTechniques(): List<String>` - List of detected techniques
- `getReport(): String` - Detailed text report
- `getTimestamp(): Instant` - Detection timestamp

```java
ClueLyDetection detection = ClueLyDetector.detectClueLyDetailed();

System.out.println("Detected: " + detection.isDetected());
System.out.println("Severity: " + detection.getSeverityLevel());
System.out.println("Summary: " + detection.getSummary());

for (String technique : detection.getEvasionTechniques()) {
    System.out.println("  - " + technique);
}
```

## Usage Examples

### Spring Boot Application

```java
@RestController
@RequestMapping("/api/security")
public class SecurityController {
    
    @GetMapping("/check")
    public ResponseEntity<SecurityResponse> checkSecurity() {
        ClueLyDetection detection = ClueLyDetector.detectClueLyDetailed();
        
        SecurityResponse response = new SecurityResponse(
            detection.isDetected(),
            detection.getSeverityLevel().toString(),
            detection.getEvasionTechniques(),
            detection.getWindowCount(),
            detection.getTimestamp()
        );
        
        return ResponseEntity.ok(response);
    }
}

@Data
@AllArgsConstructor
public class SecurityResponse {
    private boolean monitoringDetected;
    private String severity;
    private List<String> evasionTechniques;
    private int windowCount;
    private Instant timestamp;
}
```

### Background Monitoring Service

```java
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@Service
public class SecurityMonitorService {
    
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    private final Logger logger = LoggerFactory.getLogger(SecurityMonitorService.class);
    
    private ClueLyDetection lastDetection = null;
    
    @PostConstruct
    public void startMonitoring() {
        scheduler.scheduleAtFixedRate(this::checkSecurity, 0, 60, TimeUnit.SECONDS);
        logger.info("Security monitoring started");
    }
    
    @PreDestroy
    public void stopMonitoring() {
        scheduler.shutdown();
        logger.info("Security monitoring stopped");
    }
    
    private void checkSecurity() {
        try {
            ClueLyDetection detection = ClueLyDetector.detectClueLyDetailed();
            
            // Check for state changes
            if (lastDetection != null) {
                if (detection.isDetected() && !lastDetection.isDetected()) {
                    onThreatDetected(detection);
                } else if (!detection.isDetected() && lastDetection.isDetected()) {
                    onThreatRemoved();
                }
            } else if (detection.isDetected()) {
                onThreatDetected(detection);
            }
            
            lastDetection = detection;
            
        } catch (Exception e) {
            logger.error("Security check failed", e);
        }
    }
    
    private void onThreatDetected(ClueLyDetection detection) {
        logger.warn("🚨 SECURITY THREAT DETECTED - Severity: {}", detection.getSeverityLevel());
        
        // Send alerts, notifications, etc.
        sendSecurityAlert(detection);
        logSecurityEvent("THREAT_DETECTED", detection);
    }
    
    private void onThreatRemoved() {
        logger.info("✅ Security threat removed");
        logSecurityEvent("THREAT_REMOVED", null);
    }
    
    private void sendSecurityAlert(ClueLyDetection detection) {
        // Implementation depends on your alerting system
        // Could send emails, Slack messages, push notifications, etc.
    }
    
    private void logSecurityEvent(String eventType, ClueLyDetection detection) {
        // Log to your security information system
        SecurityEvent event = new SecurityEvent(eventType, Instant.now(), detection);
        // Save to database, send to SIEM, etc.
    }
}
```

### JavaFX Desktop Application

```java
import javafx.concurrent.Task;
import javafx.scene.control.Alert;

public class SecurityMonitorTask extends Task<ClueLyDetection> {
    
    @Override
    protected ClueLyDetection call() throws Exception {
        return ClueLyDetector.detectClueLyDetailed();
    }
    
    @Override
    protected void succeeded() {
        ClueLyDetection detection = getValue();
        
        if (detection.isDetected()) {
            Platform.runLater(() -> {
                Alert alert = new Alert(Alert.AlertType.WARNING);
                alert.setTitle("Security Warning");
                alert.setHeaderText("Employee Monitoring Detected");
                alert.setContentText(
                    "Severity: " + detection.getSeverityLevel() + "\n" +
                    "Techniques: " + String.join(", ", detection.getEvasionTechniques())
                );
                alert.showAndWait();
            });
        }
    }
}

// In your main application
SecurityMonitorTask task = new SecurityMonitorTask();
new Thread(task).start();
```

### Android Integration

```java
public class SecurityService extends Service {
    
    private Handler handler = new Handler(Looper.getMainLooper());
    private Runnable securityCheck = new Runnable() {
        @Override
        public void run() {
            try {
                // Note: This would only work on macOS, so Android usage would be limited
                // This is just an example of the API usage
                ClueLyDetection detection = ClueLyDetector.detectClueLyDetailed();
                
                if (detection.isDetected()) {
                    showSecurityNotification(detection);
                }
                
            } catch (Exception e) {
                Log.e("SecurityService", "Detection failed", e);
            }
            
            handler.postDelayed(this, 60000); // Check every minute
        }
    };
    
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        handler.post(securityCheck);
        return START_STICKY;
    }
    
    @Override
    public void onDestroy() {
        handler.removeCallbacks(securityCheck);
        super.onDestroy();
    }
    
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
    
    private void showSecurityNotification(ClueLyDetection detection) {
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_security_warning)
            .setContentTitle("Security Alert")
            .setContentText("Employee monitoring detected: " + detection.getSeverityLevel())
            .setPriority(NotificationCompat.PRIORITY_HIGH);
        
        NotificationManagerCompat.from(this).notify(1, builder.build());
    }
}
```

### JUnit Testing

```java
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.condition.EnabledOnOs;
import org.junit.jupiter.api.condition.OS;
import static org.junit.jupiter.api.Assertions.*;

@EnabledOnOs(OS.MAC) // Only run on macOS
public class ClueLyDetectorTest {
    
    @Test
    public void testLibraryLoaded() {
        assertTrue(ClueLyDetector.isLibraryLoaded(), "Native library should be loaded");
        assertNull(ClueLyDetector.getLoadException(), "No load exception should be present");
    }
    
    @Test
    public void testBasicDetection() {
        // Basic detection should not throw
        assertDoesNotThrow(() -> {
            boolean result = ClueLyDetector.isClueLyRunning();
            // Result can be true or false, just shouldn't throw
        });
    }
    
    @Test
    public void testDetailedDetection() {
        ClueLyDetection detection = ClueLyDetector.detectClueLyDetailed();
        
        assertNotNull(detection);
        assertNotNull(detection.getSeverityLevel());
        assertNotNull(detection.getEvasionTechniques());
        assertNotNull(detection.getReport());
        assertNotNull(detection.getTimestamp());
        
        // Severity should be valid
        assertTrue(detection.getSeverityLevel() == ClueLyDetection.SeverityLevel.NONE ||
                  detection.getSeverityLevel() == ClueLyDetection.SeverityLevel.LOW ||
                  detection.getSeverityLevel() == ClueLyDetection.SeverityLevel.MEDIUM ||
                  detection.getSeverityLevel() == ClueLyDetection.SeverityLevel.HIGH);
    }
    
    @Test
    public void testReportGeneration() {
        String report = ClueLyDetector.getClueLyReport();
        assertNotNull(report);
        assertFalse(report.isEmpty());
    }
    
    @Test
    public void testWindowCount() {
        int count = ClueLyDetector.getClueLyWindowCount();
        assertTrue(count >= 0, "Window count should be non-negative");
    }
}
```

### Configuration Class

```java
@Configuration
@ConditionalOnProperty(name = "security.monitoring.enabled", havingValue = "true")
public class SecurityConfig {
    
    @Bean
    public SecurityProperties securityProperties() {
        return new SecurityProperties();
    }
    
    @Bean
    @ConditionalOnBean(SecurityProperties.class)
    public SecurityMonitorService securityMonitorService(SecurityProperties properties) {
        return new SecurityMonitorService(properties);
    }
}

@ConfigurationProperties(prefix = "security.monitoring")
@Data
public class SecurityProperties {
    private boolean enabled = true;
    private int checkIntervalSeconds = 60;
    private boolean emailAlerts = true;
    private String alertEmailAddress = "security@company.com";
}
```

## Error Handling

```java
try {
    ClueLyDetection detection = ClueLyDetector.detectClueLyDetailed();
    // Process detection...
} catch (RuntimeException e) {
    if (e.getMessage().contains("only supported on macOS")) {
        System.out.println("This library only works on macOS");
    } else if (e.getMessage().contains("Failed to load native library")) {
        System.out.println("Native library could not be loaded: " + e.getMessage());
    } else {
        System.out.println("Detection error: " + e.getMessage());
    }
}
```

## JSON Serialization

The library includes Jackson support for JSON serialization:

```java
import com.fasterxml.jackson.databind.ObjectMapper;

ObjectMapper mapper = new ObjectMapper();
ClueLyDetection detection = ClueLyDetector.detectClueLyDetailed();

// Serialize to JSON
String json = mapper.writeValueAsString(detection);

// Deserialize from JSON
ClueLyDetection restored = mapper.readValue(json, ClueLyDetection.class);
```

## Performance

- **Detection Speed**: < 50ms per check
- **Memory Usage**: < 5MB heap usage
- **Thread Safety**: All methods are thread-safe
- **CPU Usage**: Minimal (< 0.1% during checks)

## Requirements

- **Java**: 11 or later
- **Platform**: macOS only (Darwin)
- **Architecture**: x64 (Intel/Apple Silicon)
- **Dependencies**: Jackson (optional, for JSON serialization)

## Building from Source

```bash
# Clone the repository
git clone <repository-url>
cd no-cluely-driver/bindings/java

# Build with Maven
mvn clean install

# Run tests
mvn test

# Generate Javadocs
mvn javadoc:javadoc
```

## License

MIT License

## Contributing

Issues and pull requests welcome at:
https://github.com/your-org/no-cluely-driver
