[![Untitled drawing (5)](https://github.com/user-attachments/assets/6a3730e3-5d5e-4d6a-b486-58d74307a31d)](https://nocluely.app)

# NoCluely

Cluely is an ~~undetectable~~ AI that sees your screen, hears your calls, and
feeds you answers — in real time. NoCluely helps YOU not rot your brain by
obsessively and blindly following AI. See:

- [AI Tools in Society: Impacts on Cognitive Offloading and the Future of Critical Thinking
  (MDPI.com)](https://www.mdpi.com/2075-4698/15/1/6)
- [Your Brain on ChatGPT: Accumulation of Cognitive Debt when Using an AI Assistant for Essay Writing Task (MIT)](https://arxiv.org/abs/2506.08872)
- [Is AI making us dumb? (TechCrunch)](https://techcrunch.com/2025/02/10/is-ai-making-us-dumb/)

But to be fair, I am a hypocrite. AI has assisted me in every step of creating
this project. I'm just really doing this for the memes. Cluely is impressive in
its own right, with its ability to consistently go viral. I'll bite and
piggyback on it. Make me viral, Cluely.

### Table of Contents:

- [NoCluely](#nocluely)
  - [Table of Contents:](#table-of-contents)
- [Detectable by Design](#detectable-by-design)
  - [What goes on under the hood](#what-goes-on-under-the-hood)
  - [The detection](#the-detection)
- [SDKs (Integrate detection in your app!)](#sdks-integrate-detection-in-your-app)
  - [🐍 Python](#--python)
    - [Simple Detection](#simple-detection)
    - [Detailed Analysis](#detailed-analysis)
  - [🎯 NodeJS/Typescript/JavaScript](#-nodejstypescriptjavascript)
    - [TypeScript/ES Modules](#typescriptes-modules)
    - [CommonJS/Node.js](#commonjsnodejs)
  - [🦀 Rust](#-rust)
    - [Basic Usage](#basic-usage)
- [License](#license)

# Detectable by Design

<img width="818" alt="Screenshot 2025-06-29 at 12 52 01 PM" src="https://github.com/user-attachments/assets/5f222b62-d113-4543-8da9-e3e105d9558b" />

## What goes on under the hood

- **🚫 Screen Capture Evasion**: Windows configured with `sharing_state = 0` to
  avoid screen recording
- **🔼 Elevated Layer Positioning**: Windows using elevated display layers
  (e.g., `layer = 3`) to stay above screen capture

A CS:GO cheater would have had an easier time making a VAC bypass than this.
Having your active process named "cluely" is like shouting out you're cheating.

## The detection

Available here
[/src/lib.rs](https://github.com/terminalsin/no-cluely/blob/master/src/lib.rs)

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
- [x] JavaScript/TypeScript
- [x] Rust
- [ ] Swift

## 🐍 Python

[![PyPI - Version](https://img.shields.io/pypi/v/no-cluely?style=for-the-badge&labelColor=green&color=gray)](https://pypi.org/project/no-cluely/)

NoCluely provides an SDK binding for python for you to integrate this with your
desktop apps! Available on PyPI here: https://pypi.org/project/no-cluely/

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

## 🎯 NodeJS/Typescript/JavaScript

[![NPM Version](https://img.shields.io/npm/v/no-cluely?style=for-the-badge&labelColor=red&color=gray)](https://www.npmjs.com/package/no-cluely)

NoCluely is also incredibly generous in its SDK offering. TypeScript! This means
integration with electronjs, etc. Whatever framework you use for your ChatGPT
browser wrapper in a desktop app, we support it (maybe, MacOS only). Available
on NPMjs here: https://www.npmjs.com/package/no-cluely

```bash
npm install no-cluely
```

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

## 🦀 Rust

[![Crates Version](https://img.shields.io/crates/v/no-cluely-driver?style=for-the-badge&labelColor=orange&color=gray)](https://crates.io/crates/no-cluely-driver)

For our wonderful community of low-level people, for which the basis of this
driver is made from (everything else is a wrapper, I admit), we provide the
driver on crates.io. It is available here:
https://crates.io/crates/no-cluely-driver

```
cargo install no-cluely-driver
```

### Basic Usage

```rust
fn cmd_check() {
    println!("{}", "🎯 Cluely Detection".bold().blue());
    println!("{}", "=================".blue());
    println!();

    let result = detect_cluely();
    
    if result.is_detected {
        println!("{}", "🚨 CLUELY DETECTED".bold().red());
        println!("{}", "Employee monitoring software is running on this system.".red());
        println!();
        println!("{}", "💡 Use 'cluely-detector report' for detailed analysis".yellow());
        process::exit(1);
    } else {
        println!("{}", "✅ NO CLUELY DETECTED".bold().green());
        println!("{}", "No employee monitoring software found.".green());
        process::exit(0);
    }
}
```

# License

MIT License - See LICENSE file for details.
