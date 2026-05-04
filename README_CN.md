# v_llama_cpp

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

以下提供了一个基本案例: `./examples/test_deepseek_1.5b.v`, 你需要下载 GGUF 格式的模型文件**DeepSeek-R1-Distill-Qwen-1.5B-Q2_K.gguf**存放在`./examples/`文件。推荐以下来源：

- https://modelscope.cn
- https://huggingface.co/models
