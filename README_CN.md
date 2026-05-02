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

### 前提条件

系统已编译安装好 [llama.cpp](https://github.com/ggerganov/llama.cpp)（动态库）。

### 安装 v_llama_cpp

推荐在`./v/vlib/`路径下获取源码:

```bash
git clone https://github.com/sakana-ctf/v_llama_cpp
```

### 直接安装[future]

```bash
v install v_llama_cpp
```

## 使用方法

### 示例

以下提供了一个基本案例: `./examples/test_qwen2.5_1.5b.v`, 你需要下载 GGUF 格式的模型文件存放在`./examples/`文件。推荐以下来源：

- https://modelscope.cn
- https://huggingface.co/models
