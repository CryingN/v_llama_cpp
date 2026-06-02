module main

import os
import v_llama_cpp {
	ModelUrl,
}

fn main() {
	model_url := ModelUrl{
		url:    [
			'https://www.modelscope.cn/models/ggml-org/e5-small-v2-Q8_0-GGUF/resolve/master/e5-small-v2-q8_0.gguf',
			'https://huggingface.co/ggml-org/e5-small-v2-Q8_0-GGUF/resolve/main/e5-small-v2-q8_0.gguf',
		]
		sha256: 'afdfb5c342d2efc2a051c426dd1d00913495d5f2bbceaea100d2f3892aa31cbc'
	}
	model_path := './e5-small-v2-q8_0.gguf'
	mut ctx := ModelUrl(model_url).ez_load_model(model_path, -1, 2048, 512) or {
		println('load model failed.')
		return
	}
	knowledge_base := {
		'catgirl':	'Please reply in a coquettish, shy, and lively tone, and you can add modal particles like "Meow~" or "Woo~" at the end of each sentence.'
		'vlang':	'vlang, also known as the V language, is a concise and efficient programming language.'
		'llama.cpp':	'llama.cpp supports CPU and GPU accelerated inference for AI models.'
	}
	mut input_buffer := os.input('Retriever includes: catgirl, vlang, llama.cpp introduction.\n>')
	mut doc_embs := [][]f32{}
	for doc in knowledge_base.keys() {
		doc_embs << ctx.get_embeddings('passage: ' + doc) or { panic(err) }
	}
	query := ctx.get_embeddings('query: ' + input_buffer) or { panic(err) }
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
