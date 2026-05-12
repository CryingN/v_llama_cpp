module v_llama_cpp

import os
import crypto.sha256

fn verify_and_cleanup(model_path string, expected_hash string) ! {
	mut h := sha256.new()
	mut f := os.open(model_path) or { return err }
	defer { f.close() }

	for {
		mut buf := []u8{len: 4096}
		n := f.read(mut buf) or { break }
		if n == 0 { break
		 }
		h.write(buf[..n]) or { return err }
	}

	computed_hash := h.sum([]).hex()

	if computed_hash != expected_hash {
		return error('[Error] ./v_llama_cpp/ez_hash.v verify_and_cleanup(): Hash mismatch.')
	}
}
