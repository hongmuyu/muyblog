---
title: "OpenAI API 接口参考"
date: 2026-03-31 20:52:54
updated: 2026-11-09 13:04:11
categories:
  - AI大模型
tags:
  - "LLM API"
  - "OpenAI"
toc: true
comments: true
---
## 一、OpenAI 接口规范（核心要点）

### 1. 基础调用方式（HTTP API）

- 协议：HTTPS

- 方法：POST

- 认证：Bearer Token（API Key）

```http
POST https://api.openai.com/v1/responses
Authorization: Bearer YOUR_API_KEY
Content-Type: application/json
```

---

### 2. 统一接口模型（推荐使用 Responses API）

```json
{
  "model": "gpt-4.1",
  "input": "写一段Python代码，实现快速排序"
}
```

---

### 3. 多模态输入结构

```json
{
  "model": "gpt-4.1",
  "input": [
    {
      "role": "user",
      "content": [
        {"type": "text", "text": "这张图里有什么？"},
        {"type": "image_url", "image_url": "https://..."}
      ]
    }
  ]
}
```

---

### 4. Tool / Function Calling（关键能力）

```json
{
  "model": "gpt-4.1",
  "input": "帮我查天气",
  "tools": [
    {
      "type": "function",
      "name": "get_weather",
      "description": "获取天气",
      "parameters": {
        "type": "object",
        "properties": {
          "city": {"type": "string"}
        },
        "required": ["city"]
      }
    }
  ]
}
```

👉 返回结果包含：

- tool call（函数调用意图）

- arguments（参数）

---

### 5. 流式输出（Streaming）

```http
stream: true
```

支持 SSE（Server-Sent Events）

---

### 6. Embedding 接口（向量）

```http
POST /v1/embeddings
```

```json
{
  "model": "text-embedding-3-small",
  "input": "AI agent 能力检索"
}
```

👉 用于你系统的：

- Skill 向量索引（Qdrant）

---

### 7. 关键设计特点（对你很重要）

- 统一 JSON schema

- 强 tool calling（适合 Agent）

- 多模态原生支持

- 流式输出

- 标准 REST 风格

---

## 二、OpenAI 兼容接口（重点）

很多厂商直接 **兼容 OpenAI API 格式**（你可以无缝切换）

---

### 1. 完全兼容（强兼容层）

这些可以直接替换`base_url`：

#### ① Anthropic（部分兼容 via SDK）

- 原生不是 OpenAI 格式

- 但很多中间层已适配

---

#### ② DeepSeek

- ✅ 高度兼容 OpenAI API

- 支持：

    - /chat/completions

    - function calling（部分）

- 常用于低成本替代

---

#### ③ Moonshot AI

- ✅ OpenAI 风格接口

- 中文能力强

- 支持长上下文

---

#### ④ Zhipu AI

- 基本兼容

- 部分字段不同

---

#### ⑤ Alibaba Cloud（通义千问）

- 提供 OpenAI 兼容模式

- 需指定 endpoint

---

#### ⑥ Baidu

- ❌ 不完全兼容

- 需要适配层

---

### 2. 开源模型网关（强推荐）

#### ① vLLM

- ✅ 完全兼容 OpenAI API

- 本地部署模型

- 支持：

    - /chat/completions

    - embeddings

---

#### ② FastChat

- OpenAI 风格 API

- 多模型统一接口

---

#### ③ LiteLLM

- 🔥 强烈推荐

- 统一：

    - OpenAI

    - Anthropic

    - Azure

    - HuggingFace

👉 你可以做：

```text
你的 Indexer Hub
        ↓
    LiteLLM
        ↓
多模型统一调度
```

---

## 三、对你系统的关键意义（重点）

你的系统是：

> 👉 **能力路由层（Capability Router）**

所以必须做到：

---

### 1. 接口统一（必须）

统一成 OpenAI 格式：

```json
{
  "model": "",
  "input": "",
  "tools": []
}
```

👉 所有 Skill / Agent：

- 最终都要“包装成 OpenAI 调用形式”

---

### 2. Skill 标准化（关键）

GitHub skill → 转换为：

```json
{
  "type": "function",
  "name": "xxx",
  "parameters": {}
}
```

👉 直接接入 tool calling

---

### 3. Agent 可插拔（核心）

任何支持 OpenAI API 的模型：

都可以作为：

- 推理引擎

- 调度 Agent

---

### 4. 你的系统未来形态

```text
用户Agent
   ↓
Indexer Hub（你）
   ↓
Skill / Agent
   ↓
OpenAI-compatible API
   ↓
执行
```

---

## 四、一句话总结

> OpenAI API 已经成为：
>
> 👉 **AI 世界的“HTTP 标准接口”**
>
> 你的系统必须围绕它设计，才能实现：
>
> - 多模型兼容
>

- Skill 可调用

- Agent 可编排
