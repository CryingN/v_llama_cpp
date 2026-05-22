module main

import os
import v_llama_cpp {
	ModelUrl,
}

fn main() {
	model_url := ModelUrl{
		url:    [
			'https://www.modelscope.cn/models/bartowski/google_gemma-3-1b-it-GGUF/resolve/master/google_gemma-3-1b-it-Q4_0.gguf',
			'https://huggingface.co/bartowski/google_gemma-3-1b-it-GGUF/resolve/main/google_gemma-3-1b-it-Q4_0.gguf',
		]
		sha256: '4c62ce8950bc6d5ba5124a70fc13ece971fabd4dc5705477f305a6c3eb6294cd'
	}
	model_path := './google_gemma-3-1b-it-Q4_0.gguf'
	mut ctx := ModelUrl(model_url).ez_load_model(model_path, -1, 2048, 512) or {
		println('load model failed.')
		return
	}
	for {
		input_buffer := os.input('>')
		if input_buffer == 'quit' {
			println('QUIT!')
			return
		}
		prompt := '<｜User｜>${input_buffer}<｜Assistant｜><think>\n'
		print('gemma: ')
		ctx.ez_response(prompt, 512, 512, print_token) or { println('response failed.') }
		ctx.memory_clear(true)
		print('\n')
	}
}

fn print_token(token string) {
	print(token)
}
