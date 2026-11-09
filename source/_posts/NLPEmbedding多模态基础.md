---
title: "NLP、Embedding、多模态基础"
date: 2026-06-04 22:42:40
updated: 2026-06-04 22:42:40
categories:
  - 🤖 大模型与 AI
tags: []
toc: true
comments: true
---
## 1. 中文文本处理

### jieba

Python 中最常用的中文分词工具。

核心功能：

- 中文分词

- 自定义词典

- 词性标注

- 关键词提取

常见模式：

|模式|特点|
|---|---|
|精确模式|最常用，尽量准确切词|
|全模式|把所有可能词语都切出来|
|搜索引擎模式|适合搜索/RAG召回|

作用：

```text
原始文本
→ 分词
→ Token
→ 后续 NLP 处理
```

---

## 2. 词向量与语义表示

### Gensim

经典 NLP 工具库。

核心能力：

- Word2Vec

- Doc2Vec

- Topic Modeling（LDA）

- 相似度计算

---

### Word2Vec

核心思想：

> 将词语转换为低维稠密向量。

例如：

```text
“国王 - 男人 + 女人 ≈ 王后”
```

说明：

- 向量可以表达语义关系

- 语义接近 → 向量距离接近

本质：

```text
词
→ 向量
→ 语义空间
```

---

## 3. Embedding 核心理解

### Embedding

Embedding 本质：

> 把文本/图片/音频等数据转换成语义向量。

作用：

- 语义检索

- RAG

- 推荐系统

- 相似度匹配

- 长期记忆

核心逻辑：

```text
语义越接近
→ 向量距离越近
```

---

## 4. Tokenizer → Embedding → LLM

完整流程：

```text
文本
→ Tokenizer
→ Token ID
→ Embedding
→ Transformer
→ 输出
```

---

### Tokenizer

作用：

> 将文本切分成 token。

例如：

```text
“我喜欢AI”
→ ["我", "喜欢", "AI"]
```

再映射成：

```text
[1024, 5831, 991]
```

---

### Embedding 不是“降维”

Embedding 本质是：

> 离散 ID → 高维稠密语义向量

例如：

```text
1024
→ [0.12, -0.44, ...]
```

通常反而是升维：

```text
Token ID
→ 768维 / 4096维向量
```

---

## 5. LLM 与 Embedding 模型区别

|类型|核心职责|
|---|---|
|Embedding Model|检索、相似度、召回|
|LLM|推理、生成、Agent决策|

---

Embedding 模型：

```text
更偏“语义理解”
```

LLM：

```text
更偏“推理生成”
```

因此：

- LLM 通常参数更大

- Embedding 更轻量

- RAG 常组合二者

本质分工：

```text
LLM：大脑
Embedding：记忆/检索系统
```

---

## 6. Metadata（元数据）

### Metadata

Metadata 是：

> 描述数据的数据。

例如：

```json
{
  "content": "Transformer论文",
  "metadata": {
    "作者": "OpenAI",
    "时间": "2026",
    "标签": ["AI", "LLM"]
  }
}
```

---

RAG 核心：

```text
Embedding = 语义检索
Metadata = 条件过滤
```

即：

```text
“像不像”
+
“符不符合条件”
```

---

## 7. 多模态 Embedding

核心思想：

```text
文本 / 图片 / 音频
→ 同一语义空间
```

实现：

- 文搜图

- 图搜文

- 多模态 RAG

- Agent 长期记忆

---

### CLIP

经典图文对齐模型。

作用：

- 图文统一 embedding

- 零样本文图检索

- 多模态检索

---

### ResNet

经典 CNN Backbone。

核心：

> 残差连接（Skip Connection）

y = F(x) + x

解决：

- 深层网络难训练

- 梯度消失

CLIP 常用 ResNet 作为图像编码器。

---

代表模型：

- CLIP

- Google ALIGN

- BAAI BGE-VL

---

## 8. Jina Embeddings 与 Matryoshka

### Jina AI Embeddings

特点：

> 支持自由裁剪 embedding 维度。

例如：

```text
1024维
→ 512维
→ 256维
```

依然保持较强语义能力。

---

核心技术：

### Matryoshka Representation Learning

思想类似：

```text
俄罗斯套娃
```

高维向量中：

- 前面部分已经包含核心语义

- 后续维度逐渐补充细节

因此可以：

- 动态裁剪维度

- 降低存储成本

- 提高检索效率

非常适合：

- 大规模向量库

- RAG

- Agent Memory

- 多端部署
