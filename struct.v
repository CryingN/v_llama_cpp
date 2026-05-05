module v_llama_cpp

import arrays {
	carray_to_varray
}

// Context

pub fn (ctx Context) model() Model {
	return C.llama_get_model(ctx)
}

pub fn (context Context) free() {
	C.llama_free(context)
}

pub fn (context Context) decode(batch Batch) ! {
	result := C.llama_decode(context, batch)
	if result {
		return error('[Error] ./v_llama_cpp/struct.v Context.decode(): Prompt processing failed.')
	}
}


pub fn (context Context) get_logits_ith(last_pos int, vocab Vocab) []f32 {
	logits_ptr := C.llama_get_logits_ith(context, last_pos)
	n_vocab := C.llama_vocab_n_tokens(vocab)
	return unsafe { carray_to_varray[f32](logits_ptr, n_vocab) }
}

// Model

pub fn (model Model) vocab() Vocab {
	return C.llama_model_get_vocab(model)
}

pub fn (model Model) free() {
	C.llama_model_free(model)
}

// Tokens

pub fn (tokens Tokens) batch_get_one(n_tokens int) Batch {
	return C.llama_batch_get_one(tokens.data, n_tokens)
}

// Vocab

pub fn (vocab Vocab) tokenize(prompt string, tokens Tokens, n_tokens_max int, add_special bool, parse_special bool) !int {
        result := C.llama_tokenize(vocab, prompt.str, prompt.len, tokens.data, n_tokens_max, add_special, parse_special)
        if result < 0 {
                return error('[Error] ./v_llama_cpp/llama.v tokenize(): Tokenization failed.')
        }
        return result
}


pub fn (vocab Vocab) is_eog(token_id int) bool {
	return C.llama_vocab_is_eog(vocab, token_id)
}

pub fn (vocab Vocab) token_to_piece(token_id int, length int, lstrip int, special bool) !string {
	mut buf := []u8{len: length}
	result := unsafe {
		C.llama_token_to_piece(
			vocab,
			token_id,
			&buf[0],
			length,
			lstrip,
			special
		)
	}

	if result < 0 {
		return error('[Error] ./v_llama_cpp/struct.v Vocab.token_to_piece(): Token is empty string.')
	}

	return unsafe {
		buf[0..result].bytestr()
	}
}



