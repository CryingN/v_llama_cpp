module v_llama_cpp

import arrays {
	carray_to_varray,
}

// backend_init initializes the llama.cpp backend.
pub fn backend_init() {
	C.llama_log_set(C.v_llama_log_silent, unsafe { nil })
	C.ggml_backend_load_all()
	C.llama_backend_init()
}

// backend_free releases the backend resources.
@[inline]
pub fn backend_free() {
	C.llama_backend_free()
}

// load_model_from_file loads a model from file.
pub fn load_model_from_file(path string, model_params ModelParams) !Model {
	model := C.llama_model_load_from_file(path.str, model_params)
	if model == C.NULL {
		return error('[Error] ./v_llama_cpp/llama.v load_model_form_file(): Model loading failed.')
	}
	return model
}

// model_default_params returns default model parameters.
@[inline]
pub fn model_default_params() ModelParams {
	return C.llama_model_default_params()
}

// context_default_params returns default context parameters.
@[inline]
pub fn context_default_params() ContextParams {
	return C.llama_context_default_params()
}

// init_from_model initializes context from a model.
@[inline]
pub fn init_from_model(model Model, context_params ContextParams) !Context {
	context := C.llama_init_from_model(model, context_params)
	if context == unsafe { nil } {
		return error('[Error] ./v_llama_cpp/llama.v init_from_model(): Context loading failed.')
	}
	return context
}

// get_embeddings retrieves embeddings from the context for the given model.
pub fn get_embeddings(context Context, model Model) ![]f32 {
	embedding_ptr := C.llama_get_embeddings(context)
	if embedding_ptr == unsafe { nil } {
		return error('[Error] ./v_llama_cpp/llama.v get_embeddings():embedding loading failed.')
	}
	n_embd := C.llama_n_embd(model)
	result := unsafe { carray_to_varray[f32](embedding_ptr, n_embd) }
	return result
}

pub fn rag_similarity(query []f32, docs [][]f32) ![]f32 {
	if docs.len == 0 {
		return []f32{}
	}
	dim := query.len
	n_docs := docs.len
	mut flat_docs := []f32{len: dim * n_docs}
	for i in 0..n_docs {
		for j in 0..dim {
			flat_docs[i * dim + j] = docs[i][j]
		}
	}
	scores_ptr := C.v_llama_rag_similarity(unsafe{ &query[0] }, unsafe{ &flat_docs[0] }, dim, n_docs)
	if scores_ptr == unsafe { nil } {
		return error('[Error] ./v_llama_cpp/llama.v rag_similarity():rag distance calculation failed..')
	}
	return unsafe { carray_to_varray[f32](scores_ptr, n_docs) }
}



