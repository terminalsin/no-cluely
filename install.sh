#!/bin/bash

echo "🎯 No-Cluely Driver Installation Script"
echo "======================================="
echo ""

# Build the library
echo "📦 Building library..."
cargo build --lib --release

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build successful!"
echo ""

# Create output directory
OUTPUT_DIR="./swift-integration"
mkdir -p "$OUTPUT_DIR"

# Copy files needed for Swift integration
echo "📋 Preparing Swift integration files..."

# Copy the dynamic library
cp target/release/libno_cluely_driver.dylib "$OUTPUT_DIR/"

# Copy the header file
cp include/no_cluely_driver.h "$OUTPUT_DIR/"

# Copy the Swift wrapper
cp example/ClueLyDetector.swift "$OUTPUT_DIR/"

# Create a quick integration guide
cat > "$OUTPUT_DIR/INTEGRATION.md" << 'EOF'
# Quick Integration Guide

## Files in this directory:
- `libno_cluely_driver.dylib` - The compiled library
- `no_cluely_driver.h` - C header file
- `ClueLyDetector.swift` - Swift wrapper class

## To integrate into your Xcode project:

1. **Add the library**:
   - Drag `libno_cluely_driver.dylib` into your Xcode project
   - Make sure it's added to "Copy Bundle Resources" in Build Phases

2. **Add the header**:
   - Add `no_cluely_driver.h` to your project
   - If using Objective-C bridging header, add: `#import "no_cluely_driver.h"`

3. **Add the Swift code**:
   - Copy `ClueLyDetector.swift` to your project

4. **Use it**:
   ```swift
   if ClueLyDetector.isClueLyRunning() {
       print("⚠️ Employee monitoring detected!")
   }
   ```

That's it! 🎉
EOF

echo "✅ Integration files ready in: $OUTPUT_DIR"
echo ""

# Test the library
echo "🧪 Testing library..."
clang -o test_new test_new.c -L./target/release -lno_cluely_driver -rpath ./target/release
./test_new
echo ""

# Show final instructions
echo "🎉 Installation Complete!"
echo "========================"
echo ""
echo "📁 Integration files are in: $OUTPUT_DIR"
echo "📖 Read: $OUTPUT_DIR/INTEGRATION.md for setup instructions"
echo ""
echo "🚀 Quick test in Swift:"
echo "   let detected = ClueLyDetector.isClueLyRunning()"
echo "   print(\"Cluely detected: \\(detected)\")"
echo ""
echo "Happy coding! 🎯" 