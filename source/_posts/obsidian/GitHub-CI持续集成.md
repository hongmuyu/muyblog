---
title: "GitHub CI（持续集成）"
date: 2026-07-05 12:59:29
updated: 2026-07-05 12:59:29
permalink: /notes/GitHub-CI持续集成/
categories:
  - 🛠️ 服务器与运维
tags: []
toc: true
comments: true
---
## 作用

代码提交后自动执行：

```text
测试(Test)
检查(Lint)
构建(Build)
部署(Deploy，可选)
```

保证代码质量。

---

## GitHub CI = GitHub Actions

配置文件：

```text
.github/workflows/*.yml
```

例如：

```text
.github/workflows/ci.yml
```

---

## 核心概念

### Workflow（工作流）

完整自动化流程。

### Event（触发器）

```yaml
on:
  push
  pull_request
```

### Job（任务）

一组操作。

### Step（步骤）

具体执行命令。

---

## 典型流程

```text
git push
    ↓
GitHub Actions
    ↓
Lint
    ↓
Test
    ↓
Build
    ↓
(Deploy)
```

---

## 常用 Action

```yaml
actions/checkout
```

拉取代码

```yaml
actions/setup-python
```

配置 Python

```yaml
actions/setup-node
```

配置 Node.js

---

## CI vs CD

|CI|CD|
|---|---|
|持续集成|持续部署|
|自动测试、构建|自动上线|
|保证代码质量|自动发布|

---

## 一句话

> GitHub CI 本质是通过 GitHub Actions，在代码 Push 或 PR 时自动执行测试、检查和构建流程。
