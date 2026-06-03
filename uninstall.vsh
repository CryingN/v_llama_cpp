#!/usr/bin/env v

fn remove_module_dirs() {
	mut vmodules_dir := join_path(home_dir(), '.vmodules')
	$if !windows {
		if getenv('SUDO_USER') != '' {
			original_user := getenv('SUDO_USER')
			vmodules_dir = '/home/' + join_path(original_user, '.vmodules')
		}
	}
	target := join_path(vmodules_dir, 'v_llama_cpp')
	if exists(target) {
		println('Removing user module: ${target}')
		rmdir_all(target) or { println('[Error]  Failed: ${err}') }
	}
}

remove_module_dirs()
