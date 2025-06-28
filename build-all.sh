#!/bin/bash

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_section() {
    echo
    echo -e "${BLUE}=====================================${NC}"
    echo -e "${BLUE} $1${NC}"
    echo -e "${BLUE}=====================================${NC}"
}

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This build script only works on macOS (Cluely is macOS-specific)"
    exit 1
fi

# Parse command line arguments
BUILD_RUST=true
BUILD_CLI=true
BUILD_NODE=true
BUILD_PYTHON=true
BUILD_JAVA=true
BUILD_SWIFT=false
PACKAGE_ALL=true
CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-rust)
            BUILD_RUST=false
            shift
            ;;
        --no-cli)
            BUILD_CLI=false
            shift
            ;;
        --no-node)
            BUILD_NODE=false
            shift
            ;;
        --no-python)
            BUILD_PYTHON=false
            shift
            ;;
        --no-java)
            BUILD_JAVA=false
            shift
            ;;
        --no-swift)
            BUILD_SWIFT=false
            shift
            ;;
        --no-package)
            PACKAGE_ALL=false
            shift
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --only-*)
            # Reset all to false first
            BUILD_RUST=false
            BUILD_CLI=false
            BUILD_NODE=false
            BUILD_PYTHON=false
            BUILD_JAVA=false
            BUILD_SWIFT=false
            
            # Enable specific one
            case $1 in
                --only-rust) BUILD_RUST=true ;;
                --only-cli) BUILD_RUST=true; BUILD_CLI=true ;;
                --only-node) BUILD_RUST=true; BUILD_NODE=true ;;
                --only-python) BUILD_RUST=true; BUILD_PYTHON=true ;;
                --only-java) BUILD_RUST=true; BUILD_JAVA=true ;;
                --only-swift) BUILD_RUST=true; BUILD_SWIFT=true ;;
            esac
            shift
            ;;
        -h|--help)
            echo "Build script for No-Cluely Driver multi-language libraries"
            echo
            echo "Usage: $0 [OPTIONS]"
            echo
            echo "Options:"
            echo "  --no-rust        Skip Rust library build"
            echo "  --no-cli         Skip CLI application build"
            echo "  --no-node        Skip Node.js/TypeScript bindings"
            echo "  --no-python      Skip Python bindings"
            echo "  --no-java        Skip Java bindings"
            echo "  --no-swift       Skip Swift bindings"
            echo "  --no-package     Skip packaging step"
            echo "  --clean          Clean all build artifacts first"
            echo "  --only-rust      Build only Rust library"
            echo "  --only-cli       Build only CLI application"
            echo "  --only-node      Build only Node.js bindings"
            echo "  --only-python    Build only Python bindings"
            echo "  --only-java      Build only Java bindings"
            echo "  --only-swift     Build only Swift bindings"
            echo "  -h, --help       Show this help message"
            echo
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Clean build artifacts if requested
if [ "$CLEAN" = true ]; then
    print_section "Cleaning Build Artifacts"
    
    print_status "Cleaning Rust target directory..."
    cargo clean
    
    print_status "Cleaning CLI build..."
    [ -d "bindings/cli/target" ] && rm -rf bindings/cli/target
    
    print_status "Cleaning Node.js build..."
    [ -d "bindings/node/dist" ] && rm -rf bindings/node/dist
    [ -d "bindings/node/node_modules" ] && rm -rf bindings/node/node_modules
    
    print_status "Cleaning Python build..."
    [ -d "bindings/python/build" ] && rm -rf bindings/python/build
    [ -d "bindings/python/dist" ] && rm -rf bindings/python/dist
    [ -d "bindings/python/no_cluely_detector.egg-info" ] && rm -rf bindings/python/no_cluely_detector.egg-info
    
    print_status "Cleaning Java build..."
    [ -d "bindings/java/target" ] && rm -rf bindings/java/target
    
    print_status "Cleaning Swift build..."
    [ -d "bindings/swift/.build" ] && rm -rf bindings/swift/.build
    
    print_status "Cleaning packages directory..."
    [ -d "packages" ] && rm -rf packages
    
    print_success "Clean completed"
fi

# Create packages directory
mkdir -p packages

# 1. Build Rust Library
if [ "$BUILD_RUST" = true ]; then
    print_section "Building Rust Library"
    
    print_status "Building release version..."
    cargo build --lib --release
    
    # Copy to packages
    cp target/release/libno_cluely_driver.dylib packages/
    cp include/no_cluely_driver.h packages/
    
    print_success "Rust library built successfully"
fi

# 2. Build CLI Application
if [ "$BUILD_CLI" = true ]; then
    print_section "Building CLI Application"
    
    cd bindings/cli
    
    print_status "Building CLI with Cargo..."
    cargo build --release
    
    # Copy to packages
    cp target/release/cluely-detector ../../packages/
    
    cd ../..
    
    print_success "CLI application built successfully"
fi

# 3. Build Node.js/TypeScript Bindings
if [ "$BUILD_NODE" = true ]; then
    print_section "Building Node.js/TypeScript Bindings"
    
    cd bindings/node
    
    # Check if Node.js is available
    if ! command -v node &> /dev/null; then
        print_warning "Node.js not found, skipping Node.js bindings"
    elif ! command -v npm &> /dev/null; then
        print_warning "npm not found, skipping Node.js bindings"
    else
        print_status "Installing dependencies..."
        npm install
        
        print_status "Building TypeScript..."
        npm run build
        
        print_status "Creating package..."
        npm pack
        
        # Copy to packages
        cp *.tgz ../../packages/
        
        print_success "Node.js bindings built successfully"
    fi
    
    cd ../..
fi

# 4. Build Python Bindings
if [ "$BUILD_PYTHON" = true ]; then
    print_section "Building Python Bindings"
    
    cd bindings/python
    
    # Check if Python is available
    if ! command -v python3 &> /dev/null; then
        print_warning "Python 3 not found, skipping Python bindings"
    else
        print_status "Building Python package..."
        
        # Copy the built library to the Python package directory if it doesn't exist
        if [ ! -f "../../target/release/libno_cluely_driver.dylib" ]; then
            print_error "Rust library not found. Build Rust library first."
            exit 1
        fi
        
        # Check if library already exists in Python package
        if [ ! -f "libno_cluely_driver.dylib" ]; then
            print_status "Copying Rust library to Python package..."
            cp ../../target/release/libno_cluely_driver.dylib .
        fi
        
        # Install build dependencies
        python3 -m pip install --upgrade build
        
        # Build using modern pyproject.toml approach
        python3 -m build
        
        # Copy to packages
        cp dist/* ../../packages/
        
        print_success "Python bindings built successfully"
    fi
    
    cd ../..
fi

# 5. Build Java Bindings
if [ "$BUILD_JAVA" = true ]; then
    print_section "Building Java Bindings"
    
    cd bindings/java
    
    # Check if Maven is available
    if ! command -v mvn &> /dev/null; then
        print_warning "Maven not found, skipping Java bindings"
    else
        print_status "Building with Maven..."
        mvn clean package
        
        # Copy to packages
        cp target/*.jar ../../packages/
        
        print_success "Java bindings built successfully"
    fi
    
    cd ../..
fi

# 6. Build Swift Package
if [ "$BUILD_SWIFT" = true ]; then
    print_section "Building Swift Package"
    
    cd bindings/swift
    
    # Check if Swift is available
    if ! command -v swift &> /dev/null; then
        print_warning "Swift not found, skipping Swift bindings"
    else
        print_status "Building Swift package..."
        swift build -c release
        
        print_status "Testing Swift package..."
        swift test
        
        print_success "Swift package built successfully"
    fi
    
    cd ../..
fi

# 7. Package Everything
if [ "$PACKAGE_ALL" = true ]; then
    print_section "Creating Distribution Packages"
    
    # Create distribution structure
    DIST_DIR="packages/no-cluely-driver-1.0.0"
    mkdir -p "$DIST_DIR"/{rust,cli,node,python,java,swift,c}
    
    # Copy Rust library and headers
    print_status "Packaging Rust library..."
    cp target/release/libno_cluely_driver.dylib "$DIST_DIR/rust/"
    cp include/no_cluely_driver.h "$DIST_DIR/rust/"
    cp Cargo.toml "$DIST_DIR/rust/"
    cp -r src "$DIST_DIR/rust/"
    
    # Copy CLI
    if [ -f "packages/cluely-detector" ]; then
        print_status "Packaging CLI application..."
        cp packages/cluely-detector "$DIST_DIR/cli/"
        cp bindings/cli/README.md "$DIST_DIR/cli/"
    fi
    
    # Copy Node.js package
    if ls packages/*.tgz 1> /dev/null 2>&1; then
        print_status "Packaging Node.js bindings..."
        cp packages/*.tgz "$DIST_DIR/node/"
        cp bindings/node/README.md "$DIST_DIR/node/"
        cp bindings/node/package.json "$DIST_DIR/node/"
    fi
    
    # Copy Python packages
    if ls packages/*.whl 1> /dev/null 2>&1 || ls packages/*.tar.gz 1> /dev/null 2>&1; then
        print_status "Packaging Python bindings..."
        [ -f packages/*.whl ] && cp packages/*.whl "$DIST_DIR/python/"
        [ -f packages/*.tar.gz ] && cp packages/*.tar.gz "$DIST_DIR/python/"
        cp bindings/python/README.md "$DIST_DIR/python/"
        cp bindings/python/pyproject.toml "$DIST_DIR/python/"
    fi
    
    # Copy Java JARs
    if ls packages/*.jar 1> /dev/null 2>&1; then
        print_status "Packaging Java bindings..."
        cp packages/*.jar "$DIST_DIR/java/"
        cp bindings/java/README.md "$DIST_DIR/java/"
        cp bindings/java/pom.xml "$DIST_DIR/java/"
    fi
    
    # Copy Swift package files
    if [ -d "bindings/swift" ]; then
        print_status "Packaging Swift bindings..."
        cp bindings/swift/Package.swift "$DIST_DIR/swift/"
        cp -r bindings/swift/Sources "$DIST_DIR/swift/"
        cp -r bindings/swift/Tests "$DIST_DIR/swift/" 2>/dev/null || true
    fi
    
    # Copy C headers
    print_status "Packaging C headers..."
    cp include/no_cluely_driver.h "$DIST_DIR/c/"
    cp packages/libno_cluely_driver.dylib "$DIST_DIR/c/"
    
    # Copy documentation
    cp README.md "$DIST_DIR/"
    cp install.sh "$DIST_DIR/"
    
    # Create installation guide
    cat > "$DIST_DIR/INSTALLATION.md" << 'EOF'
# Installation Guide

This package contains multi-language bindings for the No-Cluely Driver library.

## CLI Application
```bash
# Copy the binary to your PATH
cp cli/cluely-detector /usr/local/bin/
chmod +x /usr/local/bin/cluely-detector
```

## Node.js/TypeScript
```bash
cd node/
npm install *.tgz
```

## Python
```bash
cd python/
pip install *.whl
# or
pip install *.tar.gz
```

## Java
```bash
# Install the JAR to your local Maven repository
mvn install:install-file -Dfile=java/cluely-detector-1.0.0.jar \
  -DgroupId=com.nocluely -DartifactId=cluely-detector -Dversion=1.0.0 -Dpackaging=jar
```

## Swift
```bash
# Add to your Package.swift dependencies:
.package(path: "./swift")
```

## C/C++
```bash
# Copy library and headers
cp c/libno_cluely_driver.dylib /usr/local/lib/
cp c/no_cluely_driver.h /usr/local/include/
```

For detailed usage instructions, see the README.md files in each language directory.
EOF
    
    # Create archive
    print_status "Creating distribution archive..."
    cd packages
    tar -czf "no-cluely-driver-1.0.0-macos.tar.gz" "no-cluely-driver-1.0.0"
    cd ..
    
    print_success "Distribution package created: packages/no-cluely-driver-1.0.0-macos.tar.gz"
fi

# Summary
print_section "Build Summary"

echo -e "${GREEN}✅ Build completed successfully!${NC}"
echo
echo "Built components:"
[ "$BUILD_RUST" = true ] && echo "  • Rust library (libno_cluely_driver.dylib)"
[ "$BUILD_CLI" = true ] && echo "  • CLI application (cluely-detector)"
[ "$BUILD_NODE" = true ] && echo "  • Node.js/TypeScript bindings"
[ "$BUILD_PYTHON" = true ] && echo "  • Python bindings"
[ "$BUILD_JAVA" = true ] && echo "  • Java bindings"
[ "$BUILD_SWIFT" = true ] && echo "  • Swift package"

echo
echo "Output directory: $(pwd)/packages"

if [ "$PACKAGE_ALL" = true ]; then
    echo "Distribution archive: packages/no-cluely-driver-1.0.0-macos.tar.gz"
fi

echo
echo -e "${BLUE}Quick Test:${NC}"
echo "  ./packages/cluely-detector check"
echo
echo -e "${BLUE}Documentation:${NC}"
echo "  README.md files in bindings/{cli,node,python,java,swift}/"
echo
echo -e "${GREEN}🎯 Happy Cluely detection!${NC}" 