module main

import os
//import readline { Readline }
import v_llama_cpp {
	Context,
	Model,
	Token,
	Tokens,
}

// V 语言中，我们可以直接遍历数组来找到最大值索引，无需单独的 argmax 函数
fn argmax(arr []f32) int {
	mut max_idx := 0
	mut max_val := arr[0]
	for i := 1; i < arr.len; i++ {
		if arr[i] > max_val {
			max_val = arr[i]
			max_idx = i
		}
	}
	return max_idx
}

// 生成回复的函数
fn generate_response(ctx Context, prompt string) {
	n_max_tokens := 512
	tokens := Tokens([]Token{cap: n_max_tokens})
	model := ctx.model()
	vocab := model.vocab()
	n_tokens := vocab.tokenize(prompt, tokens, n_max_tokens, true, true) or {
		println('[错误] 分词失败: ${err}')
		return
	}
	mut batch := tokens.batch_get_one(n_tokens)
	ctx.decode(batch) or {
		println('[错误] 提示词处理失败: ${err}')
		return
	}
	print('neko: ')
	n_predict := 256
	mut new_token_id := Token{}

	for i := 0; i < n_predict; i++ {
		// 获取 Logits
		logits := ctx.get_logits_ith(-1, vocab)
		new_token_id = argmax(logits)
		if vocab.is_eog(new_token_id) {
			break;
		}
		n_chars := vocab.token_to_piece(new_token_id, 256, 0, true ) or { '' }
		print(n_chars)
		mut new_tokens := Tokens([]Token{ len: 1, cap: 1 })
		new_tokens[0] = Token(new_token_id)
		batch = new_tokens.batch_get_one(1)
		ctx.decode(batch) or {
			println('[错误] 提示词处理失败: ${err}')
			return
		}
	}
	println('')
}

fn main() {
	v_llama_cpp.backend_init()
	defer { v_llama_cpp.backend_free() }

	model_path := './qwen2.5-1.5B-int4.gguf'
	println('正在加载模型: ${model_path} ...')

	mut model_params := v_llama_cpp.model_default_params()
	model_params.set_n_gpu_layers(0)
	mut model := v_llama_cpp.load_model_from_file(model_path, model_params) or {
		println('模型加载失败')
		return
	}
	defer { model.free() }
	mut ctx_params := v_llama_cpp.context_default_params()
	ctx_params.n_ctx = 2048
	ctx_params.n_batch = 512
	mut ctx := v_llama_cpp.init_from_model(model, ctx_params) or {
		println("上下文初始化失败")
		return
	}
	defer { ctx.free() }
	println("true")
	for {
		input_buffer := os.input('> ')
		/*
		mut data := ''
		mut line := Readline{ skip_empty: true }
		for {
		$if linux {
			data += '\n'
		}
		if data == ':q\r\n' || data == ':q\n' {
			println('EXIT!')
			exit()
		}
		}
		*/
		if input_buffer == ':q' {
			println('EXIT!')
			exit(1)
		}
		prompt := 'User: ${input_buffer}\nAssistant:'
		generate_response(ctx, prompt)
	}
}
