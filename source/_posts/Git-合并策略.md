---
title: "git合并策略"
date: 2026-07-05 12:59:29
updated: 2026-11-09 13:04:11
categories:
  - 开发工具
tags:
  - "Git"
  - "合并策略"
toc: true
comments: true
---
## 1. Create a Merge Commit（创建合并提交）

```text
main:    A---B---C-------M
                  \     /
feature:           D---E---F
```

- 保留所有提交

- 保留分支结构

- 产生一个 Merge Commit

- 历史最完整，但较杂乱

**适用：** 团队协作、需要保留开发轨迹

---

## 2. Squash and Merge（挤压并合并）

```text
main:    A---B---C---S
```

其中：

```text
S = D + E + F
```

- 多个提交压缩成一个

- 不保留开发过程

- 历史最干净

**适用：** 个人项目、AI Coding 项目

---

## 3. Rebase and Merge（变基并合并）

```text
main:    A---B---C---D'---E'---F'
```

- 保留所有提交

- 不保留分支结构

- 不产生 Merge Commit

- 历史线性、整洁

**适用：** 要求提交历史整洁的项目

---

## 一句话区别

|方式|保留提交|保留分支|Merge Commit|
|---|---|---|---|
|Merge Commit|✅|✅|✅|
|Squash|❌|❌|❌|
|Rebase|✅|❌|❌|

## 个人项目推荐

```text
开发：feature 分支
合并：Squash and Merge
```

得到：

```text
feat: 用户系统
feat: Agent注册
feat: RAG检索
```

主分支历史最干净。
