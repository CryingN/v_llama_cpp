#include "v_llama_cpp.h"

void v_llama_log_silent(enum ggml_log_level level, const char * text, void * user_data) {
    (void) level;
    (void) text;
    (void) user_data;
}

#ifdef _WIN32
    #include <windows.h>

    void dll_search_path(const char* path) {
        if (path == NULL) return;

        wchar_t wide[MAX_PATH];
        MultiByteToWideChar(CP_UTF8, 0, path, -1, wide, MAX_PATH);
        SetDllDirectoryW(wide);
    }
#else
    void dll_search_path(const char* path) {
        (void)path;
    }
#endif


