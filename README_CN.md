# v_llama_cpp

<div align="center">
<img src="https://img.shields.io/github/stars/sakana-ctf/v_llama_cpp?style=flat-square&amp;logo=github&amp;color=green&amp;logoSize=14" alt="License" height="20">
</div>

[English](README.md)|中文

v_llama_cpp 是 [llama.cpp](https://github.com/ggerganov/llama.cpp) 的 V 语言绑定，让你可以在 V 语言项目中直接使用 llama.cpp 的功能。

## llama.cpp 是什么？

[llama.cpp](https://github.com/ggerganov/llama.cpp) 是一个用 C++ 实现的 LLM（大语言模型）推理框架，主要特点：

- **纯 CPU 推理**：无需 GPU 也能运行大模型
- **量化支持**：支持 INT4、INT5、INT8 等量化格式，大幅降低内存需求
- **跨平台**：支持 Windows、Linux、macOS，甚至移动端
- **高效性能**：针对普通硬件优化，普通笔记本也能运行

简单说，llama.cpp 让你能在消费级硬件上本地运行 Deepseek、Qwen、ChatGLM 等大模型。

## 安装

### 自行配置

推荐使用git下载源码:

```bash
# Github下载
git clone https://github.com/sakana-ctf/v_llama_cpp
# 国内可使用Gitee下载
git clone https://gitee.com/sakana_ctf/v_llama_cpp
```

构建并检测llama.cpp环境, 如果没有llama.cpp环境将尝试进行安装:

```bash
v build.vsh
```

> 注意: 一般情况vlang在特殊路径或安装llama.cpp需要root权限, 建议使用`sudo v build.vsh`

### 直接安装[future]

未来计划使用以下命令直接安装:

```bash
v install v_llama_cpp
```

## 使用方法

### 示例

在`./examples/`文件夹中提供了一些基本案例, 以下是一个最简易的调用方式: `./examples/ez_simple.v`:

```v
module main

import os
import v_llama_cpp {
        ModelUrl,
}

fn main() {
        model_url := ModelUrl{
                url:     [
                        'https://www.modelscope.cn/models/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/master/DeepSeek-R1-Distill-Qwen-1.5B-Q2_K.gguf',
                        'https://huggingface.co/unsloth/DeepSeek-R1-Distill-Qwen-1.5B-GGUF/resolve/main/DeepSeek-R1-Distill-Qwen-1.5B-Q2_K.gguf',
                ]
                sha256: '6b01273c847100f7e594c34869670430fc3597b3897f839664ed4ba4588f5c54'
        }
        model_path := './DeepSeek-R1-Distill-Qwen-1.5B-Q2_K.gguf'
        mut ctx := ModelUrl(model_url).ez_load_model(model_path, -1, 2048, 512) or {
                println('load model failed.')
                return
        }
        defer { ctx.free() }
        input_buffer := os.input('>')
        prompt := '<｜User｜>${input_buffer}<｜Assistant｜>'
        print('deepseek:')
        v_llama_cpp.ez_response(ctx, prompt, 512, 256, print_token) or { println('response failed.') }
}

fn print_token(token string) {
        print(token)
}
```

模型文件将自动下载到程序所在的'./DeepSeek-R1-Distill-Qwen-1.5B-Q2_K.gguf'目录下。推荐从以下来获取模型文件：

- https://modelscope.cn
- https://huggingface.co/models
