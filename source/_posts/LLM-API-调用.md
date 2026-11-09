---
title: "LLM API 调用"
date: 2026-03-31 20:45:23
updated: 2026-11-09 13:04:11
categories:
  - AI大模型
tags:
  - "LLM API"
  - "Function Calling"
toc: true
comments: true
---
## LLM API 调用（OpenAI 兼容）

## 第一部分：Function Calling 完整范式

 从 messages 流，到两次请求的工程范式

在使用 Chat Completions API 构建 **“能自己决定调用函数”的 AI** 时，一个成熟、稳定的做法是：

> **两次请求（Two-Step Call）**
> ① 让模型判断是否需要调用工具
> ② 执行工具，把结果喂回去，让模型最终回答

这篇文章完整拆解这个流程，包括：

* 为什么要 **两次 response**
* Tool Calling 的返回结构
*`messages` 流在其中的作用
*`tool_call_id` 的真实用途
* 为什么`return` 的是`message.content` 而不是`messages`

---

## 一、整体流程（先有大局观）

完整的 Tool Calling 过程可以总结为一句话：

> **模型 → 决定是否调用工具 → 人类/程序执行函数 → 把结果返回给模型 → 模型基于结果回答**

对应到代码流程就是：

```
定义函数
  ↓
将函数封装为 tools 传给模型
  ↓
messages：用户输入
  ↓
第一次请求（允许 tools）
  ↓
模型返回 tool_calls
  ↓
程序执行真实函数
  ↓
将函数结果以 role="tool" 加入 messages
  ↓
第二次请求（tool_choice="none"）
  ↓
模型基于 messages 给最终答案
```

**重点**：

> ❗ 工具不是模型在“自动执行”，而是模型“提出调用请求”，你来执行。

---

## 二、函数调用示例（Two-Step 标准范式）

```python
def function_call_playground(prompt):
    messages = [{'role': 'user', 'content': prompt}]

    # 第一次请求：允许模型调用工具
    response = client.chat.completions.create(
        model="deepseek-ai/DeepSeek-V2.5",
        messages=messages,
        temperature=0.01,
        top_p=0.95,
        stream=False,
        tools=tools
    )

    # 第二次请求：禁止工具，直接用 messages 回答
    response = client.chat.completions.create(
        model="deepseek-ai/DeepSeek-V2.5",
        messages=messages,
        temperature=0.01,
        top_p=0.95,
        stream=False,
        tool_choice="none"
    )

    return response.choices[0].message.content
```

### 为什么要两次？

* **第一次**

  * 模型只做一件事：
    👉 *“我需不需要调用工具？调用哪个？参数是什么？”*
* **第二次**

  * 模型基于：

    * 用户问题
    * 工具返回结果
  * 输出最终自然语言答案

这一步拆开，AI 的“决策”和“表达”就清晰分离了。

---

## 三、`client.chat.completions.create` 是什么？

一句话定义：

> **向聊天模型发送一次对话上下文，生成下一条 assistant 消息**

分解来看：

### 1️⃣`client`

```python
from openai import OpenAI
client = OpenAI(api_key="YOUR_API_KEY")
```

* OpenAI / 兼容 API 的客户端
* 负责和模型服务通信

### 2️⃣`.chat.completions.create(...)`

* 使用 **Chat Completions API**
* 核心输入是`messages`
* 输出是模型生成的“下一条回复”

---

## 四、messages：对话上下文的“唯一真相源”

在 Chat Completions 中：

> **模型永远只看`messages`**

```python
messages = [
  {"role": "system", "content": "你是一个严谨的数学助手"},
  {"role": "user", "content": "5 + 4 等于多少？"}
]
```

### role 含义

| role      | 含义           |
| --------- | ------------ |
| system    | 人设 / 规则 / 约束 |
| user      | 用户输入         |
| assistant | 模型回复         |
| tool      | 工具执行结果（专用）   |

👉 **tool 不是给人看的，是给模型看的**

---

## 五、第一次 response：模型请求调用工具

当模型认为需要调用函数时，返回结构是这样的：

```
response
 └── choices[0]
      ├── message
      │    ├── role = "assistant"
      │    ├── content = null
      │    └── tool_calls
      │         └── [0]
      │              ├── id = "call_abc123"
      │              ├── type = "function"
      │              └── function
      │                   ├── name = "add"
      │                   └── arguments = "{\"a\":5,\"b\":3}"
      └── finish_reason = "tool_calls"
```

### 关键点

*`content = null` ❗
  因为**模型不是在“回答”，而是在“请求工具”**
*`tool_calls` 是一个数组（可能一次要调用多个）

---

## 六、执行函数 + 写回 messages

```python
func_name = response.choices[0].message.tool_calls[0].function.name
func_args = response.choices[0].message.tool_calls[0].function.arguments

func_result = eval(f'{func_name}({func_args})')
```

### 将结果写回 messages（非常关键）

```python
messages.append(response.choices[0].message)

messages.append({
    "role": "tool",
    "content": f"{func_result}",  # 必须是字符串
    "tool_call_id": response.choices[0].message.tool_calls[0].id
})
```

---

## 七、`tool_call_id` 是干什么的？

> **用于匹配 “模型的请求” 和 “你的执行结果”**

* 模型：
  👉 “我请求调用工具 A（id=call_abc123）”
* 你返回：
  👉 “这是 call_abc123 的执行结果”

如果一次回复请求了 **多个工具**，`tool_call_id` 能防止结果错位。

---

## 八、第二次 response：禁止工具，直接回答

```python
response = client.chat.completions.create(
    model="deepseek-ai/DeepSeek-V2.5",
    messages=messages,
    tool_choice="none"
)
```

此时模型已经看到：

* 原始用户问题
* 自己刚才的工具调用意图
* 工具返回结果（role="tool"）

👉 **这一步，模型只做“语言生成”**

---

## 九、为什么传`messages`，却 return`message.content`？

这是很多人第一次都会困惑的问题。

### 1️⃣ 请求时

```python
messages=messages
```

你做的是：

> **把完整上下文喂给模型**

---

### 2️⃣ 响应时

```python
response.choices[0].message.content
```

你拿的是：

> **模型“新生成的那一条”消息**

### 这是固定结构吗？

✅ **是的，这是 Chat Completions API 的固定返回结构**

*`messages`：你维护
*`message`：模型刚生成的
*`choices[0]`：默认只取第一个候选

你不需要、也不应该直接 return messages。

---

## 十、stream 模式下的 chunk 补充

非流式：

```
response
 └── choices[0].message.content
```

流式（stream=True）：

```
response (iterator)
 ├── chunk
 │    └── choices[0].delta.content
 ├── chunk
 └── ...
```

`delta` 表示的是 **“新增的一点点内容”**。

---

## 十一、tools 的完整结构（函数声明）

```python
tools = [
  {
    "type": "function",
    "function": {
      "name": "add",
      "description": "计算两个数字之和",
      "parameters": {
        "type": "object",
        "properties": {
          "a": {"type": "number"},
          "b": {"type": "number"}
        },
        "required": ["a", "b"]
      }
    }
  }
]
```

📌 **description 写不好，模型就不会选你这个函数**

---

## 十二、一个容易被忽略的细节：Prompt 的“微差异”

```
"5 + 4 等于多少?"
"5+4等于多少"
```

对人一样，对模型不一定一样。

* 空格
* 标点
* 中文 / 英文符号

👉 **都会影响 token 切分和理解路径**

---

## 结语：为什么这个范式非常重要？

这个 Two-Step Tool Calling 模式，本质上让你实现了：

* AI 决策（用不用工具）
* 人类/程序执行（真实世界）
* AI 表达（自然语言输出）

这就是：

> **Agent 的最小可行架构**

## 第二部分：Stream 流式返回与消息角色

​

在使用大模型做应用开发时，**`stream=True` 和`stream=False` 的区别**，是很多人一开始容易迷糊、但工程里非常关键的点。
这篇文章我们用一个完整视角来讲清楚：

- 什么是流式（stream）输出？

- 返回结构到底长什么样？

- 各参数在干嘛？

- 聊天角色（system / user / assistant）怎么理解？

- 最后补一个常用的 Python API：`os.listdir`

---

## 一、什么是 stream=True？（流式返回）

当你开启`stream=True` 时，模型**不会等整段回答生成完**，而是像“打字机”一样，一小段一小段地返回内容。

### 示例代码

```
response = client.chat.completions.create(
    model="Qwen2-7B-Instruct",
    messages=messages,
    temperature=0.2,
    top_p=0.95,
    stream=True,
)
```



### 每次返回的 chunk 结构（数量不固定）

```
{
  "choices": [
    {
      "delta": {
        "content": "这是一部分内容"
      }
    }
  ]
}
```



### 📌 特点总结

- 没有完整`message`

- 内容藏在`choices[0].delta.content`

- 每个 chunk 可能只有几个字，甚至是一个字

- 非常适合：

    - Web 聊天窗口

    - 实时显示模型“正在思考”

    - 降低首字响应延迟（TTFB）

👉 **你需要自己把每个 chunk 拼起来**

---

## 二、stream=False：一次性返回完整回复（默认）

如果你关闭流式：

```
response = client.chat.completions.create(
    model="Qwen2-7B-Instruct",
    messages=messages,
    stream=False,
)
```



### 返回结构

```
{
  "choices": [
    {
      "message": {
        "role": "assistant",
        "content": "这是完整的一段回复"
      }
    }
  ]
}
```



### 📌 特点总结

- 返回的是“最终成品”

- 使用简单

- 适合：

    - 脚本

    - 批量处理

    - 后台任务 / 数据分析

---

## 三、stream=True vs stream=False 对比

| 维度    | stream=True  | stream=False |
| ----- | ------------ | ------------ |
| 返回方式  | 多次 chunk     | 一次性          |
| 延迟体验  | 很低           | 较高           |
| 使用复杂度 | ⭐⭐⭐          | ⭐            |
| 适合场景  | 聊天 UI / 实时输出 | 批处理 / 脚本     |
|       |              |              |

一句话总结：

> **做“产品感”的应用 → stream=True
> 做“工具感”的脚本 → stream=False**

---

## 四、核心参数说明

| 参数                               | 作用                       |
| -------------------------------- | ------------------------ |
|`client.chat.completions.create` | 调用聊天模型生成回复               |
|`model="Qwen2-7B-Instruct"`      | 指定模型（如你本地或服务部署的 Qwen）    |
|`messages=messages`              | 聊天上下文（对话历史）              |
|`temperature=0.2`                | 随机性控制：越小越严谨              |
|`top_p=0.95`                     | 概率截断采样，常和 temperature 搭配 |
|`stream=True`                    | 是否启用流式输出                 |

### 🎯 实战经验

- **问答 / 代码 / 推理**：`temperature = 0.1 ~ 0.3`

- **创意 / 文案 / 头脑风暴**：`temperature = 0.7 ~ 0.9`

- 一般不需要同时大幅调高`temperature` 和`top_p`

---

## 五、messages 中的角色（非常关键）

```
{
  "role": "system",
  "content": "你是一个严谨的后端工程师"
}
```



### 角色含义

|角色|含义|
|---|---|
|`system`|设定模型的身份、行为规则|
|`user`|用户输入|
|`assistant`|模型输出|

### 🧠 认知模型

可以理解为：

-`system`：**潜意识 / 人设**

-`user`：**你说的话**

-`assistant`：**模型的回答**

在工程中，**system prompt 的质量 ≈ 输出稳定性的一半**。

---

## 六、结语

如果你在写 **LLM 应用 / Agent / Web 聊天系统**：

-`stream=True` 是体验的灵魂

-`messages + system prompt` 是控制力的核心

- 参数调得好，模型才“听话”

​
## 第三部分：DashScope 与 OpenAI 接口差异

**阿里云 DashScope（灵积）平台的接口规范**，与 OpenAI 的接口有区别：

## 主要区别：

1. **导入方式不同**：
   - **DashScope**：`from dashscope.api_entities.dashscope_response import Role`
   - **OpenAI**：通常不需要导入 Role，直接用字符串`"system"`,`"user"`,`"assistant"`

2. **调用方式不同**：
   - **DashScope**：使用`dashscope.Generation.call()`
   - **OpenAI**：使用`client.chat.completions.create()`

3. **Role 类的作用**：
   - DashScope 提供了`Role` 枚举类来规范角色定义
   - OpenAI 直接使用字符串

虽然两者都兼容 OpenAI 的消息格式（role + content），但 DashScope 是阿里云自家的 SDK，可以通过代理调用 DeepSeek 等模型，而无需直接使用 OpenAI 的 SDK。

https://pypi.tuna.tsinghua.edu.cn/simple
清华大学国内镜像
