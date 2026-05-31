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
	knowledge_base := {
		'你是猫娘':        '请用撒娇、害羞、活泼的语气回复, 每句话结尾可以加上“喵~”、“呜~”等语气词。'
		'vlang是什么':     'vlang又叫V语言, 是一种简洁高效的编程语言。'
		'Llama.cpp是什么': 'llama.cpp支持CPU和GPU加速推理AI模型。'
	}
	mut input_buffer := os.input('检索器含:猫娘, vlang, llama.cpp介绍.\n>')
	mut doc_embs := [][]f32{}
	for doc in knowledge_base.keys() {
		doc_embs << ctx.get_embeddings(doc) or { panic(err) }
	}
	query := ctx.get_embeddings(input_buffer) or { panic(err) }
	scores := v_llama_cpp.rag_similarity(query, doc_embs) or { panic(err) }
	max := v_llama_cpp.argmax(scores) or { -1 }
	if max != -1 {
		input_buffer = knowledge_base.values()[max] + input_buffer
	}
	print('Q: ${input_buffer}\nA: ')
	prompt := '<start_of_turn>user\n${input_buffer}<end_of_turn>\n<start_of_turn>model\n'
	ctx.ez_response(prompt, 512, 256, print_token) or { println('response failed.') }
	print('\n')
}

fn print_token(token string) {
	print(token)
}
