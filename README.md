# v_llama_cpp

<div align="center">
<img src="https://img.shields.io/github/stars/sakana-ctf/v_llama_cpp?style=flat-square&amp;logo=github&amp;color=green&amp;logoSize=14" alt="License" height="20">
</div>

English|[中文](./README_CN.md)

v_llama_cpp is the V language binding for [llama.cpp](https://github.com/ggerganov/llama.cpp), allowing you to directly use llama.cpp functionality in V language projects.

## What is llama.cpp?

[llama.cpp](https://github.com/ggerganov/llama.cpp) is an LLM (Large Language Model) inference framework implemented in C++, with the following main features:

- **Pure CPU Inference**: Run large models without a GPU
- **Quantization Support**: Supports INT4, INT5, INT8 and other quantization formats, significantly reducing memory requirements
- **Cross-Platform**: Works on Windows, Linux, macOS, and even mobile devices
- **Efficient Performance**: Optimized for ordinary hardware, runs on regular laptops

Simply put, llama.cpp allows you to run large models like Deepseek, Qwen, ChatGLM locally on consumer-grade hardware.

## Installation

### Manual Setup

It is recommended to download the source code using git:

```bash
# Download from Github
git clone https://github.com/sakana-ctf/v_llama_cpp
# For users in China, download from Gitee
git clone https://gitee.com/sakana_ctf/v_llama_cpp
```

Build and check the llama.cpp environment; if the llama.cpp environment does not exist, it will attempt to install it:

```bash
v install.vsh
```

> Note: Installing llama.cpp with vlang may require root privileges. You can use sudo v build.vsh

### Uninstall

A convenient method is now provided to uninstall the current repository:

```
v unstall.vsh
```

If you had configured v_llama_cpp before updating, it will be uninstalled first and then reinstalled during the installation process.

### Direct Installation [future]

Direct installation using the following command is planned for the future:

```bash
v install v_llama_cpp
```

## Usage

### Example

Several basic examples are provided in the `./examples/` folder. Below is the simplest calling method: `./examples/ez_simple.v`:

```v
module main

import os
import v_llama_cpp {
        ModelUrl,
}

fn main() {
        model_url := ModelUrl{
                url:     [
                        'https://www.modelscope.cn/models/bartowski/google_gemma-3-1b-it-GGUF/resolve/master/google_gemma-3-1b-it-Q4_0.gguf',
                        'https://huggingface.co/bartowski/google_gemma-3-1b-it-GGUF/resolve/main/google_gemma-3-1b-it-Q4_0.gguf',
                ]
                sha256: '4c62ce8950bc6d5ba5124a70fc13ece971fabd4dc5705477f305a6c3eb6294cd'
        }
        model_path := './google_gemma-3-1b-it-Q4_0.gguf'
        mut ctx := ModelUrl(model_url).ez_load_model(model_path, -1, 2048, 512) or {
                println('load model failed.')
                return
        }
        input_buffer := os.input('>')
        prompt := '<start_of_turn>user\n${input_buffer}<end_of_turn>\n<start_of_turn>model\n'
        print('gemma: ')
        ctx.ez_response(prompt, 512, 256, print_token) or { println('response failed.') }
}

fn print_token(token string) {
        print(token)
}
```

The model file will be automatically downloaded to the `./google_gemma-3-1b-it-Q4_0.gguf` directory where the program is located. It is recommended to obtain model files from the following sources:

- https://huggingface.co/models
- https://modelscope.cn

