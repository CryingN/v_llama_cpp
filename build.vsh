#!/usr/bin/env v

source := dir(@FILE)
vlib_dir := '${dir(@VEXE)}/vlib'
target := '${vlib_dir}/v_llama_cpp'

system('rm -rf ${target}')
mkdir_all(target) or {
    println('[False] Failed to create directory: ${err}')
    return
}

v_files := ls(source) or {
        println('Copy failed!')
        println('  Please copy the system information to the following address for future updates to support your system:')
        println('  * https://gitee.com/sakana_ctf/v_llama_cpp/issues')
        println('  * https://github.com/sakana-ctf/v_llama_cpp/issues')
        println('source :       ${source}')
        println('target :       ${target}')
        return
}

for file in v_files {
    if file.ends_with('.v') || file.ends_with('v.mod') {
        src_path := join_path(source, file)
        dst_path := join_path(target, file)
        cp(src_path, dst_path) or {
            println('[Warn] Failed to copy ${file}: ${err}')
        }
    }
}

/*
if system('cp -r ${source} ${target}') == 0 {
	println('[True] v_llama_cpp copy by: ${target}v_llama_cpp')
} else {
        println('Copy failed!')
        println('  Please copy the system information to the following address for future updates to support your system:')
        println('  * https://gitee.com/sakana_ctf/v_llama_cpp/issues')
        println('  * https://github.com/sakana-ctf/v_llama_cpp/issues')
        println('source :       ${source}')
        println('target :       ${target}')
        println('cmd    :       cp -r ${source} ${target}')
        return
}
*/

$if linux {
        // arch
        if system('which pacman') == 0 {
                check := system('pacman -Q llama.cpp')
                if check == 0 {
                        println('llama.cpp already installed via pacman, skipping')
                } else {
                        println('Detected pacman, installing llama.cpp...')
                        system('pacman -S --noconfirm llama.cpp')
                }
                return
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
}
$if windows {
        // windows
        if system('where winget') == 0 {
                println('Checking if llama.cpp is already installed...')
                check := system('winget list --id ggerganov.llama.cpp')
                if check == 0 {
                        println('llama.cpp already installed via winget, skipping')
                } else {
                        println('Detected winget, installing llama.cpp...')
                        system('winget install -e --id ggerganov.llama.cpp')
                }
                return
        }
}

$if macos {
        // mac
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
}

println('[Error] No supported package manager detected (pacman/dnf/brew/winget)')
println('  Please configure llama.cpp manually.')
println('  Please copy the system information to the following address for future updates to support your system:')
println('  * https://gitee.com/sakana_ctf/v_llama_cpp/issues')
println('  * https://github.com/sakana-ctf/v_llama_cpp/issues')
system('v doctor')
