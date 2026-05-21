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
	mut new_ctx := ctx.new(2048, 512) or {
		println('load new model failed.')
		return
	}
	for {
		input_buffer := os.input('>')
		if input_buffer == 'quit' {
			println('QUIT!')
			return
		}
		prompt := '<｜User｜>${input_buffer}<｜Assistant｜><think>\n'
		output_buffer := os.input('1. Stateful Model\n2. Stateless Model\nOther. Stateless Model.\n\tSelect (1,2) >').trim_space()
		print('deepseek: ')
		if output_buffer == '2' {
			new_ctx.ez_response(prompt, 512, 512, print_token) or { println('response failed.') }
			new_ctx.memory_clear(true)
		} else {
			ctx.ez_response(prompt, 512, 512, print_token) or { println('response failed.') }
		}
		print('\n')
	}
}

fn print_token(token string) {
	print(token)
}
