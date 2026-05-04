#!/usr/bin/env v

source := dir(@FILE)
target := '${dir(@VEXE)}/vlib/'

system('rm -rf ${target}v_llama_cpp')
if system('cp -r ${source} ${target}') == 0 {
	println('[True] v_llama_cpp copy by: ${target}')
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

$if mac {
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
