module v_llama_cpp

// set_n_gpu_layers sets the number of GPU layers.
pub fn (mut model_params ModelParams) set_n_gpu_layers(value int) {
	model_params.n_gpu_layers = value
}

