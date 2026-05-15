module main

import os
import v_llama_cpp {
	ModelUrl,
}

fn main() {
	model_url := ModelUrl{
		url:    [
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
	input_buffer := os.input('> ')
	if input_buffer == 'exit' {
		println('EXIT!')
		return
	}
	prompt := '<｜User｜>${input_buffer}<｜Assistant｜><think>\n'
	print('deepseek:')
	ctx.ez_response(prompt, 2 ** 4, 2 ** 4, print_token) or {
		println('response failed.')
		return
	}
	print('\n')
	for os.input('Continue?(Y/n)>').trim_space() in ['yes', 'y', 'Y'] {
		ctx.ez_continue(2 ** 4, print_token) or { println('response failed.') }
	}
}

fn print_token(token string) {
	print(token)
}
