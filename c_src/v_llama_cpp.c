#include "v_llama_cpp.h"

void v_llama_log_silent(enum ggml_log_level level, const char * text, void * user_data) {
    (void) level;
    (void) text;
    (void) user_data;
}

float* v_llama_rag_similarity(const float* query, const float* docs, int dim, int n_docs) {
    struct ggml_init_params params = {
        .mem_size = 10 * 1024 * 1024,
	.mem_buffer = NULL,
        .no_alloc = false,
    };
    struct ggml_context* ctx = ggml_init(params);
    
    struct ggml_tensor* t_query = ggml_new_tensor_2d(ctx, GGML_TYPE_F32, dim, 1);
    memcpy(t_query->data, query, dim * sizeof(float));
    
    struct ggml_tensor* t_docs = ggml_new_tensor_2d(ctx, GGML_TYPE_F32, dim, n_docs);
    memcpy(t_docs->data, docs, dim * n_docs * sizeof(float));
    
    struct ggml_tensor* result = ggml_mul_mat(ctx, t_query, t_docs);
    struct ggml_cgraph* graph = ggml_new_graph(ctx);
    ggml_build_forward_expand(graph, result);
    ggml_graph_compute_with_ctx(ctx, graph, 4);
    
    float* scores = (float*)malloc(n_docs * sizeof(float));
    memcpy(scores, result->data, n_docs * sizeof(float));
    
    ggml_free(ctx);
    return scores;
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






