module v_llama_cpp

#flag -I @VMODROOT/build/include
#flag -I @VMODROOT/c_src
#flag -L @VMODROOT/build/lib
#flag @VMODROOT/c_src/v_llama_cpp.c
#flag -lllama -lggml -lggml-base -lggml-cpu
#flag -Wl,-rpath="@VMODROOT/build/bin"
#flag -Wl,-rpath="@VMODROOT/build/lib"

/*
// MacOS
#flag darwin -I/opt/homebrew/include
#flag darwin -L/opt/homebrew/lib

// Linux
#flag linux -I/usr/include
#flag linux -I/usr/local/include
#flag linux -L/usr/lib
#flag linux -L/usr/local/lib
*/

#include "v_llama_cpp.h"

struct C.llama_model_params {
pub mut:
	devices                     voidptr // ggml_backend_dev_t *
	tensor_buft_overrides       voidptr // const struct llama_model_tensor_buft_override *
	n_gpu_layers                i32
	split_mode                  int // enum llama_split_mode
	main_gpu                    i32
	tensor_split                &f32    // const float *
	progress_callback           voidptr // llama_progress_callback function pointer
	progress_callback_user_data voidptr // void *
	kv_overrides                voidptr // const struct llama_model_kv_override *
	vocab_only                  bool
	use_mmap                    bool
	use_direct_io               bool
	use_mlock                   bool
	check_tensors               bool
	use_extra_bufts             bool
	no_host                     bool
	no_alloc                    bool
}

struct C.llama_model {}

struct C.llama_context_params {
pub mut:
	n_ctx               u32
	n_batch             u32
	n_ubatch            u32
	n_seq_max           u32
	n_rs_seq            u32
	n_outputs_max       u32
	n_threads           i32
	n_threads_batch     i32
	ctx_type            int // enum llama_context_type
	rope_scaling_type   int // enum llama_rope_scaling_type
	pooling_type        int // enum llama_pooling_type
	attention_type      int // enum llama_attention_type
	flash_attn_type     int // enum llama_flash_attn_type
	rope_freq_base      f32
	rope_freq_scale     f32
	yarn_ext_factor     f32
	yarn_attn_factor    f32
	yarn_beta_fast      f32
	yarn_beta_slow      f32
	yarn_orig_ctx       u32
	defrag_thold        f32
	cb_eval             voidptr // ggml_backend_sched_eval_callback
	cb_eval_user_data   voidptr // void *
	type_k              int     // enum ggml_type
	type_v              int     // enum ggml_type
	abort_callback      voidptr // ggml_abort_callback
	abort_callback_data voidptr // void *
	embeddings  bool
	offload_kqv bool
	no_perf     bool
	op_offload  bool
	swa_full    bool
	kv_unified  bool
	samplers    voidptr // struct llama_sampler_seq_config *
	n_samplers  usize   // size_t
}

struct C.llama_context {}

struct C.llama_vocab {}

struct C.llama_batch {
pub mut:
	n_tokens i32
	token    &i32    // llama_token *  (llama_token = int32_t)
	embd     &f32    // float *
	pos      &i32    // llama_pos *  (llama_pos = int32_t)
	n_seq_id &i32    // int32_t *
	seq_id   voidptr // llama_seq_id **  (不支持 V 的双指针，用 voidptr)
	logits   &i8     // int8_t *
}

struct C.llama_memory_t {}

struct C.llama_chat_message {
	role    &char
	content &char
}

fn C.llama_tokenize(vocab &C.llama_vocab,
	text &char,
	text_len int,
	tokens &i32,
	n_tokens_max int,
	add_special bool,
	parse_special bool) int

fn C.llama_backend_init()
fn C.llama_backend_free()
fn C.llama_model_free(model &C.llama_model)
fn C.llama_free(context &C.llama_context)

fn C.llama_model_load_from_file(path &u8,
	params C.llama_model_params) &C.llama_model
fn C.llama_model_default_params() C.llama_model_params
fn C.llama_model_get_vocab(model &C.llama_model) &C.llama_vocab
fn C.llama_get_model(ctx &C.llama_context) &C.llama_model
fn C.llama_context_default_params() C.llama_context_params
fn C.llama_init_from_model(model &C.llama_model,
	ctx_params C.llama_context_params) &C.llama_context
fn C.llama_batch_get_one(tokens &i32,
	n_tokens int) C.llama_batch
fn C.llama_decode(context &C.llama_context,
	batch C.llama_batch) int
fn C.llama_vocab_n_tokens(vocab &C.llama_vocab) int
fn C.llama_get_logits_ith(context &C.llama_context,
	last_pos int) &f32
fn C.llama_vocab_is_eog(vocab &C.llama_vocab,
	token int) bool
fn C.llama_token_to_piece(vocab &C.llama_vocab,
	token int,
	buf &char,
	length int,
	lstrip int,
	special bool) int
fn C.ggml_backend_load_all()
fn C.llama_get_memory(ctx &C.llama_context) &C.llama_memory_t
fn C.llama_memory_clear(mem &C.llama_memory_t,
	data bool)
fn C.llama_memory_seq_pos_max(mem &C.llama_memory_t,
	seq_id int) int
fn C.llama_model_chat_template(model &C.llama_model,
	name &char) &char
fn C.llama_chat_apply_template(tmpl &char,
	chat &C.llama_chat_message,
	n_msg usize,
	add_ass bool,
	buf &char,
	length int) int
fn C.llama_log_set(callback voidptr, user_data voidptr)
fn C.v_llama_log_silent(level int, text &char, user_data voidptr)
fn C.v_llama_rag_similarity(query &f32,
	docs &f32,
	dim int,
	n_docs int) &f32
fn C.llama_state_save_file(ctx &C.llama_context,
	path_session &u8,
	tokens &i32,
	n_token_count usize) u64
fn C.llama_state_load_file(ctx &C.llama_context,
	path_session &u8,
	tokens_out &i32,
	n_token_capacity usize,
	n_token_count_out &usize) u64
fn C.llama_n_embd(model &C.llama_model) int
fn C.llama_encode(ctx &C.llama_context, batch C.llama_batch) int
fn C.llama_get_embeddings(ctx &C.llama_context) &f32
fn C.llama_get_embeddings_ith(ctx &C.llama_context, i int) &f32
fn C.llama_get_seq_id(ctx &C.llama_context, seq_id int)
fn C.llama_n_ctx(ctx &C.llama_context) u32
fn C.llama_n_batch(ctx &C.llama_context) u32
