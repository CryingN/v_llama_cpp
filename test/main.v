import os

fn main() {
	v_llama_cpp_dir := os.dir(os.dir(@FILE))
	examples_dir := os.join_path(v_llama_cpp_dir, 'examples')
	examples := os.ls(examples_dir) or { panic(err) }

	for f in examples {
		if !f.ends_with('.v') { continue }
		example_path := os.join_path(examples_dir, f)
		res := os.execute('v ${example_path}')
		if res.exit_code == 0 {
			println('PASS: ${f}')
		} else {
			panic('FAIL: ${f}\n${res.output}')
		}

	}
}
