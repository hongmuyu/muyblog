---
title: "Attention Is All You Need"
date: 2026-07-05 12:59:29
updated: 2026-07-05 12:59:29
categories:
  - 🤖 大模型与 AI
tags: []
toc: true
comments: true
---
对于 Transformer 的输入张量 (N, L, C)，其中 N 是句子数（Batch Size），L 是序列长度（Token 数），C 是特征维度（Embedding 维度）。
BatchNorm 的本质是固定某个特征维度 C，观察所有样本在该特征上的分布X[:,:,c]。几何上相当于从三维立方体中切出一个平行于 NL 的平面（垂直于 C 轴），然后在这个平面上计算均值和方差。我的理解是：固定特征，看不同样本（句子、Token）之间的差异。
LayerNorm 的本质是固定一个具体的 Token，即固定 (N, L) 坐标，只保留该 Token 的全部特征向量 X[n,l,:]。几何上相当于从立方体中抽出一条沿 C 轴的线，然后在这条线上计算均值和方差。我的理解是：固定样本（准确说固定一个 Token），看该 Token 内部各个特征维度的相对强弱关系。Transformer 使用 LayerNorm，本质上是在让每个 Token 独立完成归一化，不受其他样本影响。

One-Hot Encoding
1. **第一步（1-of-N 编码）**：词表里有 5 万个词（N=50000），“苹果”这个词会被表示为一个极其稀疏、长度为 5 万的 1-of-N 向量（只有属于“苹果”的那个位置是 1，其余都是 0）。
2. **第二步（Embedding 降维）**：这个 5 万维的 1-of-N 向量太庞大、太稀疏了，而且无法表达语义。于是，模型通过一个线性矩阵，把这个 1-of-N 向量压缩映射成一个 768 维的稠密连续向量。这个过程，就是从 **1-of-N Encoding** 进化到了 **Embedding**！
