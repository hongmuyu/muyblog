---
title: "Kaggle Notebook训练huggingface lora实例"
date: 2026-03-31 20:51:46
updated: 2026-03-31 20:51:46
categories:
  - 🤖 大模型与 AI
tags: []
toc: true
comments: true
---
## 一、你遇到的错误总结（本质统一）

## 1️⃣`evaluation_strategy` 报错

```text
TypeError: unexpected keyword argument 'evaluation_strategy'
```

本质：

```text
transformers 5.x 已移除 evaluation_strategy
```

正确写法：

```python
eval_strategy="epoch"
```

---

## 2️⃣`tokenizer` 报错

```text
TypeError: Trainer.__init__() got an unexpected keyword argument 'tokenizer'
```

本质：

```text
transformers 5.x 不再使用 tokenizer 参数
```

正确写法：

```python
processing_class=processor
```

---

## 3️⃣ 模型加载 warning（不是错误）

```text
classifier.weight MISSING
classifier.bias MISSING
```

本质：

```text
分类头不匹配（预训练 vs 你的任务）
```

结论：

```text
正常现象，需要训练
```

---

## 4️⃣ 训练日志不显示 loss

```text
Epoch Training Loss Validation Loss（空）
```

本质：

```text
还没到 logging / eval step
```

解决：

```python
logging_steps=10
eval_strategy="steps"
```

---

## 二、核心总结（一句话）

```text
你所有问题 = transformers 5.x API 变化 + 教程是 4.x
```

---

## 三、Kaggle Notebook 标准流程（一步一步）

直接照这个顺序跑，不会错。

---

## Step 0：开启 GPU

右侧设置：

```text
Accelerator → GPU T4 ×2
Internet → ON
```

---

## Step 1：安装环境（第一格必须）

```python
!pip install -U transformers peft accelerate datasets torchvision
```

---

## Step 2：导入库

```python
import torch
from datasets import load_dataset
from transformers import (
    AutoImageProcessor,
    ViTForImageClassification,
    TrainingArguments,
    Trainer
)
from peft import LoraConfig, get_peft_model
```

---

## Step 3：加载数据集

```python
ds = load_dataset("food101")
```

---

## Step 4：加载模型 + 处理器

```python
model_name = "google/vit-base-patch16-224-in21k"

processor = AutoImageProocessr.from_pretrained(model_name)

model = ViTForImageClassification.from_pretrained(
    model_name,
    num_labels=101
)
```

---

## Step 5：加 LoRA（重点）

```python
lora_config = LoraConfig(
    r=8,
    lora_alpha=16,
    target_modules=["query", "value"],
    lora_dropout=0.1,
    bias="none"
)

model = get_peft_model(model, lora_config)
```

---

## Step 6：数据预处理

```python
def transform(example):
    inputs = processor(example["image"], return_tensors="pt")
    inputs["labels"] = example["label"]
    return inputs

ds = ds.with_transform(transform)
```

---

## Step 7：训练参数（5.x写法）

```python
args = TrainingArguments(
    output_dir="./vit-lora",
    per_device_train_batch_size=16,
    per_device_eval_batch_size=16,
    eval_strategy="epoch",      # ✅ 注意
    save_strategy="epoch",
    logging_steps=10,
    num_train_epochs=3,
    learning_rate=5e-5,
    fp16=True
)
```

---

## Step 8：Trainer（5.x关键点）

```python
trainer = Trainer(
    model=model,
    args=args,
    train_dataset=ds["train"],
    eval_dataset=ds["validation"],
    processing_class=processor   # ✅ 不是 tokenizer
)
```

---

## Step 9：开始训练

```python
trainer.train()
```

---

## 四、你必须记住的 3 个关键点

```text
1️⃣ transformers 5.x → eval_strategy（不是 evaluation_strategy）
2️⃣ Trainer → processing_class（不是 tokenizer）
3️⃣ MISSING classifier → 正常，继续训练
```

---

## 五、如果你想更稳（强烈建议）

其实更简单的方案是：

```bash
pip install transformers==4.40.2
```

👉 优点：

```text
完全兼容所有教程
不用改参数名
```
