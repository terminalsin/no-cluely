use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_void};
use std::ptr;

// Core Graphics and Core Foundation bindings
#[link(name = "CoreGraphics", kind = "framework")]
#[link(name = "CoreFoundation", kind = "framework")]
#[link(name = "ApplicationServices", kind = "framework")]
extern "C" {
    fn CGWindowListCopyWindowInfo(option: u32, relative_window_id: u32) -> *const c_void;
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
}

// Constants
const K_CG_WINDOW_LIST_OPTION_ALL: u32 = 0;
const K_CF_STRING_ENCODING_UTF8: u32 = 0x08000100;
const K_CF_NUMBER_INT_TYPE: c_int = 9;
const WINDOW_OWNER_NAME: &str = "kCGWindowOwnerName";
const WINDOW_SHARING_STATE: &str = "kCGWindowSharingState";
const WINDOW_LAYER: &str = "kCGWindowLayer";
const WINDOW_NUMBER: &str = "kCGWindowNumber";

/// Detailed detection result with evasion techniques
#[repr(C)]
#[derive(Debug, Clone, Copy)]
pub struct ClueLyDetectionResult {
    pub is_detected: bool,
    pub window_count: u32,
    pub screen_capture_evasion_count: u32,  // Windows avoiding screen capture
    pub elevated_layer_count: u32,          // Windows using elevated layers
    pub max_layer_detected: i32,            // Highest layer number found
}

/// Window information for detailed analysis
#[derive(Debug)]
struct WindowInfo {
    owner: String,
    window_id: i32,
    sharing_state: i32,
    layer: i32,
}

fn create_cfstring(s: &str) -> *const c_void {
    let c_str = CString::new(s).unwrap();
    unsafe {
        CFStringCreateWithCString(
            ptr::null(),
            c_str.as_ptr(),
            K_CF_STRING_ENCODING_UTF8,
        )
    }
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
            CFNumberGetValue(value, K_CF_NUMBER_INT_TYPE, &mut result as *mut i32 as *mut c_void);
            result
        } else {
            0
        }
    }
}

fn is_cluely_process(owner: &str) -> bool {
    let owner_lower = owner.to_lowercase();
    
    // Exclude our own detection tool
    if owner_lower.contains("no-cluely") {
        return false;
    }
    
    // Look for actual Cluely processes
    owner_lower.contains("cluely") ||
    owner_lower.contains("clue.ly") ||
    owner_lower.contains("com.cluely") ||
    owner_lower.contains("io.cluely") ||
    owner_lower.contains("co.cluely")
}

fn analyze_cluely_windows() -> (Vec<WindowInfo>, ClueLyDetectionResult) {
    let mut cluely_windows = Vec::new();
    let mut result = ClueLyDetectionResult {
        is_detected: false,
        window_count: 0,
        screen_capture_evasion_count: 0,
        elevated_layer_count: 0,
        max_layer_detected: 0,
    };
    
    unsafe {
        let window_list = CGWindowListCopyWindowInfo(K_CG_WINDOW_LIST_OPTION_ALL, 0);
        
        if window_list.is_null() {
            return (cluely_windows, result);
        }
        
        let count = CFArrayGetCount(window_list);
        
        for i in 0..count {
            let window_dict = CFArrayGetValueAtIndex(window_list, i);
            if window_dict.is_null() {
                continue;
            }
            
            let owner = get_dict_string(window_dict, WINDOW_OWNER_NAME);
            if is_cluely_process(&owner) {
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
                
                if layer > 0 {
                    result.elevated_layer_count += 1;
                    if layer > result.max_layer_detected {
                        result.max_layer_detected = layer;
                    }
                }
                
                cluely_windows.push(window_info);
            }
        }
        
        CFRelease(window_list);
    }
    
    (cluely_windows, result)
}

/// Main detection function - returns detailed result
/// This is the primary Rust API for detection
pub fn detect_cluely_rust() -> ClueLyDetectionResult {
    let (_, result) = analyze_cluely_windows();
    result
}

/// Simple boolean check function for Rust API
pub fn is_cluely_running_rust() -> bool {
    let result = detect_cluely_rust();
    result.is_detected
}

/// Get the number of Cluely windows detected (Rust API)
pub fn get_cluely_window_count_rust() -> u32 {
    let result = detect_cluely_rust();
    result.window_count
}

/// C API - Main detection function (for compatibility)
/// 
/// # Safety
/// This function is safe to call from Swift/C
#[no_mangle]
pub extern "C" fn detect_cluely() -> ClueLyDetectionResult {
    let (_, result) = analyze_cluely_windows();
    result
}

/// C API - Simple boolean check (for compatibility)
/// 
/// # Safety
/// This function is safe to call from Swift/C
#[no_mangle]
pub extern "C" fn is_cluely_running() -> c_int {
    if detect_cluely().is_detected { 1 } else { 0 }
}

/// C API - Get window count (for compatibility)
/// 
/// # Safety
/// This function is safe to call from Swift/C
#[no_mangle]
pub extern "C" fn get_cluely_window_count() -> u32 {
    detect_cluely().window_count
}

/// Generate a detailed text report of Cluely detection
/// Returns a pointer to a C string that must be freed with free_cluely_report
/// 
/// # Safety
/// This function is safe to call from Swift/C
/// The returned string must be freed with free_cluely_report
#[no_mangle]
pub extern "C" fn get_cluely_report() -> *mut c_char {
    let (windows, result) = analyze_cluely_windows();
    
    let mut report = String::new();
    
    if result.is_detected {
        report.push_str("🚨 CLUELY EMPLOYEE MONITORING DETECTED\n");
        report.push_str("=====================================\n\n");
        
        report.push_str(&format!("📊 Summary:\n"));
        report.push_str(&format!("   • Total Cluely windows: {}\n", result.window_count));
        report.push_str(&format!("   • Screen capture evasion: {}\n", result.screen_capture_evasion_count));
        report.push_str(&format!("   • Elevated layer usage: {}\n", result.elevated_layer_count));
        if result.max_layer_detected > 0 {
            report.push_str(&format!("   • Highest layer detected: {}\n", result.max_layer_detected));
        }
        report.push_str("\n");
        
        report.push_str("🔍 Evasion Techniques Detected:\n");
        if result.screen_capture_evasion_count > 0 {
            report.push_str(&format!("   ⚠️  {} window(s) configured to avoid screen capture\n", result.screen_capture_evasion_count));
        }
        if result.elevated_layer_count > 0 {
            report.push_str(&format!("   ⚠️  {} window(s) using elevated display layers\n", result.elevated_layer_count));
        }
        report.push_str("\n");
        
        report.push_str("📋 Window Details:\n");
        for (i, window) in windows.iter().enumerate() {
            report.push_str(&format!("   {}. Window ID: {} [{}]\n", i + 1, window.window_id, window.owner));
            report.push_str(&format!("      - Sharing State: {} {}\n", 
                window.sharing_state,
                if window.sharing_state == 0 { "(avoiding screen capture)" } else { "(normal)" }
            ));
            report.push_str(&format!("      - Layer: {} {}\n", 
                window.layer,
                if window.layer > 0 { "(elevated - potential overlay)" } else { "(normal)" }
            ));
            
            let mut techniques = Vec::new();
            if window.sharing_state == 0 {
                techniques.push("Screen capture evasion");
            }
            if window.layer > 0 {
                techniques.push("Elevated layer positioning");
            }
            
            if !techniques.is_empty() {
                report.push_str(&format!("      - Techniques: {}\n", techniques.join(", ")));
            }
            report.push_str("\n");
        }
        
        report.push_str("⚠️  WARNING:\n");
        report.push_str("   This software is designed to monitor employee activity\n");
        report.push_str("   while remaining hidden during screen sharing sessions.\n");
        report.push_str("   Your activities may be recorded even when sharing your screen.\n");
        
    } else {
        report.push_str("✅ NO CLUELY MONITORING DETECTED\n");
        report.push_str("================================\n\n");
        report.push_str("No Cluely employee monitoring software found.\n");
        report.push_str("Your system appears to be free from this monitoring tool.\n");
    }
    
    // Convert to C string
    let c_string = CString::new(report).unwrap();
    c_string.into_raw()
}

/// Free memory allocated by get_cluely_report
/// 
/// # Safety
/// This function is safe to call from Swift/C
/// Only call this with pointers returned by get_cluely_report
#[no_mangle]
pub extern "C" fn free_cluely_report(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr);
        }
    }
} 