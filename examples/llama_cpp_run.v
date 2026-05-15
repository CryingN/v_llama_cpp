module main

import os
import v_llama_cpp {
	Context,
	Model,
	Token,
	Tokens,
}

fn generate_response(ctx Context, prompt string) ! {
	add_special := ctx.memory_seq_pos_max(0) == -1
	n_max_tokens := 512
	tokens := Tokens([]Token{cap: n_max_tokens})
	model := ctx.model()
	vocab := model.vocab()
	n_tokens := vocab.tokenize(prompt, tokens, n_max_tokens, add_special, true) or {
		return error('[错误] 分词失败: ${err}')
	}
	mut batch := tokens.batch_get_one(n_tokens)
	ctx.decode(batch) or {
		return error('[错误] 提示词处理失败: ${err}')
	}
	print('deepseek: ')
	n_predict := 256
	mut new_token_id := Token{}

	for i := 0; i < n_predict; i++ {
		logits := ctx.get_logits_ith(-1, vocab)
		new_token_id = v_llama_cpp.argmax(logits)!
		if vocab.is_eog(new_token_id) {
			break
		}
		n_chars := vocab.token_to_piece(new_token_id, n_predict, 0, true ) or { '' }
		print(n_chars)
		mut new_tokens := Tokens([]Token{ len: 1, cap: 1 })
		new_tokens[0] = Token(new_token_id)
		batch = new_tokens.batch_get_one(1)
		ctx.decode(batch) or {
			return error('[错误] 提示词处理失败: ${err}')
		}
	}
	println('')
}

fn main() {
	v_llama_cpp.backend_init()
	model_path := './DeepSeek-R1-Distill-Qwen-1.5B-Q2_K.gguf'
	println('正在加载模型: ${model_path} ...')

	mut model_params := v_llama_cpp.model_default_params()
	model_params.set_n_gpu_layers(-1)
	mut model := v_llama_cpp.load_model_from_file(model_path, model_params) or {
		println('模型加载失败')
		return
	}
	mut ctx_params := v_llama_cpp.context_default_params()
	ctx_params.n_ctx = 2048
	ctx_params.n_batch = 512
	mut ctx := v_llama_cpp.init_from_model(model, ctx_params) or {
		println("上下文初始化失败")
		return
	}
	for {
		input_buffer := os.input('> ')
		if input_buffer == ':q' {
			println('EXIT!')
			exit(1)
		}
		prompt := '<｜User｜>${input_buffer}<｜Assistant｜><think>\n'
		generate_response(ctx, prompt) or { panic(err) }
	}
}
