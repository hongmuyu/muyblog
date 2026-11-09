---
title: "AI大模型原理与API使用"
date: 2026-06-04 22:42:40
updated: 2026-06-04 22:42:40
permalink: /notes/AI大模型原理与API使用/
categories:
  - 🤖 大模型与 AI
tags: []
toc: true
comments: true
---
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
