---
title: "Claude Code + DeepSeek API 完整配置笔记（Linux 无地区限制版）"
date: 2026-06-04 22:42:40
updated: 2026-11-09 13:04:11
categories:
  - 开发工具
tags:
  - "Claude Code"
  - "API 配置"
toc: true
comments: true
---
> **适用场景**：Linux 服务器 / 桌面，想用 Claude Code 但遇到 “地区不可用” 提示。
> **核心思路**：用 npm 安装 Claude Code，API 走 DeepSeek（兼容 Anthropic 协议）→ 不限地区，成本更低，纯命令行。

---

## 一、前置要求

- **操作系统**：Ubuntu / Debian 系 Linux（其他发行版可对照修改包管理器命令）
- **用户**：普通用户（**不要**一直在 root 下操作，环境变量配在普通用户的`~/.bashrc`）
- **网络**：能正常访问 DeepSeek API 即可（无需特殊网络）

---

## 二、安装 Node.js 22

### 1. 以 root 权限执行 NodeSource 安装脚本（注意整个命令要一起提权）
```bash
sudo bash -c "$(curl -fsSL https://deb.nodesource.com/setup_22.x)"
```

> **踩坑提醒**：
> ❌ 错误写法：`sudo curl ... | bash -` → 后面的 bash 仍是普通用户，会因权限不足而报错。
> ✅ 正确写法：用`sudo bash -c "$(curl ...)"` 让整个脚本以 root 运行。

### 2. 安装 Node.js 22
```bash
sudo apt install -y nodejs
```

### 3. 验证安装
```bash
node --version   # 应显示 v22.x.x
npm --version
```

---

## 三、安装 Claude Code（通过 npm，绕开官方脚本）

```bash
npm install -g @anthropic-ai/claude-code
```

> **说明**：
> - 不要使用`curl https://claude.ai/install.sh | bash`，该脚本会因地区限制返回 HTML 报错。
> - npm 包会从 Anthropic 官方仓库下载编译好的二进制文件，**无地区检查**。
> - 如果 npm 全局安装遇到权限问题，可配置 npm 使用用户目录：
>```bash
>   mkdir ~/.npm-global
>   npm config set prefix '~/.npm-global'
>   echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
>   source ~/.bashrc
>   ```

### 验证安装
```bash
claude --version   # 应输出版本号
```

---

## 四、获取 DeepSeek API Key

1. 访问 [DeepSeek 开放平台](https://platform.deepseek.com/)
2. 注册 / 登录 → 进入 **API Keys** 页面
3. 点击 **创建 API Key**，复制以`sk-` 开头的密钥（**只显示一次，请妥善保存**）

> **安全提醒**：
> - 不要将 API Key 上传到公开代码仓库
> - 不要在聊天 / 论坛中直接粘贴完整 Key
> - 生产环境建议使用环境变量文件并限制权限（`chmod 600`）

---

## 五、配置环境变量（接入 DeepSeek API）

编辑普通用户的`~/.bashrc` 文件（**不是 root 的**）：

```bash
nano ~/.bashrc
# 如果没有 nano，可用 vi 或直接 echo 追加
```

在文件**末尾**添加以下内容（**替换`sk-你的Key` 为真实的 API Key**）：

```bash
# Claude Code + DeepSeek API 配置
export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"
export ANTHROPIC_AUTH_TOKEN="sk-你的Key"
export ANTHROPIC_MODEL="deepseek-v4-pro"
export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro"
export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro"
export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"
export CLAUDE_CODE_EFFORT_LEVEL="max"
```

保存并退出（nano 按`Ctrl+O` 回车保存，`Ctrl+X` 退出）。

### 使配置立即生效
```bash
source ~/.bashrc
```

---

## 六、启动 Claude Code

在任意项目目录下运行：
```bash
claude
```

如果一切正常，你会看到 Claude Code 的交互界面，并开始使用 DeepSeek 模型。

---

## 七、常见问题与排查

| 现象 | 可能原因 | 解决方法 |
|------|----------|----------|
|`claude: 未找到命令` | npm 全局 bin 目录不在 PATH 中 | 执行`echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc`，然后`source ~/.bashrc` |
| 启动后依然提示“地区不可用” | 环境变量未正确设置或未生效 | 检查`env \| grep ANTHROPIC`，确认五个变量都存在且值正确 |
| API 返回 401 错误 | API Key 错误或过期 | 重新检查`ANTHROPIC_AUTH_TOKEN`，确认没有多余空格 |
| API 返回 404 或超时 |`ANTHROPIC_BASE_URL` 写错 | 必须是`https://api.deepseek.com/anthropic`（结尾无斜杠） |
|`sudo npm install -g` 报错 | 不应该用 sudo 安装全局包 | 改用用户级 npm 配置（见第三节） |

---

## 八、可选：快速配置命令（一键追加）

如果你想跳过手动编辑，可以直接用以下命令一键添加配置（**注意先替换 Key**）：

```bash
echo 'export ANTHROPIC_BASE_URL="https://api.deepseek.com/anthropic"' >> ~/.bashrc
echo 'export ANTHROPIC_AUTH_TOKEN="sk-你的真实Key"' >> ~/.bashrc
echo 'export ANTHROPIC_MODEL="deepseek-v4-pro"' >> ~/.bashrc
echo 'export ANTHROPIC_DEFAULT_OPUS_MODEL="deepseek-v4-pro"' >> ~/.bashrc
echo 'export ANTHROPIC_DEFAULT_SONNET_MODEL="deepseek-v4-pro"' >> ~/.bashrc
echo 'export ANTHROPIC_DEFAULT_HAIKU_MODEL="deepseek-v4-flash"' >> ~/.bashrc
echo 'export CLAUDE_CODE_SUBAGENT_MODEL="deepseek-v4-flash"' >> ~/.bashrc
echo 'export CLAUDE_CODE_EFFORT_LEVEL="max"' >> ~/.bashrc
source ~/.bashrc
```

---

## 九、成本与模型说明

-`deepseek-v4-pro`：高性能版本，适合复杂任务
-`deepseek-v4-flash`：更快、成本更低，适合简单问答或子代理
- 详细价格请查阅 [DeepSeek 官方定价](https://platform.deepseek.com/pricing)
- 相比直接使用 Anthropic 官方 API，成本可降低 **90% 以上**

---

## 十、卸载与重置（如果需要）

```bash
# 卸载 Claude Code
npm uninstall -g @anthropic-ai/claude-code

# 移除环境变量（编辑 ~/.bashrc 删除相关行）
# 删除 npm 全局目录（如果使用了用户级）
rm -rf ~/.npm-global
```
