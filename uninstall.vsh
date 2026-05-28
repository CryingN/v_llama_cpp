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

fn uninstall_llama_cpp() {
	$if linux {
		// Arch
		if system('which pacman') == 0 {
			check := system('pacman -Q llama.cpp 2>/dev/null')
			if check == 0 {
				println('Removing llama.cpp via pacman...')
				system('sudo pacman -R --noconfirm llama.cpp')
			}
		}
		if system('which yay') == 0 {
			pkgs := [
			'llama.cpp',
			'llama.cpp-vulkan',
			'llama.cpp-cuda',
			'llama.cpp-hip',
			]

			for pkg in pkgs {
				check := system('yay -Q ${pkg} 2>/dev/null')
				if check == 0 {
					println('Removing ${pkg} via yay...')
					system('yay -R --noconfirm ${pkg}')
				}
			}
		}
		// Fedora
		if system('which dnf') == 0 {
			check := system('dnf list installed llama.cpp 2>/dev/null')
			if check == 0 {
				println('Removing llama.cpp via dnf...')
				system('sudo dnf remove -y llama.cpp')
			}
		}
		// Homebrew
		if system('which brew') == 0 {
			check := system('brew list --formula 2>/dev/null | grep -q llama.cpp')
			if check == 0 {
				println('Removing llama.cpp via Homebrew...')
				system('brew uninstall llama.cpp')
			}
		}
	}
}

fn main() {
	remove_module_dirs()
	choose :=
	input('[Choose] Whether to attempt uninstalling the llama.cpp library from third-party package managers(Y/n): ')
	if choose.trim_space() in ['yes', 'y', 'Y'] {
		uninstall_llama_cpp()
	}
	println('[True] v_llama_cpp uninstall completed.')
}
