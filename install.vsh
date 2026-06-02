#!/usr/bin/env v

import runtime

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

fn get_optimal_build_jobs() int {
    total_cpus := runtime.nr_cpus()
    total_memory_gb := runtime.total_memory() or {0}
    mut safe_jobs := if total_cpus <= 2 {
        1
    } else if total_cpus /1024 /1024 /1024 <= 3 {
        total_cpus - 1
    } else {
        total_cpus / 2
    }
    if total_memory_gb <= 8 && safe_jobs > 2 {
	    safe_jobs = 2
    }
    if safe_jobs < 1 {
        return 1
    }
    return safe_jobs
}

fn download(update_cmd string, search_cmd string, install_cmd string, packages []string) {
	mut to_install := []string{}
	for pkg in packages {
		check := system(search_cmd.replace('{pkg}', pkg))
		if check != 0 {
			to_install << pkg
		}
	}
	if to_install.len > 0 && update_cmd != '' {
		system(update_cmd)
	}
	for pkg in to_install {
		system(install_cmd.replace('{pkg}', pkg))
	}
}

source := dir(@FILE)
build := join_path(source, 'build')
llama_src := join_path(build, 'llama.cpp')
llama_build := join_path(llama_src, 'build')
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
llama_bin := join_path(build_path, 'bin')

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
	if system('which pacman') == 0 {
		// arch
		download(
			 'sudo pacman -Sy',
			 'pacman -Q {pkg}',
			 'sudo pacman -S --noconfirm {pkg}',
			 ['git', 'cmake', 'base-devel']
		)
	} else if system('which brew') == 0 {
		// Linuxbrew
		download(
			'brew update',
			'brew list {pkg}',
			'brew install {pkg}',
			['git', 'cmake', 'libomp']
		)
	} else if system('which dnf') == 0 {
		// Fedora
		download(
			'sudo dnf check-update',
			'dnf list installed {pkg}',
			'sudo dnf install -y {pkg}',
			['git', 'cmake', 'gcc-c++', 'make']
		)
	} else if system('which apt') == 0 {
		// Debian & Ubuntu
		download(
			'sudo apt update',
			'dpkg -s {pkg}',
			'sudo apt install -y {pkg}',
			['git', 'cmake', 'build-essential']
		)
	} else if system('which zypper') == 0 {
		// openSUSE
		download(
			'sudo zypper refresh',
			'rpm -q {pkg}',
			'sudo zypper install -y {pkg}',
			['git', 'cmake', 'gcc-c++', 'make']
		)
	} else if system('which apk') == 0 {
		// Alpine Linux
		download(
			'sudo apk update',
			'apk info -e {pkg}',
			'sudo apk add {pkg}',
			['git', 'cmake', 'g++', 'make']
		)
	} else {
                error_msg('Third-party package not found on Linux.')
	}
}

$if windows {
        if system('winget --help') == 0 {
                download(
                        '',
                        'winget list {pkg} >nul 2>&1',
                        'winget install -e --id {pkg}',
                        ['Git.Git', 'Kitware.CMake']
                )
        } else {
                error_msg('Winget is required on Windows to fetch build dependencies. Please install it first.')
        }

}

$if macos {
        if system('which brew') == 0 {
                download(
                        'brew update',
                        'brew list {pkg} >/dev/null 2>&1',
                        'brew install {pkg}',
                        ['git', 'cmake', 'libomp']
                )
        } else {
                error_msg('Homebrew is required on macOS to fetch build dependencies. Please install it first.')
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

if system('cmake --build "${llama_build}" --config Release --parallel ${get_optimal_build_jobs()}') != 0 {
	error_msg('Build llama.cpp failed.')
        return
}

if system('cmake --install "${llama_build}" --config Release --prefix ${build_path}') != 0 {
	error_msg('Install llama.cpp libraries failed.')
        return
}

$if windows {
	cmd := '.\\path.bat ${llama_bin.replace('/', '\\')}'
	system(cmd)
}


