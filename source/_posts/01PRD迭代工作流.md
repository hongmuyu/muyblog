---
title: "01PRD迭代工作流"
date: 2026-07-05 12:59:29
updated: 2026-11-09 13:04:11
categories:
  - 开发工具
tags:
  - "AI 开发工作流"
  - "PRD"
toc: true
comments: true
---
核心思想：

```text
PRD
↓
挑刺
↓
问题分级
↓
修订
↓
评分
↓
继续迭代
```

而不是：

```text
PRD
↓
挑刺
↓
结束
```

因为真正有价值的是持续收敛出更好的 PRD。

## 目标

自动评审并持续迭代PRD。

最终输出：

- FINAL_PRD.md

- final_assessment.md

---

## 目录结构

iterations/
reviews/
reports/
prompts/

---

## 自动发现当前PRD

扫描：

iterations/

寻找：

PRD_v*.md

选择版本号最大的文件。

例如：

PRD_v2.md
PRD_v3.md
PRD_v4.md

则当前PRD：

PRD_v4.md

---

## 第一阶段：Review

读取当前PRD。

执行：

1. Architect Review

2. Performance Review

3. Security Review

分别使用：

prompts/architect.md
prompts/performance.md
prompts/security.md

输出：

reviews/architect_review.md

reviews/performance_review.md

reviews/security_review.md

目标：

发现问题。

不要修改PRD。

---

## 第二阶段：Issue Prioritization

读取：

当前PRD

全部Review报告

使用：

prompts/prioritize.md

输出：

reviews/prioritized_issues.md

分类：

P0
P1
P2

规则：

P0 = 不修无法上线

P1 = 建议修复

P2 = 可选优化

输出：

Top 5 Issues

---

## 第三阶段：Revision

读取：

当前PRD

全部Review报告

prioritized_issues.md

使用：

prompts/revision.md

目标：

生成下一版本PRD。

规则：

修复全部P0

尽量修复P1

忽略P2

保留原有需求

保留原有结构

新增内容标记：

[NEW]

修改内容标记：

[UPDATED]

输出：

PRD_v{N+1}.md

例如：

PRD_v2.md

↓

PRD_v3.md

---

## 第四阶段：Judge

读取：

最新生成的PRD

使用：

prompts/judge.md

输出：

reports/final_assessment.md

评分：

Product

Architecture

Performance

Security

Scalability

Maintainability

Overall

---

## 第五阶段：决策

如果：

Overall >= 8.5

执行：

生成：

FINAL_PRD.md

状态：

PASS

停止迭代

---

如果：

Overall < 8.5

状态：

CONTINUE

继续下一轮：

Review

↓

Prioritize

↓

Revision

↓

Judge

直到通过

---

## 每轮输出

Current Version

Next Version

Overall Score

Top 5 Remaining Issues

Iteration Status

PASS / CONTINUE

```
读取 WORKFLOW.md

严格按照流程执行。

自动发现 iterations 中最新版本 PRD。

完成：

Review
→ Prioritize
→ Revision
→ Judge

生成下一版本PRD和评审报告。
```
