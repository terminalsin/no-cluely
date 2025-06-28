#ifndef NO_CLUELY_DRIVER_H
#define NO_CLUELY_DRIVER_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/// Detailed detection result structure with evasion technique analysis
typedef struct {
    bool is_detected;                        // True if Cluely is detected
    uint32_t window_count;                   // Total number of Cluely windows
    uint32_t screen_capture_evasion_count;   // Windows avoiding screen capture
    uint32_t elevated_layer_count;           // Windows using elevated layers
    int32_t max_layer_detected;              // Highest layer number found
} ClueLyDetectionResult;

/// Main detection function - returns detailed result with evasion analysis
/// Returns a structure with detection status, window count, and evasion techniques
ClueLyDetectionResult detect_cluely(void);

/// Simple boolean check - returns 1 if Cluely detected, 0 otherwise
/// This is the simplest function to use from Swift
int is_cluely_running(void);

/// Get the number of Cluely windows detected
uint32_t get_cluely_window_count(void);

/// Generate a detailed text report of Cluely detection and evasion techniques
/// Returns a pointer to a C string that must be freed with free_cluely_report()
/// The report includes specific details about detected evasion techniques
char* get_cluely_report(void);

/// Free memory allocated by get_cluely_report()
/// MUST be called to free memory returned by get_cluely_report()
void free_cluely_report(char* report);

#ifdef __cplusplus
}
#endif

#endif // NO_CLUELY_DRIVER_H 