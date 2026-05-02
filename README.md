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

## Installation

### Prerequisites

Ensure [llama.cpp](https://github.com/ggerganov/llama.cpp) (dynamic library) is compiled and installed on your system.

### Install v_llama_cpp

It is recommended to obtain the source code under the `./v/vlib/` path:

```bash
git clone https://github.com/sakana-ctf/v_llama_cpp
Direct installation [future]
bash
v install v_llama_cpp
Usage
Example
Here is a basic example: ./examples/test_qwen2.5_1.5b.v. You need to download the model file in GGUF format and place it in the ./examples/ directory. Recommended sources include:

https://modelscope.cn
https://huggingface.co/models

