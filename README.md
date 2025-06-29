![Untitled drawing (5)](https://github.com/user-attachments/assets/6a3730e3-5d5e-4d6a-b486-58d74307a31d)

Cluely is an ~~undetectable~~ AI that sees your screen, hears your calls, and feeds you answers — in real time

## Detectable by Design
<img width="818" alt="Screenshot 2025-06-29 at 12 52 01 PM" src="https://github.com/user-attachments/assets/5f222b62-d113-4543-8da9-e3e105d9558b" />


## What goes on under the hood
- **🚫 Screen Capture Evasion**: Windows configured with `sharing_state = 0` to avoid screen recording
- **🔼 Elevated Layer Positioning**: Windows using elevated display layers (e.g., `layer = 3`) to stay above screen capture

A CS:GO cheater would have had an easier time making a VAC bypass than this. Having your active process named "cluely" is like shouting out you're cheating.

## The detection

Available here [/src/lib.rs](https://github.com/terminalsin/no-cluely/blob/master/src/lib.rs)
```rust
let window_id = get_dict_int(window_dict, WINDOW_NUMBER);
let sharing_state = get_dict_int(window_dict, WINDOW_SHARING_STATE);
let layer = get_dict_int(window_dict, WINDOW_LAYER);

let window_info = WindowInfo {
    owner,
    window_id,
    sharing_state,
    layer,
};

result.is_detected = true;
result.window_count += 1;

// Check for specific evasion techniques
if sharing_state == 0 {
    result.screen_capture_evasion_count += 1;
}
```

# SDKs (Integrate detection in your app!)

This library provides SDKs for:
- [x] Python
- [ ] Java
- [ ] JavaScript/TypeScript
- [ ] Swift

## 🐍  Python
```bash
pip install no-cluely
```

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

## License

MIT License - See LICENSE file for details.
