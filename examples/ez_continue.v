module main

import os
import v_llama_cpp {
	ModelUrl,
}

fn main() {
	model_url := ModelUrl{
		url:     [
			'https://www.modelscope.cn/models/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/master/DeepSeek-R1-Distill-Qwen-1.5B-Q2_K.gguf',
			'https://huggingface.co/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B-Q2_K.gguf',
		]
		sha256: '6b01273c847100f7e594c34869670430fc3597b3897f839664ed4ba4588f5c54'
	}
	model_path := './DeepSeek-R1-Distill-Qwen-1.5B-Q2_K.gguf'
	mut ctx := ModelUrl(model_url).ez_load_model(model_path, -1, 2048, 512) or {
		println('load model failed.')
		return
	}
	defer { ctx.free() }
	input_buffer := os.input('>')
	prompt := '<｜User｜>${input_buffer}<｜Assistant｜>'
	print('deepseek:')
	v_llama_cpp.ez_response(ctx, prompt, 2**4, 2**4, print_token) or { println('response failed.') }
	mut continue_bool := false
	if os.input('是否继续(Y/n)>').trim_space() in ['yes', 'y', 'Y'] {
		continue_bool = true
	}
	for continue_bool {
		v_llama_cpp.ez_continue(ctx, 2**4, print_token) or { println('response failed.') }
		if os.input('是否继续(Y/n)>').trim_space() in ['yes', 'y', 'Y'] {} else {
			continue_bool = false
		}
	}
}

fn print_token(token string) {
	print(token)
}
