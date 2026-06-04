#ifndef V_LLAMA_CPP_H
#define V_LLAMA_CPP_H

#include "llama.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>

void v_llama_log_silent(enum ggml_log_level level, const char * text, void *
user_data);
float* v_llama_rag_similarity(const float* query, const float* docs, int dim, int n_docs);
void dll_search_path(const char* path);

#endif


