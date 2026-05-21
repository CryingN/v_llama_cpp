#include "v_llama_cpp.h"

static void llama_log_silent(enum ggml_log_level level, const char * text, void * user_data) {
    (void) level;
    (void) text;
    (void) user_data;
}
