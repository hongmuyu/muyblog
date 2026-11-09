---
title: "claude agent设置不同模型"
date: 2026-07-05 12:59:29
updated: 2026-11-09 13:04:11
categories:
  - 开发工具
tags:
  - "Claude Code"
  - "多模型"
toc: true
comments: true
---
## 一、为什么这样设计（先理解，再操作）

### 1.1 Claude Code 的两个"记忆位置"

Claude Code 启动时读两类信息：

- **环境变量**（`ANTHROPIC_BASE_URL`、`ANTHROPIC_AUTH_TOKEN` 等）→ 决定**连哪个服务器**
- **`$HOME/.claude/` 目录** → 存**登录凭证、对话历史、配置**

两类信息必须**配套**。如果环境变量指向 Moonshot，而`.claude/` 里却有 Anthropic Max Plan 的登录态，就会冲突——轻则报错，重则把 Max Plan 的 token 发到 Moonshot 服务器（**凭证泄漏风险**）。

### 1.2 解决方案：两套`$HOME`，两套`.claude/`

利用 Linux 一个特性：**软件去哪找"家"，看`$HOME` 这个环境变量**。我们临时把`$HOME` 拨向不同位置，让两套配置物理隔离：

```
/home/ykn-u/                          ← 真家（Max Plan 住这里）
├── .claude/                          
│   └── Anthropic 登录态、配置、历史
│
└── .claude-kimi-home/                ← 假家（Kimi 住这里）
    └── .claude/                      
        └── Moonshot 配置、历史
```

**两个`.claude/` 互不知道对方存在，零污染。**

### 1.3 进程隔离 = 窗口隔离

每个终端窗口 = 一个独立的 bash 进程。**环境变量只在自己进程里生效**，新开窗口自动回到系统默认状态（`$HOME=/home/ykn-u`）。

**直接推论**：开两个窗口，一个跑 Kimi、一个跑 Max Plan，**完全独立、可同时运行、互不干扰**。这是对比测试最理想的形态。

---

## 二、一次性准备（只做一遍）

### 2.1 装官方 Claude Code

```bash
npm install -g @anthropic-ai/claude-code
claude --version    # 验证装上了
```

### 2.2 建 Kimi 的"假家"

```bash
mkdir -p ~/.claude-kimi-home
```

空壳子就行，Claude Code 第一次跑会自己往里写东西。

### 2.3 在`~/.bashrc` 末尾加两个函数

```bash
# 用 Kimi 跑 Claude Code
kimi() {
  export ANTHROPIC_BASE_URL="https://api.moonshot.cn/anthropic"
  export ANTHROPIC_AUTH_TOKEN="sk-换成你的Kimi真实key"
  export ANTHROPIC_MODEL="kimi-k2.5"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="kimi-k2.5"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="kimi-k2.5"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="kimi-k2.5"
  export CLAUDE_CODE_SUBAGENT_MODEL="kimi-k2.5"
  export ENABLE_TOOL_SEARCH="false"
  export HOME="$HOME/.claude-kimi-home"
  claude "$@"
}

# 用 Max Plan 跑官方 Claude Code
cc() {
  claude "$@"
}

# 或者kimi的：这种写法叫**前缀变量赋值**。所有这些变量**只对紧跟其后的 `claude` 命令**生效。`claude` 一退出，变量全部消失——不会污染你当前的终端窗口。
kimi() { ANTHROPIC_BASE_URL=[https://api.moonshot.cn/anthropic](https://api.moonshot.cn/anthropic) \ ANTHROPIC_AUTH_TOKEN=sk-换成你的Kimi真实key \ ANTHROPIC_MODEL=kimi-k2.5 \ ANTHROPIC_DEFAULT_OPUS_MODEL=kimi-k2.5 \ ANTHROPIC_DEFAULT_SONNET_MODEL=kimi-k2.5 \ ANTHROPIC_DEFAULT_HAIKU_MODEL=kimi-k2.5 \ CLAUDE_CODE_SUBAGENT_MODEL=kimi-k2.5 \ ENABLE_TOOL_SEARCH=false \ HOME=$HOME/.claude-kimi-home \ claude "$@" }
```

> ⚠️ 重点：
>
> - 国内用`api.moonshot.cn`，海外用`api.moonshot.ai`
> -`kimi` 函数里**最后一行**是`export HOME=...`，把家指向假家
> -`cc` 函数里**什么都不改**，用真家、走 Max Plan 订阅

### 2.4 生效并验证

```bash
source ~/.bashrc
type kimi    # 应输出: kimi is a function 加函数体
type cc      # 应输出: cc is a function 加函数体
```

 要再加一个（比如智谱 GLM），照这个模板抄就行

```bash
 # 智谱 (Zhipu) - 模型 glm-5.1
zhipu() {
  export ANTHROPIC_BASE_URL="https://open.bigmodel.cn/api/anthropic"
  export ANTHROPIC_AUTH_TOKEN="换成你的智谱API Key"                      # 请填写你的智谱 API Key
  export ANTHROPIC_MODEL="glm-5.1"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-5.1"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-5.1"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-5.1"
  export CLAUDE_CODE_SUBAGENT_MODEL="glm-5.1"
  export HOME="$HOME/.claude-zhipu-home"
  claude "$@"
}
```
  然后让配置生效：

  source ~/.bashrc

  之后终端敲 zhipu 就是在用智谱 GLM 了，跟 kimi、cc 三者互不干扰。

---

  加新模型的"万能套路"（记住这 4 步就够了）

  1. 复制 kimi 那个函数，改个新名字（比如 zhipu、deepseek）
  2. 改地址 ANTHROPIC_BASE_URL → 换成对方家的 Anthropic 兼容地址
  3. 改 key 和模型名 → 换成对方平台给你的 key 和模型名
  4. 改家目录 HOME=$HOME/.claude-xxx-home → 名字别和已有的重复 ★ 这步最容易忘，忘了就会和别的串台

  各家地址参考（都是 Anthropic 兼容接口）：

  ┌──────────────────┬────────────────────────────────────────┬───────────────┐
  │       厂商       │                BASE_URL                │  常用模型名   │
  ├──────────────────┼────────────────────────────────────────┼───────────────┤
  │ Kimi（月之暗面） │ https://api.moonshot.cn/anthropic      │ kimi-k2.5     │
  ├──────────────────┼────────────────────────────────────────┼───────────────┤
  │ 智谱 GLM         │ https://open.bigmodel.cn/api/anthropic │ glm-4.6       │
  ├──────────────────┼────────────────────────────────────────┼───────────────┤
  │ DeepSeek         │ https://api.deepseek.com/anthropic     │ deepseek-chat │
  └──────────────────┴────────────────────────────────────────┴───────────────┘

  ▎ 提醒：模型名和地址各家偶尔会调整，如果敲了之后报错 model not found 或
  ▎ 404，去对应平台的官方文档确认下当前的"模型名 / Anthropic
  ▎ 接口地址"再改一下就行。需要的话我可以帮你现查智谱最新的模型名和接口地址，确保一次配对。
