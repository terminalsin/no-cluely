use clap::{Parser, Subcommand};
use colored::*;
use serde_json;
use std::process;
use std::thread;
use std::time::Duration;

// Import the detection functions from our Rust library
use no_cluely_driver::{detect_cluely_rust as detect_cluely, ClueLyDetectionResult};

#[derive(Parser)]
#[command(name = "cluely-detector")]
#[command(about = "Detect Cluely employee monitoring software and its evasion techniques")]
#[command(version)]
struct Cli {
    #[command(subcommand)]
    command: Option<Commands>,
}

#[derive(Subcommand)]
enum Commands {
    /// Quick check if Cluely is running
    Check,
    /// Show detailed detection report
    Report,
    /// Monitor continuously for Cluely (Ctrl+C to stop)
    Monitor {
        /// Check interval in seconds
        #[arg(short, long, default_value_t = 10)]
        interval: u64,
    },
    /// Output detection results as JSON
    Json,
    /// Show detection statistics
    Stats,
}

fn main() {
    let cli = Cli::parse();

    match &cli.command {
        Some(Commands::Check) => cmd_check(),
        Some(Commands::Report) => cmd_report(),
        Some(Commands::Monitor { interval }) => cmd_monitor(*interval),
        Some(Commands::Json) => cmd_json(),
        Some(Commands::Stats) => cmd_stats(),
        None => {
            // Default behavior - quick check
            cmd_check();
        }
    }
}

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

fn cmd_report() {
    // Generate detailed report using the same logic as the C function
    let result = detect_cluely();
    
    let report = if result.is_detected {
        format!(
            "🚨 CLUELY EMPLOYEE MONITORING DETECTED\n\
             =====================================\n\n\
             📊 Summary:\n\
                • Total Cluely windows: {}\n\
                • Screen capture evasion: {}\n\
                • Elevated layer usage: {}\n\
                {}\n\
             🔍 Evasion Techniques Detected:\n\
             {}\
             {}\n\
             ⚠️  WARNING:\n\
                This software is designed to monitor employee activity\n\
                while remaining hidden during screen sharing sessions.\n\
                Your activities may be recorded even when sharing your screen.\n",
            result.window_count,
            result.screen_capture_evasion_count,
            result.elevated_layer_count,
            if result.max_layer_detected > 0 {
                format!("   • Highest layer detected: {}", result.max_layer_detected)
            } else {
                "".to_string()
            },
            if result.screen_capture_evasion_count > 0 {
                format!("   ⚠️  {} window(s) configured to avoid screen capture\n", result.screen_capture_evasion_count)
            } else {
                "".to_string()
            },
            if result.elevated_layer_count > 0 {
                format!("   ⚠️  {} window(s) using elevated display layers\n", result.elevated_layer_count)
            } else {
                "".to_string()
            }
        )
    } else {
        "✅ NO CLUELY MONITORING DETECTED\n\
         ================================\n\n\
         No Cluely employee monitoring software found.\n\
         Your system appears to be free from this monitoring tool.\n".to_string()
    };
    
    println!("{}", report);
}

fn cmd_monitor(interval: u64) {
    println!("{}", "🔍 Monitoring for Cluely (Press Ctrl+C to stop)".bold().blue());
    println!("{}", "=============================================".blue());
    println!();

    // Set up Ctrl+C handler
    let running = std::sync::Arc::new(std::sync::atomic::AtomicBool::new(true));
    let r = running.clone();
    
    ctrlc::set_handler(move || {
        r.store(false, std::sync::atomic::Ordering::SeqCst);
    }).expect("Error setting Ctrl+C handler");

    let mut last_detection_state = false;
    let mut check_count = 0;

    while running.load(std::sync::atomic::Ordering::SeqCst) {
        check_count += 1;
        let result = detect_cluely();
        let is_detected = result.is_detected;
        
        let timestamp = chrono::Utc::now().format("%Y-%m-%d %H:%M:%S UTC");
        
        if is_detected != last_detection_state {
            if is_detected {
                println!("{} {}", 
                    format!("[{}]", timestamp).cyan(),
                    "🚨 CLUELY DETECTED - Monitoring software started!".bold().red()
                );
            } else {
                println!("{} {}", 
                    format!("[{}]", timestamp).cyan(),
                    "✅ Cluely monitoring stopped".bold().green()
                );
            }
            last_detection_state = is_detected;
        } else if check_count % 6 == 0 { // Status update every minute (if interval is 10s)
            let status = if is_detected { "DETECTED".red() } else { "NOT DETECTED".green() };
            println!("{} Status: {}", 
                format!("[{}]", timestamp).cyan(),
                status
            );
        }

        thread::sleep(Duration::from_secs(interval));
    }

    println!();
    println!("{}", "👋 Monitoring stopped".yellow());
}

fn cmd_json() {
    let result = detect_cluely();
    
    let json_result = serde_json::json!({
        "detected": result.is_detected,
        "window_count": result.window_count,
        "screen_capture_evasion_count": result.screen_capture_evasion_count,
        "elevated_layer_count": result.elevated_layer_count,
        "max_layer_detected": result.max_layer_detected,
        "severity": get_severity_level(&result),
        "evasion_techniques": get_evasion_techniques(&result),
        "timestamp": chrono::Utc::now().to_rfc3339()
    });

    println!("{}", serde_json::to_string_pretty(&json_result).unwrap());
}

fn cmd_stats() {
    let result = detect_cluely();
    
    println!("{}", "📊 Detection Statistics".bold().blue());
    println!("{}", "======================".blue());
    println!();
    
    println!("{:<30} {}", "Detection Status:", 
        if result.is_detected { "DETECTED".red() } else { "NOT DETECTED".green() });
    
    if result.is_detected {
        println!("{:<30} {}", "Total Windows:", result.window_count.to_string().cyan());
        println!("{:<30} {}", "Screen Capture Evasion:", result.screen_capture_evasion_count.to_string().yellow());
        println!("{:<30} {}", "Elevated Layer Usage:", result.elevated_layer_count.to_string().yellow());
        
        if result.max_layer_detected > 0 {
            println!("{:<30} {}", "Max Layer Detected:", result.max_layer_detected.to_string().magenta());
        }
        
        println!("{:<30} {}", "Severity Level:", get_severity_level(&result).bold());
        
        let techniques = get_evasion_techniques(&result);
        if !techniques.is_empty() {
            println!();
            println!("{}", "Evasion Techniques:".bold().yellow());
            for technique in techniques {
                println!("  • {}", technique);
            }
        }
    }
}

fn get_severity_level(result: &ClueLyDetectionResult) -> String {
    if !result.is_detected {
        return "None".to_string();
    }
    
    let technique_count = 
        (if result.screen_capture_evasion_count > 0 { 1 } else { 0 }) +
        (if result.elevated_layer_count > 0 { 1 } else { 0 });
    
    match technique_count {
        0 => "Low".to_string(),
        1 => "Medium".to_string(),
        _ => "High".to_string(),
    }
}

fn get_evasion_techniques(result: &ClueLyDetectionResult) -> Vec<String> {
    let mut techniques = Vec::new();
    
    if result.screen_capture_evasion_count > 0 {
        techniques.push(format!("Screen capture evasion ({} windows)", result.screen_capture_evasion_count));
    }
    
    if result.elevated_layer_count > 0 {
        techniques.push(format!("Elevated layer positioning ({} windows)", result.elevated_layer_count));
    }
    
    techniques
} 