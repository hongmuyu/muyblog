---
title: "Ubuntu 中 apt 无法更新"
date: 2026-03-31 20:47:29
updated: 2026-03-31 20:47:29
categories:
  - 🛠️ 服务器与运维
tags: []
toc: true
comments: true
---
## Ubuntu 中 apt 无法更新：Clash Verge 端口不一致导致的代理失败问题分析

## 背景

在 Ubuntu 系统中执行`sudo apt update` 时，出现大量如下警告：

```text
W: 无法下载 https://download.docker.com/linux/ubuntu/dists/jammy/InRelease
无法连接上 127.0.0.1:7890 (127.0.0.1) - connect (111: 连接被拒绝)
```

涉及的源包括但不限于：

- Docker

- Google Chrome

- Microsoft VS Code

- Launchpad PPA

表面看起来像是**网络问题或源不可用**，但实际上这是一个**典型的本地代理端口配置错误**问题。

---

## 问题现象

所有 apt 源在更新时均失败，并统一报错：

```text
connect (111: 连接被拒绝)
```

注意关键信息：

- 代理地址：`127.0.0.1`

- 代理端口：`7890`

- 错误类型：连接被拒绝（Connection refused）

这说明：

> apt 正在尝试通过本机代理访问网络，但该端口并没有服务在监听。

---

## 根本原因分析

### 1. Clash Verge 的实际代理端口

在 Clash Verge 的 **系统代理设置** 中可以看到：

- 系统代理：已启用

- 代理地址：`127.0.0.1:7897`

也就是说：

> Clash Verge 当前 **HTTP 代理端口是 7897，而不是 7890**

### 2. apt 的代理配置仍使用旧端口

apt 的代理通常通过以下文件配置：

```bash
/etc/apt/apt.conf.d/99proxy
```

原内容往往是教程里常见的旧配置：

```conf
Acquire::http::Proxy "http://127.0.0.1:7890/";
Acquire::https::Proxy "http://127.0.0.1:7890/";
```

于是形成了一个致命不匹配：

|组件|使用端口|
|---|---|
|Clash Verge|7897|
|apt|7890|

👉 **apt 去敲一个根本不存在的端口，必然失败**

---

## 为什么“系统代理已开启”也没用？

这是很多人会误解的一点：

- GUI 系统代理（Clash Verge / GNOME Settings）

- ❌ **apt 不会自动读取**

- ❌ apt 是纯 CLI 工具，只认`/etc/apt/apt.conf.d/`

所以即便系统代理显示“已启用”，apt 依然可能完全不可用。

---

## 解决方案：修正 apt 代理端口

### 1. 找到代理配置文件

```bash
ls /etc/apt/apt.conf.d/ | grep -i proxy
```

通常是：

```text
99proxy
```

### 2. 编辑并修改端口

```bash
sudo nano /etc/apt/apt.conf.d/99proxy
```

修改为：

```conf
Acquire::http::Proxy "http://127.0.0.1:7897/";
Acquire::https::Proxy "http://127.0.0.1:7897/";
```

### 3. 更新测试

```bash
sudo apt update
```

若 Clash 正常运行，此时应恢复正常。
