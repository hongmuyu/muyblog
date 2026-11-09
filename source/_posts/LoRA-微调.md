---
title: "LoRA 微调"
date: 2026-03-31 20:51:46
updated: 2026-11-09 13:04:11
categories:
  - AI大模型
tags:
  - "LoRA"
  - "模型微调"
toc: true
comments: true
---
## LoRA 微调

## 第一部分：LoRA 原理与 LoraConfig

## 一、LoRA（核心原理）

## 本质

```text
W → W + ΔW
ΔW = A × B（低秩矩阵）
```

- W：原模型权重（冻结）

- A、B：小矩阵（可训练）

---

## 做了什么

- 不再微调整个模型

- 只在注意力层插入低秩矩阵

- 只训练极少参数（通常 <1%）

---

## 为什么有效

- 大模型权重更新本质是低秩的

- 用小矩阵可以近似原来的更新

---

## 核心优势

- 显存占用极低

- 训练速度快

- 可插拔（Adapter）

- 支持多任务切换

---

## 一句话总结

```text
LoRA = 用小矩阵近似大模型的权重更新
```

---

## 二、LoraConfig（定义规则）

## 本质

```text
LoraConfig = 定义 LoRA 加在哪、怎么加、加多少
```

---

## 最关键参数（必须掌握）

```python
config = LoraConfig(
    r=8,
    lora_alpha=16,
    target_modules=["q_proj", "v_proj"],
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
)
```

---

## 参数核心理解

- r
    低秩维度（决定能力上限）

- target_modules
    指定插入 LoRA 的层
    本质：在哪些权重上做 ΔW

- lora_alpha
    控制 LoRA 强度
    实际缩放：

```text
    alpha / r
    ```

- lora_dropout
    防止过拟合

- bias
    是否训练 bias（一般关）

- task_type
    任务类型（语言模型一般用 CAUSAL_LM）

---

## 进阶但重要

- use_rslora
    改进缩放方式，更稳定

- init_lora_weights
    初始化方法

    - eva / pissa：更先进

    - True：默认

---

## 特殊能力（知道即可）

- target_parameters
    用于 MoE（没有 nn.Linear 的情况）

- layers_to_transform
    只训练部分层（省资源）

- modules_to_save
    额外训练某些层（如 lm_head）

---

## 总结

```text
LoraConfig 本质是：控制 LoRA 的“位置 + 容量 + 强度”
```

---

## 三、LoraModel（应用 LoRA）

## 本质

```text
LoraModel = 把 LoRA 插入模型并改造成可训练结构
```

---

## 实际使用方式

```python
from peft import get_peft_model

model = get_peft_model(base_model, config)
```

不推荐：

```python
LoraModel(model, config)
```

---

## 内部做了什么

```text
1. 找到 target_modules
2. 替换为 LoRA 层（Linear → LoRA Linear）
3. 冻结原模型参数
4. 只训练 LoRA 参数
```

---

## 关键参数理解

- model
    原始预训练模型

- peft_config
    LoraConfig

- adapter_name
    LoRA 名字（支持多 Adapter）

---

## 多 Adapter（重要）

```python
model.add_adapter("task1", config)
model.add_adapter("task2", config)

model.set_adapter("task1")
```

作用：

- 一个模型加载多个能力

- Agent 系统核心能力

---

## 高级能力（了解）

- adapter merge（融合多个 LoRA）

- weighted adapter（加权组合）

- aLoRA（按 token 激活）

- DoRA（分解方向和幅度）

---

## 总结

```text
LoraModel 本质是：把 LoRA 注入模型，并控制训练行为
```

---

## 最终总结

```text
LoRA：用低秩矩阵替代大模型更新
LoraConfig：定义怎么加 LoRA
LoraModel：把 LoRA 真正加到模型里
```
## 第二部分：Kaggle Notebook 训练实例

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
