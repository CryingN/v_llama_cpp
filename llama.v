module v_llama_cpp

pub fn (vocab Vocab)tokenize(prompt string, tokens Tokens, n_tokens_max int, add_special bool, parse_special bool) !int {
	result := C.llama_tokenize(vocab, prompt.str, prompt.len, tokens.data, n_tokens_max, add_special, parse_special)
	if result < 0 {
		return error('[Error] ./v_llama_cpp/llama.v tokenize(): Tokenization failed.')
	}
	return result
}

@[inline]
pub fn backend_init() { C.llama_backend_init() }
@[inline]
pub fn backend_free() { C.llama_backend_free() }

pub fn load_model_from_file(path string, model_params ModelParams) !Model {
	model := C.llama_load_model_from_file(path.str, model_params)
	if model == C.NULL {
		return error('[Error] ./v_llama_cpp/llama.v load_model_form_file(): Model loading failed.')
	}
	return model
}

@[inline]
pub fn model_default_params() ModelParams { return C.llama_model_default_params() }

@[inline]
pub fn context_default_params() ContextParams { return C.llama_context_default_params() }

@[inline]
pub fn init_from_model(model Model, context_params ContextParams) !Context {
	context := C.llama_init_from_model(model, context_params)
	if context == C.NULL {
		return error('[Error] ./v_llama_cpp/llama.v init_from_model(): Context loading failed.')
	}
	return context
}




