use std::collections::{HashMap, HashSet};
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_void};
use std::ptr;

// Core Graphics and Core Foundation bindings
#[link(name = "CoreGraphics", kind = "framework")]
#[link(name = "CoreFoundation", kind = "framework")]
#[link(name = "ApplicationServices", kind = "framework")]
extern "C" {
    // Core Graphics Window List functions
    fn CGWindowListCopyWindowInfo(option: u32, relative_window_id: u32) -> *const c_void;

    // Core Foundation functions
    fn CFArrayGetCount(array: *const c_void) -> isize;
    fn CFArrayGetValueAtIndex(array: *const c_void, index: isize) -> *const c_void;
    fn CFDictionaryGetValue(dict: *const c_void, key: *const c_void) -> *const c_void;
    fn CFStringCreateWithCString(
        allocator: *const c_void,
        c_str: *const c_char,
        encoding: u32,
    ) -> *const c_void;
    fn CFStringGetCStringPtr(string: *const c_void, encoding: u32) -> *const c_char;
    fn CFStringGetCString(
        string: *const c_void,
        buffer: *mut c_char,
        buffer_size: isize,
        encoding: u32,
    ) -> bool;
    fn CFNumberGetValue(number: *const c_void, number_type: c_int, value_ptr: *mut c_void) -> bool;
    fn CFRelease(cf_type: *const c_void);
    fn CFGetTypeID(cf_type: *const c_void) -> usize;
    fn CFStringGetTypeID() -> usize;
    fn CFNumberGetTypeID() -> usize;
    fn CFBooleanGetValue(boolean: *const c_void) -> bool;
    fn CFBooleanGetTypeID() -> usize;
}

// Constants
const K_CG_WINDOW_LIST_OPTION_ALL: u32 = 0;
const K_CF_STRING_ENCODING_UTF8: u32 = 0x08000100;
const K_CF_NUMBER_INT_TYPE: c_int = 9;

// Window property keys
const WINDOW_NAME: &str = "kCGWindowName";
const WINDOW_OWNER_NAME: &str = "kCGWindowOwnerName";
const WINDOW_NUMBER: &str = "kCGWindowNumber";
const WINDOW_LAYER: &str = "kCGWindowLayer";
const WINDOW_IS_ONSCREEN: &str = "kCGWindowIsOnscreen";
const WINDOW_ALPHA: &str = "kCGWindowAlpha";
const WINDOW_BOUNDS: &str = "kCGWindowBounds";
const WINDOW_SHARING_STATE: &str = "kCGWindowSharingState";
const WINDOW_STORE_TYPE: &str = "kCGWindowStoreType";
const WINDOW_BACKING_TYPE: &str = "kCGWindowBackingType";

#[derive(Debug)]
struct WindowInfo {
    name: String,
    owner: String,
    window_id: i32,
    layer: i32,
    is_onscreen: bool,
    alpha: f64,
    is_hidden: bool,
    sharing_state: i32,
    store_type: i32,
    backing_type: i32,
    bounds: HashMap<String, f64>,
}

fn create_cfstring(s: &str) -> *const c_void {
    let c_str = CString::new(s).unwrap();
    unsafe { CFStringCreateWithCString(ptr::null(), c_str.as_ptr(), K_CF_STRING_ENCODING_UTF8) }
}

fn cfstring_to_string(cf_string: *const c_void) -> String {
    if cf_string.is_null() {
        return String::new();
    }

    unsafe {
        let c_str_ptr = CFStringGetCStringPtr(cf_string, K_CF_STRING_ENCODING_UTF8);
        if !c_str_ptr.is_null() {
            return CStr::from_ptr(c_str_ptr).to_string_lossy().into_owned();
        }

        let mut buffer = vec![0u8; 1024];
        let success = CFStringGetCString(
            cf_string,
            buffer.as_mut_ptr() as *mut c_char,
            buffer.len() as isize,
            K_CF_STRING_ENCODING_UTF8,
        );

        if success {
            let c_str = CStr::from_ptr(buffer.as_ptr() as *const c_char);
            c_str.to_string_lossy().into_owned()
        } else {
            String::new()
        }
    }
}

fn get_dict_string(dict: *const c_void, key: &str) -> String {
    unsafe {
        let cf_key = create_cfstring(key);
        let value = CFDictionaryGetValue(dict, cf_key);
        CFRelease(cf_key);

        if value.is_null() {
            return String::new();
        }

        if CFGetTypeID(value) == CFStringGetTypeID() {
            cfstring_to_string(value)
        } else {
            String::new()
        }
    }
}

fn get_dict_int(dict: *const c_void, key: &str) -> i32 {
    unsafe {
        let cf_key = create_cfstring(key);
        let value = CFDictionaryGetValue(dict, cf_key);
        CFRelease(cf_key);

        if value.is_null() {
            return 0;
        }

        if CFGetTypeID(value) == CFNumberGetTypeID() {
            let mut result: i32 = 0;
            CFNumberGetValue(
                value,
                K_CF_NUMBER_INT_TYPE,
                &mut result as *mut i32 as *mut c_void,
            );
            result
        } else {
            0
        }
    }
}

fn get_dict_bool(dict: *const c_void, key: &str) -> bool {
    unsafe {
        let cf_key = create_cfstring(key);
        let value = CFDictionaryGetValue(dict, cf_key);
        CFRelease(cf_key);

        if value.is_null() {
            return false;
        }

        if CFGetTypeID(value) == CFBooleanGetTypeID() {
            CFBooleanGetValue(value)
        } else {
            false
        }
    }
}

fn get_dict_float(dict: *const c_void, key: &str) -> f64 {
    unsafe {
        let cf_key = create_cfstring(key);
        let value = CFDictionaryGetValue(dict, cf_key);
        CFRelease(cf_key);

        if value.is_null() {
            return 0.0;
        }

        if CFGetTypeID(value) == CFNumberGetTypeID() {
            let mut result: f64 = 0.0;
            CFNumberGetValue(value, 6, &mut result as *mut f64 as *mut c_void);
            result
        } else {
            0.0
        }
    }
}

fn get_window_bounds(dict: *const c_void) -> HashMap<String, f64> {
    let mut bounds = HashMap::new();
    unsafe {
        let cf_key = create_cfstring(WINDOW_BOUNDS);
        let bounds_dict = CFDictionaryGetValue(dict, cf_key);
        CFRelease(cf_key);

        if !bounds_dict.is_null() {
            bounds.insert("X".to_string(), get_dict_float(bounds_dict, "X"));
            bounds.insert("Y".to_string(), get_dict_float(bounds_dict, "Y"));
            bounds.insert("Width".to_string(), get_dict_float(bounds_dict, "Width"));
            bounds.insert("Height".to_string(), get_dict_float(bounds_dict, "Height"));
        }
    }
    bounds
}

// Detect Cluely's screen sharing evasion techniques
fn detect_screen_sharing_evasion(window: &WindowInfo) -> Vec<String> {
    let mut evasion_techniques = Vec::new();

    // Special handling for Cluely - it's inherently designed for monitoring/evasion
    if is_cluely_related(window) {
        evasion_techniques.push("Cluely employee monitoring software detected".to_string());

        // Check for additional Cluely-specific techniques
        if window.sharing_state == 0 {
            evasion_techniques.push("Cluely window configured to avoid screen capture".to_string());
        }
        if window.layer > 0 {
            evasion_techniques.push(format!(
                "Cluely using elevated window layer: {}",
                window.layer
            ));
        }
        return evasion_techniques;
    }

    // For non-Cluely processes, use conservative detection
    // 1. Off-screen positioning trick (common evasion technique)
    if let (Some(&x), Some(&y)) = (window.bounds.get("X"), window.bounds.get("Y")) {
        // Only flag truly extreme off-screen positioning (not just secondary monitor positioning)
        if x < -50000.0 || y < -50000.0 || x > 50000.0 || y > 50000.0 {
            evasion_techniques.push("Extreme off-screen positioning detected".to_string());
        }
    }

    // 2. Zero-dimension windows that should have content
    if let (Some(&width), Some(&height)) = (window.bounds.get("Width"), window.bounds.get("Height"))
    {
        if (width == 0.0 || height == 0.0)
            && window.is_onscreen
            && !window.name.is_empty()
            && window.name != "<No Title>"
        {
            evasion_techniques.push("Named window with zero dimensions".to_string());
        }

        // 3. Sub-pixel dimensions for named windows (suspicious for content windows)
        if (width > 0.0 && width < 1.0) || (height > 0.0 && height < 1.0) {
            if !window.name.is_empty() && window.name != "<No Title>" && !is_system_window(window) {
                evasion_techniques.push("Sub-pixel dimensions for content window".to_string());
            }
        }
    }

    // 4. Layer manipulation - only flag extreme cases that are clearly evasive
    if window.layer < -100000 && !is_system_background_window(window) {
        evasion_techniques.push("Extremely deep layer positioning".to_string());
    }

    // 5. Detect windows that are trying to be invisible during screen sharing
    if window.name.to_lowercase().contains("hidden")
        || window.name.to_lowercase().contains("invisible")
        || window.name.to_lowercase().contains("stealth")
    {
        evasion_techniques.push("Explicitly hidden/stealth window".to_string());
    }

    // 6. Detect apps that have suspiciously transparent windows
    if window.is_onscreen
        && window.alpha < 0.01
        && !window.name.is_empty()
        && window.name != "<No Title>"
    {
        evasion_techniques.push("Nearly invisible content window".to_string());
    }

    evasion_techniques
}

// Helper function to identify system windows that normally have sharing_state 0
fn is_system_window(window: &WindowInfo) -> bool {
    let system_processes = [
        "Window Server",
        "Dock",
        "SystemUIServer",
        "Control Center",
        "Spotlight",
        "Notification Center",
        "loginwindow",
        "Finder",
        "TextInputMenuAgent",
        "Universal Control",
        "CursorUIViewService",
        "Open and Save Panel Service",
        "Accessibility",
        "Wi-Fi",
        "Displays",
        "Wallpaper",
    ];

    system_processes
        .iter()
        .any(|&process| window.owner.contains(process))
        || window.name == "Menubar"
        || window.layer >= 20 // Menu bar and overlay layers
}

// Helper function to identify background/wallpaper windows
fn is_system_background_window(window: &WindowInfo) -> bool {
    window.name.contains("Wallpaper") ||
    window.owner == "Dock" ||
    window.owner.contains("Wallpaper") ||
    (window.owner == "Window Server" && window.layer < -1000000) ||
    // Finder often manages the desktop background with very deep layers
    (window.owner == "Finder" && window.layer < -1000000 && 
     window.bounds.get("X").unwrap_or(&-1.0) == &0.0 && 
     window.bounds.get("Y").unwrap_or(&-1.0) == &0.0)
}

fn is_cluely_related(window: &WindowInfo) -> bool {
    let name_lower = window.name.to_lowercase();
    let owner_lower = window.owner.to_lowercase();

    // More specific Cluely detection - only flag actual Cluely processes
    // Exclude our own detection tool
    if owner_lower.contains("no-cluely") || name_lower.contains("no-cluely") {
        return false;
    }

    // Look for actual Cluely processes
    name_lower.contains("cluely") ||
    owner_lower.contains("cluely") ||
    name_lower.contains("clue.ly") ||
    owner_lower.contains("clue.ly") ||
    owner_lower.contains("com.cluely") ||
    owner_lower.contains("io.cluely") ||
    owner_lower.contains("co.cluely") ||
    // Be more specific about these generic terms
    (owner_lower.contains("cluely helper") || owner_lower.contains("cluely agent")) ||
    // Only flag productivity + clue if it's very specific
    (name_lower == "productivity monitor" && owner_lower.contains("clue"))
}

fn analyze_window_set(windows: &[WindowInfo]) -> Vec<String> {
    let mut analysis = Vec::new();

    let total_windows = windows.len();
    let hidden_count = windows.iter().filter(|w| w.is_hidden).count();

    // Only flag if the hidden ratio is extremely high (macOS systems have many legitimate hidden windows)
    // Increase threshold to be more conservative
    if hidden_count as f64 / total_windows as f64 > 0.85 {
        analysis.push("Extremely high ratio of hidden windows detected".to_string());
    }

    // Look for coordinated window manipulation, but be more conservative
    let mut same_owner_groups: HashMap<String, usize> = HashMap::new();
    for window in windows {
        if !window.owner.is_empty() && !is_system_window(window) {
            *same_owner_groups.entry(window.owner.clone()).or_insert(0) += 1;
        }
    }

    // Only flag non-system processes with very high window counts
    // Increase threshold to reduce false positives
    for (owner, count) in same_owner_groups {
        if count > 20 &&
           !owner.contains("com.apple") && 
           !owner.contains("Apple") &&
           !owner.contains("Messages") && // Messages legitimately creates multiple conversation windows
           !owner.contains("Chrome")
        {
            // Chrome legitimately creates many tab windows
            analysis.push(format!("Suspicious multi-window pattern from: {}", owner));
        }
    }

    analysis
}

fn detect_all_windows() -> Vec<WindowInfo> {
    let mut all_windows = Vec::new();

    unsafe {
        let window_list = CGWindowListCopyWindowInfo(K_CG_WINDOW_LIST_OPTION_ALL, 0);

        if window_list.is_null() {
            eprintln!("Failed to get window list");
            return all_windows;
        }

        let count = CFArrayGetCount(window_list);

        for i in 0..count {
            let window_dict = CFArrayGetValueAtIndex(window_list, i);
            if window_dict.is_null() {
                continue;
            }

            let name = get_dict_string(window_dict, WINDOW_NAME);
            let owner = get_dict_string(window_dict, WINDOW_OWNER_NAME);
            let window_id = get_dict_int(window_dict, WINDOW_NUMBER);
            let layer = get_dict_int(window_dict, WINDOW_LAYER);
            let is_onscreen = get_dict_bool(window_dict, WINDOW_IS_ONSCREEN);
            let alpha = get_dict_float(window_dict, WINDOW_ALPHA);
            let sharing_state = get_dict_int(window_dict, WINDOW_SHARING_STATE);
            let store_type = get_dict_int(window_dict, WINDOW_STORE_TYPE);
            let backing_type = get_dict_int(window_dict, WINDOW_BACKING_TYPE);
            let bounds = get_window_bounds(window_dict);

            let is_hidden = !is_onscreen || alpha < 0.1 || layer < 0;

            all_windows.push(WindowInfo {
                name: if name.is_empty() {
                    "<No Title>".to_string()
                } else {
                    name
                },
                owner,
                window_id,
                layer,
                is_onscreen,
                alpha,
                is_hidden,
                sharing_state,
                store_type,
                backing_type,
                bounds,
            });
        }

        CFRelease(window_list);
    }

    all_windows
}

fn main() {
    println!("🎯 Cluely Screen Sharing Evasion Detector");
    println!("=========================================\n");

    let windows = detect_all_windows();

    println!("🔍 SCANNING FOR SCREEN SHARING EVASION TECHNIQUES:");
    println!("--------------------------------------------------");

    let mut cluely_detected = false;
    let mut evasion_detected = false;

    for window in &windows {
        let evasion_techniques = detect_screen_sharing_evasion(window);
        let is_cluely = is_cluely_related(window);

        if !evasion_techniques.is_empty() {
            evasion_detected = true;

            if is_cluely {
                cluely_detected = true;
                println!("🚨 CLUELY EVASION DETECTED:");
            } else {
                println!("⚠️  Screen sharing evasion detected:");
            }

            println!("   Window: {} [{}]", window.name, window.owner);
            println!("   Window ID: {}", window.window_id);
            println!("   Techniques used:");
            for technique in evasion_techniques {
                println!("     • {}", technique);
            }

            println!("   Technical details:");
            println!("     - Sharing State: {}", window.sharing_state);
            println!("     - Backing Type: {}", window.backing_type);
            println!("     - Layer: {}", window.layer);
            println!("     - Alpha: {:.3}", window.alpha);
            if let (Some(&x), Some(&y), Some(&w), Some(&h)) = (
                window.bounds.get("X"),
                window.bounds.get("Y"),
                window.bounds.get("Width"),
                window.bounds.get("Height"),
            ) {
                println!("     - Bounds: ({:.1}, {:.1}) {}x{}", x, y, w, h);
            }
            println!();
        }
    }

    if !evasion_detected {
        println!("✅ No screen sharing evasion techniques detected");
    }

    // Add debug output to show all potential Cluely-related processes
    println!("\n🔍 DEBUG: ALL NON-SYSTEM PROCESSES:");
    println!("----------------------------------");
    let mut seen_owners = HashSet::new();
    for window in &windows {
        if !is_system_window(window)
            && !window.owner.is_empty()
            && seen_owners.insert(window.owner.clone())
        {
            println!("📱 Process: {}", window.owner);
        }
    }

    // Show potentially suspicious windows
    println!("\n🔍 DEBUG: POTENTIALLY SUSPICIOUS WINDOWS:");
    println!("------------------------------------------");
    for window in &windows {
        if !is_system_window(window)
            && (window.sharing_state == 0 || window.alpha < 0.5 || window.layer < 0)
        {
            println!("🤔 Window: {} [{}]", window.name, window.owner);
            println!(
                "   - Sharing State: {}, Alpha: {:.3}, Layer: {}",
                window.sharing_state, window.alpha, window.layer
            );
            if let (Some(&x), Some(&y), Some(&w), Some(&h)) = (
                window.bounds.get("X"),
                window.bounds.get("Y"),
                window.bounds.get("Width"),
                window.bounds.get("Height"),
            ) {
                println!("   - Bounds: ({:.1}, {:.1}) {}x{}", x, y, w, h);
            }
            println!();
        }
    }

    println!("🔬 SYSTEM-WIDE ANALYSIS:");
    println!("------------------------");

    let analysis_results = analyze_window_set(&windows);
    for result in analysis_results {
        println!("📊 {}", result);
    }

    println!("\n📋 DETECTION SUMMARY:");
    println!("--------------------");
    println!("Total windows analyzed: {}", windows.len());
    println!(
        "Screen sharing evasion detected: {}",
        if evasion_detected { "YES" } else { "NO" }
    );
    println!(
        "Cluely specifically detected: {}",
        if cluely_detected { "YES" } else { "NO" }
    );

    if cluely_detected {
        println!("\n🚨 CLUELY DETECTION CONFIRMED");
        println!("=============================");
        println!("Cluely is actively using screen sharing evasion techniques.");
        println!("This software is designed to hide from screen recording and sharing.");
        println!("It may be monitoring your activity while remaining invisible during calls.");
        println!("\nRecommended actions:");
        println!("• Check Activity Monitor for Cluely processes");
        println!("• Review System Preferences > Security & Privacy > Screen Recording");
        println!("• Consider discussing with your employer about monitoring policies");
    }
}
