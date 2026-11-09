---
title: "lora"
date: 2026-03-31 20:51:46
updated: 2026-03-31 20:51:46
categories:
  - 🤖 大模型与 AI
tags: []
toc: true
comments: true
---
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
