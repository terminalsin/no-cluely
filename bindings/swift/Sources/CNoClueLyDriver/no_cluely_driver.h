#ifndef NO_CLUELY_DRIVER_H
#define NO_CLUELY_DRIVER_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * Detailed detection result structure containing comprehensive information
 * about detected Cluely evasion techniques.
 */
typedef struct {
    bool is_detected;                    // True if Cluely is detected
    uint32_t window_count;               // Total number of Cluely windows
    uint32_t screen_capture_evasion_count; // Windows using sharing_state = 0
    uint32_t elevated_layer_count;       // Windows using layer > 0
    int32_t max_layer_detected;          // Highest layer number found
} ClueLyDetectionResult;

/**
 * Simple check if Cluely employee monitoring software is running.
 * 
 * @return 1 if Cluely is detected, 0 otherwise
 */
int is_cluely_running(void);

/**
 * Detailed detection that analyzes specific evasion techniques.
 * 
 * @return ClueLyDetectionResult structure with comprehensive analysis
 */
ClueLyDetectionResult detect_cluely(void);

/**
 * Get a detailed text report of the detection results.
 * The returned string must be freed with free_cluely_report().
 * 
 * @return Detailed report string (caller must free)
 */
char* get_cluely_report(void);

/**
 * Free the memory allocated by get_cluely_report().
 * 
 * @param report_ptr Pointer returned by get_cluely_report()
 */
void free_cluely_report(char* report_ptr);

/**
 * Get the number of Cluely windows currently detected.
 * 
 * @return Number of Cluely windows
 */
uint32_t get_cluely_window_count(void);

#ifdef __cplusplus
}
#endif

#endif // NO_CLUELY_DRIVER_H 