---
title: "AI Agent 能力索引与动态路由中枢（A2A 中间件）"
date: 2026-06-04 22:44:24
updated: 2026-06-04 22:44:24
categories:
  - 🚀 项目实战
tags: []
toc: true
comments: true
---
## 1. 文档信息

| 项目   | 内容                            |
| ---- | ----------------------------- |
| 项目名称 | AI Agent 能力索引与动态路由中枢（A2A 中间件） |
| 版本   | v1.0                          |
| 状态   | 草案                            |
| 作者   | 系统架构团队                        |
| 更新日期 | 2026-04-28                    |

---

## 2. 背景与目标

### 2.1 背景

在多智能体系统中，上游 Agent 需要调用外部能力（图像处理、数据计算、第三方 API 等），当前存在以下问题：

- 能力调用强耦合（硬编码 endpoint）

- 能力变更需逐个 Agent 修改

- 缺乏统一的动态路由与调度能力

- 无法基于成本、延迟、可用性进行优化

---

### 2.2 目标

构建一个纯后台 M2M 中间件，实现：

- 能力自动注册与多维索引

- 基于 intent 与约束的动态路由

- 标准化执行与统一结果返回

- 高可靠机制（熔断、限流、重试、故障转移）

- 全链路可观测

- **核心约束：** 系统**绝对不参与**自然语言理解（NLU）。所有输入输出均为结构化数据。

- **意图（Intent）定义：** 上游传入的`intent` 必须是已标准化的动作标识符（如`image.ocr` 或`data.calc`），中间件仅将其作为强匹配的 Tag 处理，不进行任何语义向量转换。

---

## 3. 范围

### 3.1 包含功能

- 能力注册、注销、更新

- 标签索引与可选语义检索

- 路由决策引擎

- 调用执行器（HTTP / gRPC / MQ）

- 结果规范化

- 容错机制（重试、熔断、fallback）

- 指标与追踪输出

---

### 3.2 不包含功能

- 面向用户的 UI 系统

- 意图解析（由上游提供 intent）

- 能力本身的业务实现

---

## 4. 角色定义

|角色|描述|交互方式|
|---|---|---|
|上游 Agent|请求能力的智能体|HTTP API|
|下游 Agent / Tool|实际执行能力|被调用|
|运维系统|管理注册表|管理 API|
|自动化探针|健康检查与更新状态|定时调用|

---

## 5. 功能需求

### 5.1 能力注册与管理（FR-1）

**功能描述**

- 提供能力注册、查询、更新、注销接口

- 支持版本管理与状态控制

**关键要求**

- 注册后支持按 ID 查询

- 索引刷新延迟 ≤ 500ms

- maintenance 状态能力不参与路由

---

### 5.2 路由决策（FR-2）

**处理流程**

1. 标签召回（基于 tags 或 intent 提示）

2. Schema 校验（请求字段为能力输入子集）

3. 约束过滤（cost / latency / tags）

4. 最优能力选择

**默认策略**

- 最小成本优先

- 成本相同则选择最低延迟

**扩展策略**

- round-robin

- least-busy

**新增 Schema 性能要求：**

- Schema 校验：针对高并发场景，路由决策层的 JSON Schema 校验必须基于**预编译缓存**执行，拒绝在请求热路径上进行实时的 AST 解析，以防止 CPU 阻塞。

---

### 5.3 调用执行（FR-3）

**执行模式**

|模式|描述|
|---|---|
|sync|同步调用|
|async|返回 task_id|

**能力要求**

- 多协议支持（HTTP / gRPC / MQ）

- 自动重试（指数退避）

- fallback 调度

- 统一结果封装

---

### 5.4 可靠性（FR-4）

- Trace ID 全链路传递

- 熔断机制：5 分钟内错误率 > 50%

- 限流：基于 capability 级别

- 幂等：支持 idempotency_key

---

### 5.5 可观测性（FR-5）

**指标**

- 请求总数

- 成功率

- 延迟分位

- 熔断次数

**日志**

- JSON 结构化输出

- 包含 trace_id

**追踪**

- 支持 OpenTelemetry / Jaeger

---

## 6. 非功能需求

| 类别    | 指标                                                                                                                 |
| ----- | ------------------------------------------------------------------------------------------------------------------ |
| 路由延迟  | P99 路由延迟 < 10ms （注：此时间仅指 A2A 中间件内部的纯处理开销，即“收到请求到发起下游调用的间隔”，严格排除网络 RTT 与下游 Agent/Tool 的业务执行耗时）                      |
| 索引刷新  | ≤ 500ms                                                                                                            |
| 可用性   | 99.95%                                                                                                             |
| 吞吐能力  | 10,000 req/s                                                                                                       |
| 安全    | mTLS + JWT。统一采用 Kubernetes`cert-manager` + 进程内 Go`crypto/tls` 处理证书轮换，不引入 Istio Sidecar（避免增加一跳网络延迟影响 10ms 的硬性指标）。 |
| 数据一致性 | 强一致                                                                                                                |

---

## 7. 数据模型

### 7.1 Capability

```json
{
  "capability_id": "uuid",
  "endpoint": "string",
  "protocol": "http | grpc | mq",
  "auth": {},
  "schema_input": {},
  "schema_output": {},
  "tags": [],
  "cost_per_call_cents": 0.1,
  "avg_latency_ms": 120,
  "rate_limit": "100r/1s",
  "status": "active | maintenance | deprecated"
}
```

---

### 7.2 RouteRequest

```json
{
  "request_id": "uuid",
  "trace_id": "string",
  "intent": "string",
  "input_schema": {},
  "constraints": {
    "max_latency_ms": 1000,
    "max_cost_cents": 10,
    "required_tags": []
  },
  "retry_policy": {
    "max_attempts": 3,
    "backoff_ms": 100,
    "fallback_behavior": "pick_next_best"
  },
  "execution_mode": "sync | async",
  "callback_url": "string",
  "idempotency_key": "string"
}
```

---

### 7.3 ExecutionResult

```json
{
  "status": "success | error | partial | fallbacked",
  "data": {},
  "error": {
    "code": "string",
    "message": "string",
    "details": {}
  },
  "execution_metadata": {
    "capability_id": "uuid",
    "endpoint": "string",
    "latency_ms": 100,
    "attempts": 1,
    "cost_cents": 0.2,
    "fallback_triggered": false,
    "trace_id": "string"
  }
}
```

---

## 8. API 设计

### 8.1 路由接口

POST /v1/route

**响应**

- sync：200 + ExecutionResult

- async：202 + task 信息

**错误码**

- 400：请求错误

- 404：无匹配能力

- 429：限流

- 503：不可用

---

### 8.2 异步查询

GET /v1/tasks/{task_id}

- 200：完成

- 202：处理中

---

### 8.3 能力管理

- POST /v1/capabilities

- GET /v1/capabilities/{id}

- PUT /v1/capabilities/{id}

- DELETE /v1/capabilities/{id}

- POST /v1/capabilities/{id}/status

---

## 9. 集成约束

- 中间件独立部署

- 下游必须提供`/health`

- 下游错误格式统一

- 上游必须提供 JWT

- 支持 Kubernetes + Helm

---

## 10. 验收标准

1. 功能测试：覆盖正常、异常、fallback、异步场景

2. 性能测试：P99 路由延迟 < 10ms

3. 可靠性：熔断与恢复机制验证

4. 可观测性：指标与 trace 完整

5. 安全性：JWT + mTLS 生效
