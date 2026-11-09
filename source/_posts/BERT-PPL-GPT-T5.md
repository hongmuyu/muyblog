---
title: "BERT，PPL，GPT，T5"
date: 2026-06-04 22:42:40
updated: 2026-11-09 13:04:11
categories:
  - AI大模型
tags:
  - "BERT"
  - "GPT"
  - "T5"
  - "预训练模型"
toc: true
comments: true
---
BERT = 用双向 Transformer + 填空训练，让模型真正理解上下文

两个预训练过程：MLM和NSP，前者是根据上下文预测当前空所需的词，后者是判断前后两个句子是否衔接，逻辑自洽

不适合生成任务，因为生成是序列预测，MLM是局部预测，推理时需要一个一个词生成

![PPL公式.png](/images/notes/BERT-PPL-GPT-T5/PPL公式.webp)

GPT是生成模型

T5=BERT+GPT，理解和生成都很强，输入文本——>输出文本

SFT——>model——>{Q,A}——>RM

RM奖励模型训练，对GPT的每个问题的回答组进行人工分数标注，再对RM进行监督微调，能够产生人工标注同样的效果即可
