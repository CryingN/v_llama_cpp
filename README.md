# v_llama_cpp

English|[中文](./README_CN.md)

v_llama_cpp is a V language binding for [llama.cpp](https://github.com/ggerganov/llama.cpp), allowing you to directly use llama.cpp's functionality in V language projects.

## What is llama.cpp?

[llama.cpp](https://github.com/ggerganov/llama.cpp) is an LLM (Large Language Model) inference framework implemented in C++, with the following key features:

- **Pure CPU inference**: Run large models without a GPU  
- **Quantization support**: Supports INT4, INT5, INT8, and other quantization formats, significantly reducing memory requirements  
- **Cross-platform**: Works on Windows, Linux, macOS, and even mobile devices  
- **High efficiency**: Optimized for ordinary hardware, enabling operation on standard laptops  

In short, llama.cpp allows you to run large models like Deepseek, Qwen, and ChatGLM locally on consumer-grade hardware.

Here's the English translation:

## Installation

### Manual Setup

It is recommended to download the source code using git:

```bash
# Download from Github
git clone https://github.com/sakana-ctf/v_llama_cpp
# For users in China, use Gitee
git clone https://gitee.com/sakana_ctf/v_llama_cpp
```

Build and detect the llama.cpp environment. If no llama.cpp environment exists, it will attempt to install it:

```bash
v build.vsh
```

> Note: Due to special Vlang installation paths and the need for root privileges when installing llama.cpp, it is recommended to use `sudo v build.vsh`

### Direct Installation [future]

Direct installation using the following command is planned for the future:

```bash
v install v_llama_cpp
```

## Usage

### Example

The `./examples/` folder provides some basic examples. Below is the simplest way to call the module: `./examples/ez_simple.v`:

```v
module main

import os
import v_llama_cpp

fn main() {
        model_path := './DeepSeek-R1-Distill-Qwen-1.5B-Q2_K.gguf'
        ctx := v_llama_cpp.ez_load_model(model_path, -1, 2048, 512) or {
                println('load model failed.')
                return
        }
        defer { ctx.free() }
        input_buffer := os.input('>')
        prompt := '<｜User｜>${input_buffer}<｜Assistant｜>'
        print('deepseek:')
        v_llama_cpp.ez_response(
                ctx,
                prompt,
                512,
                256,
                print_token,
        ) or {
                println('response failed.')
        }
}

fn print_token(token string) {
        print(token)
}
```

You need to download the GGUF format model file **DeepSeek-R1-Distill-Qwen-1.5B-Q2_K.gguf** and place it in the program's working directory. It is recommended to download the model file from the following sources:

- https://huggingface.co/models
- https://modelscope.cn

