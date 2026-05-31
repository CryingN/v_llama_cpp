#!/usr/bin/env v

fn error_msg(msg string) {
	println('[Error] Failed to configure llama.cpp.')
	println('  Please copy the system information to the following address for future updates to support your system:')
	println('  * https://gitee.com/sakana_ctf/v_llama_cpp/issues')
	println('  * https://github.com/sakana-ctf/v_llama_cpp/issues')
	system('v doctor')
	println(msg)
	exit(0)
}

fn choice_type() string {
	println('Please choose which version to install:')
	println('  1) llama.cpp (default)')
	println('  2) llama.cpp-vulkan (Vulkan backend)')
	println('  3) llama.cpp-cuda (CUDA backend for NVIDIA)')
	println('  4) llama.cpp-hip (HIP backend for AMD)')
	println('  5) llama.cpp-metal (Metal backend for Apple)')
	return input('Enter your choice (1-5, default 1): ').trim_space()
}

source := dir(@FILE)
mut vmodules_dir := join_path(home_dir(), '.vmodules')
$if !windows {
	if getenv('SUDO_USER') != '' {
		original_user := getenv('SUDO_USER')
		vmodules_dir = '/home/${original_user}/.vmodules'
	}
}

target := join_path(vmodules_dir, 'v_llama_cpp')
build_path := join_path(target, 'build')
llama_h_path := join_path(build_path, 'include', 'llama.h')
llama_src := join_path(build_path, 'llama.cpp')
llama_build := join_path(llama_src, 'build')
llama_bin := join_path(build_path, 'bin').replace('/', '\\')

old_files := ls(target) or { []string{} }
for file in old_files {
        if file.ends_with('.v') || file == 'v.mod' {
                rm(join_path(target, file)) or {
                        println('[Warn] Failed to remove old ${file}: ${err}')
                }
        } else if file == 'c_src' {
                rmdir_all(join_path(target, file)) or {
                        println('[Warn] Failed to remove old ${file}: ${err}')
                }
	}
  }

mkdir_all(target) or {}

v_files := ls(source) or {
	mut msg := 'Copy failed!\n'
	msg += 'source :       ${source}\n'
	msg += 'target :       ${target}'
	error_msg(msg)
	return
}

for file in v_files {
	src_path := join_path(source, file)
	dst_path := join_path(target, file)
	if file.ends_with('.v') || file.ends_with('v.mod') {
		cp(src_path, dst_path) or { error_msg('Failed to copy ${file}: ${err}') }
	} else if file == 'c_src' {
		mkdir(dst_path) or {}
		cp_all(src_path, dst_path, true) or { error_msg('Failed to copy ${file}: ${err}') }
	}
}

$if !windows {
	if getenv('SUDO_USER') != '' {
		original_user := getenv('SUDO_USER')
		system('chown -R ${original_user}:${original_user} ${vmodules_dir}')
	}
}

$if linux {
	// arch
	if system('which pacman') == 0 {
		mut check := system('pacman -Q llama.cpp')
		if check == 0 {
			println('llama.cpp already installed via pacman, skipping')
			return
		} else {
			println('Detected pacman, installing llama.cpp...')
			system('pacman -S --noconfirm llama.cpp')
		}
		check = system('pacman -Q llama.cpp')
		if check == 0 {
			return
		}
	}

	if system('which yay') == 0 {
		mut check := system('yay -Q llama.cpp')
		if check == 0 {
			println('llama.cpp already installed via yay, skipping')
			return
		}

		println('llama.cpp not found in pacman, installing via yay...')
		choice := choice_type()
		pkg := match choice {
			'2' { 'llama.cpp-vulkan' }
			'3' { 'llama.cpp-cuda' }
			'4' { 'llama.cpp-hip' }
			else { 'llama.cpp' }
		}

		println('Installing ${pkg}...')
		system('yay -S --noconfirm ${pkg}')

		check = system('yay -Q ${pkg}')
		if check == 0 {
			return
		}
	}

	// Fedora
	if system('which dnf') == 0 {
		check := system('dnf list installed llama.cpp')
		if check == 0 {
			println('llama.cpp already installed via dnf, skipping')
		} else {
			println('Detected dnf, installing llama.cpp...')
			system('dnf install -y llama.cpp')
		}
		return
	}
	// Linuxbrew
	if system('which brew') == 0 {
		check := system('brew list --formula | grep -q llama.cpp')
		if check == 0 {
			println('llama.cpp already installed via Homebrew, skipping')
		} else {
			println('Detected Homebrew, installing llama.cpp...')
			system('brew install llama.cpp')
		}
		return
	}
	// Debian & Ubuntu
	if system('which apt') == 0 {
		packages := ['git', 'cmake', 'build-essential']
		mut to_install := []string{}

		for pkg in packages {
			check := system('dpkg -s ${pkg} >/dev/null 2>&1')
			if check != 0 {
				to_install << pkg
			} else {
				println('$pkg already installed, skipping')
			}
		}
		if to_install.len > 0 {
			system('sudo apt update')
		}
		for package in to_install {
			system('sudo apt install -y ${package}')
		}
	}
}

$if windows {
	// Windows
	if system('winget --help') == 0 {
		if system('git --help') != 0 {
			system('winget install -e --id Git.Git')
		}
		if system('cmake --help') != 0 {
			system('winget install -e --id Kitware.CMake')
		}
	}
}

$if macos {
	// mac
	if os.system('which brew') == 0 {
		if os.system('brew list cmake >/dev/null 2>&1') != 0 {
		        println('  -> cmake not found, installing...')
		        os.system('brew install cmake')
		} else {
		        println('  -> cmake is already installed.')
		}
		if os.system('brew list git >/dev/null 2>&1') != 0 {
		        println('  -> git not found, installing...')
		        os.system('brew install git')
		} else {
		        println('  -> git is already installed.')
		}
		if os.system('brew list libomp >/dev/null 2>&1') != 0 {
		        println('  -> libomp not found, installing OpenMP support...')
		        os.system('brew install libomp')
		} else {
		        println('  -> libomp is already installed.')
		}
	} else {
	        error_msg('Homebrew is required on macOS to fetch build dependencies. Please install it first.')
	}
}

if !exists(llama_src) || !exists(join_path(llama_src, 'Makefile')) {
	rmdir_all(llama_src) or {}
	if system('git clone https://github.com/ggml-org/llama.cpp "${llama_src}"') != 0 {
	error_msg('Clone llama.cpp failed.')
	}
}

if exists(llama_h_path) {
	return
}

mut cmake_flags := '-DCMAKE_BUILD_TYPE=Release'
choice := choice_type()
match choice {
	'1' { cmake_flags += ' -DGGML_VULKAN=OFF' }
	'2' { cmake_flags += ' -DGGML_VULKAN=ON' }
	'3' { cmake_flags += ' -DGGML_CUDA=ON' }
	'4' { cmake_flags += ' -DGGML_HIP=ON' }
	'5' { cmake_flags += ' -DGGML_METAL=ON' }
	else { cmake_flags += ' -DGGML_VULKAN=OFF' }
}

cmake_flags += ' -DBUILD_SHARED_LIBS=ON'
cmake_flags += ' -DLLAMA_BUILD_COMMON=OFF'
cmake_flags += ' -DLLAMA_BUILD_APP=OFF'
cmake_flags += ' -DLLAMA_BUILD_TOOLS=OFF'
cmake_flags += ' -DLLAMA_BUILD_EXAMPLES=OFF'
cmake_flags += ' -DLLAMA_BUILD_TESTS=OFF'
cmake_flags += ' -DLLAMA_BUILD_SERVER=OFF'
cmake_flags += ' -DGGML_BUILD_EXAMPLES=OFF'
cmake_flags += ' -DGGML_BUILD_TESTS=OFF'

rmdir_all(llama_build) or {}
if system('cmake -S "${llama_src}" -B "${llama_build}" ${cmake_flags}') != 0 {
        error_msg('CMake configure llama.cpp failed.')
        return
  }

if system('cmake --build "${llama_build}" --config Release --parallel') != 0 {
	error_msg('Build llama.cpp failed.')
        return
}

if system('cmake --install "${llama_build}" --config Release --prefix ${build_path}') != 0 {
	error_msg('Install llama.cpp libraries failed.')
        return
}

$if windows {
	cmd := '.\\path.bat ${llama_bin}'
	system(cmd)
}


