#!/usr/bin/env v


fn remove_module_dirs() {
    mut vmodules_dir := home_dir() + '/.vmodules'
    $if !windows {
            if getenv('SUDO_USER') != '' {
                    original_user := getenv('SUDO_USER')
                    vmodules_dir = '/home/${original_user}/.vmodules'
            }
    }
    target := '${vmodules_dir}/v_llama_cpp'
    if exists(target) {
        println('Removing user module: ${target}')
        rmdir_all(target) or { println('[Error]  Failed: ${err}') }
    }

    sys_path := '${dir(@VEXE)}/vlib/v_llama_cpp'
    if exists(sys_path) {
        println('Removing system module: ${sys_path}')
        rmdir_all(sys_path) or {
		error('${typeof(err).name}, ${err}')
		/*
            if err.contains('permission denied') {
                println('[Error]  Permission denied, try: sudo v run ${@FILE}')
            } else {
                println('[Error]  Failed: ${err}')
            }
		*/
        }
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
    $if windows {
        if system('where winget') == 0 {
            println('Removing llama.cpp via winget...')
            system('winget uninstall --id ggerganov.llama.cpp')
        }
    }
}

fn main() {
    remove_module_dirs()
    choose := input('[Choose] Whether to attempt uninstalling the llama.cpp library from third-party package managers(Y/n): ')
    if choose.trim_space() in ['yes', 'y', 'Y'] {
	uninstall_llama_cpp()
    }
    println('[True] v_llama_cpp uninstall completed.')
}
