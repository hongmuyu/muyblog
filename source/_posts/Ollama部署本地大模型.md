---
title: "Ollama部署本地大模型"
date: 2026-06-04 22:42:40
updated: 2026-06-04 22:42:40
categories:
  - 🤖 大模型与 AI
tags: []
toc: true
comments: true
---
## 在本地windows电脑通过Ollama部署Deepseek，qwen和gpt等大模型

- [1. 整体描述](https://adg.csdn.net/69524b945b9f5f31781b6953.html#1__1)
- [2. 部署步骤](https://adg.csdn.net/69524b945b9f5f31781b6953.html#2__9)
- - [2.1 下载Ollama](https://adg.csdn.net/69524b945b9f5f31781b6953.html#21_Ollama_10)
    - [2.2 安装Ollama](https://adg.csdn.net/69524b945b9f5f31781b6953.html#22_Ollama_13)
    - [2.3 修改模型储存路径（推荐）](https://adg.csdn.net/69524b945b9f5f31781b6953.html#23__21)
    - - [方法一：使用命令行修改](https://adg.csdn.net/69524b945b9f5f31781b6953.html#_22)
        - [方法二：通过图形界面设置](https://adg.csdn.net/69524b945b9f5f31781b6953.html#_28)
    - [2.4 验证](https://adg.csdn.net/69524b945b9f5f31781b6953.html#24__30)
    - [2.4 下载模型](https://adg.csdn.net/69524b945b9f5f31781b6953.html#24__37)
    - [2.5 模型测试](https://adg.csdn.net/69524b945b9f5f31781b6953.html#25__52)
    - - [Ollama应用测试](https://adg.csdn.net/69524b945b9f5f31781b6953.html#Ollama_54)
        - [Ollama接口测试](https://adg.csdn.net/69524b945b9f5f31781b6953.html#Ollama_57)
- [3 总结](https://adg.csdn.net/69524b945b9f5f31781b6953.html#3__102)

## 1. 整体描述

想在本地部署一个大模型，使用Ollama，Ollama是一个开源工具，主要用于本地化部署和运行大型语言模型（LLM），支持模型量化、微调及RAG应用等操作。并且Ollama可以使用CPU跑各个大模型，不需要GPU就可以在本地电脑运行。
当然肯定是和电脑配置有关。我的电脑的配置是：
联想小新pro14 GT
CPU：Intel Core Ultra 9 285H
显卡：Intel Arc 140T GPU
内存：32G
网上有很多Core Ultra 9 285H部署大模型的测试，说是能跑20B模型，等部署完可以看下能跑到什么程度。

## 2. 部署步骤

### 2.1 下载Ollama

Ollama官网：[Ollama](https://ollama.com)
点击Download，选择自己的电脑版本相应的Ollama安装包。

### 2.2 安装Ollama

这里由于Ollama默认安装到C盘，修改安装路径。
以管理员身份打开 PowerShell 或命令提示符（CMD）。这很重要，否则可能因权限不足导致安装失败。切换到你想要安装的目录，比如D:\Ollama，执行：

.\OllamaSetup.exe /DIR="D:\ollama"

命令执行后，会弹出图形化的安装界面，点击 “Install” 即可开始安装。

### 2.3 修改模型储存路径（推荐）

#### 方法一：使用命令行修改

在 管理员身份 运行的 PowerShell 或 CMD 中，输入以下命令（注意变量值是你想存放模型的具体路径）：

setx OLLAMA_MODELS "D:\ollama\models"

或者在Windows的环境变量窗口修改。

#### 方法二：通过图形界面设置

打开Ollama程序，在Settings选项卡，也有Model Location的设置，可以在这里修改。

### 2.4 验证

在命令行输入：

ollama -v

正常出现版本号，就说明安装成功了。
![ollama版本号](https://i-blog.csdnimg.cn/direct/2d774f5af3ac45e49b5a2297b7efb9f4.png)

### 2.4 下载模型

安装之后就可以在Ollama下载模型了，Ollama的模型仓库提供了基本我们需要的所有模型。模型仓库的地址：[Ollama模型仓库](https://ollama.com/search)
比如下载Deepseek R1模型：
![Deepseek R1模型](https://i-blog.csdnimg.cn/direct/249644f17ed14224948828c3f7b5bba5.png)
这里面有很多个，不同参数量的模型，个人电脑根据电脑的配置不同，可以选择不同参数的模型，建议个人电脑选择30b以下的模型进行部署。
这里我们下载一个1.5b的模型验证一下，点击1.5b模型，在下面复制命令：
![deepseek 1.5b](https://i-blog.csdnimg.cn/direct/8270ecdf9f664f5db7027903dd9384cf.png)
然后在命令行直接执行，Ollama就会自动下载这个模型，等待下载完成即可。
下载之后，执行：

ollama list

可以查询当前电脑安装的模型列表。
![模型列表](https://i-blog.csdnimg.cn/direct/fd6590f75dd949728cec812fd9d877f2.png)

### 2.5 模型测试

下载完成之后，可以测试下这个模型，有两种测试方式

#### Ollama应用测试

可以在Ollama聊天页面，选择下载的模型直接提问：
![Ollama页面](https://i-blog.csdnimg.cn/direct/55a3313dcc324c11a217f622e9016417.png)

#### Ollama接口测试

接口测试，我们需要先在Ollama应用里面，把这个选项打开：
![Ollama设置](https://i-blog.csdnimg.cn/direct/ee1407d4d19a4968991e2071dd8fd868.png)
然后就可以使用接口调试工具进行测试了，我这用Apifox调用一下：
Ollama默认的接口地址是11434，直接调用即可：
调用地址：

http://localhost:11434/api/chat

请求Body：

{
    "model": "deepseek-r1:1.5b",
    "messages": [
        {
            "role": "user",
            "content": "你好，请介绍一下你自己"
        }
    ],
    "stream": false
}

返回：

{
    "model": "deepseek-r1:1.5b",
    "created_at": "2025-11-18T03:24:08.1200021Z",
    "message": {
        "role": "assistant",
        "content": "您好！我是由中国的深度求索（DeepSeek）公司开发的智能助手DeepSeek-R1。如您有任何任何问题，我会尽我所能为您提供帮助。"
    },
    "done": true,
    "done_reason": "stop",
    "total_duration": 2772747600,
    "load_duration": 1945882200,
    "prompt_eval_count": 7,
    "prompt_eval_duration": 50844500,
    "eval_count": 40,
    "eval_duration": 714565300
}

![调用示例](https://i-blog.csdnimg.cn/direct/e03fc2d66e014495ba008b4ff5f45f87.png)

## 3 总结

这里就简单讲下，Ollama安装和调用模型相关，当然，也可以下载其他模型测试下，然后后面可以把自己本地的模型接入Dify，这样就不用为调用Token收费而烦恼了，但是本地模型能力有限，自己抉择吧。
