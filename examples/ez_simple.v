module main

import os
import v_llama_cpp {
	ModelUrl
}

fn main() {
	model_url := 'https://www.modelscope.cn/models/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/master/DeepSeek-R1-Distill-Qwen-1.5B-Q2_K.gguf'
	model_path := './DeepSeek-R1-Distill-Qwen-1.5B-Q2_K.gguf'
        mut ctx := ModelUrl(model_url).ez_load_model(model_path, -1, 2048, 512) or {
                println('load model failed.')
                return
        }
        defer { ctx.free() }
        input_buffer := os.input('>')
        prompt := '<｜User｜>${input_buffer}<｜Assistant｜>'
        print('deepseek:')
        v_llama_cpp.ez_response(
                ctx,
                prompt,
                512,
                256,
                print_token,
        ) or {
                println('response failed.')
        }
}

fn print_token(token string) {
        print(token)
}

