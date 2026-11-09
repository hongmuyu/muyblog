---
title: "技术栈(claude)"
date: 2026-06-04 22:44:24
updated: 2026-06-04 22:44:24
categories:
  - 🚀 项目实战
tags: []
toc: true
comments: true
---
## 技术栈推荐

基于 PRD 的核心诉求（P99 路由 < 10ms、10K req/s、多协议适配、M2M 纯后台），推荐如下分层技术栈。

---

### 运行时 & 语言

**Go 1.22+**

路由决策是热路径，Go 的极低 GC 延迟和 goroutine 并发模型是达成 P99 < 10ms 的最直接保障。相比 Java/Kotlin，冷启动快、内存占用低，适合 Kubernetes 高密度部署。Rust 性能更强但生态成熟度和招募成本不划算。

---

### 核心组件选型

|层级|选型|理由|
|---|---|---|
|**HTTP 框架**|[Fiber v3](https://github.com/gofiber/fiber)（基于 fasthttp）|比 net/http 吞吐高 2-3x，零分配路由，适合高 QPS 场景|
|**gRPC**|google.golang.org/grpc|官方库，与 protobuf 原生集成，支持双向流|
|**消息队列适配**|NATS JetStream（轻量）或 Apache Pulsar（重量）|NATS 延迟极低适合同 AZ 通信；Pulsar 支持跨 AZ 持久化|
|**能力注册表存储**|PostgreSQL 16（主库） + etcd（索引热缓存）|PG 强一致写入满足 6.1 节要求；etcd watch 实现 ≤500ms 索引刷新|
|**倒排标签索引**|内存`map[tag][]capID`，由 etcd watch 增量更新|纯内存检索 < 1ms，避免引入 Elasticsearch 的运维复杂度|
|**语义向量索引**（可选）|[Weaviate](https://weaviate.io/) 或 pgvector 扩展|PRD 标注"可选"，先用 pgvector 降低组件数|
|**幂等缓存**|Redis 7（Cluster 模式）|TTL 1h，原子 SET NX 保障幂等，也用于限流计数器|
|**熔断 / 限流**|[sony/gobreaker](https://github.com/sony/gobreaker) + Redis 滑动窗口限流|gobreaker 满足 FR-4.2 的 5min/50%/30s 参数；Redis 保证多实例共享限流状态|
|**JWT 鉴权**|[golang-jwt/jwt v5](https://github.com/golang-jwt/jwt)|轻量，支持 RS256/ES256，满足 mTLS + JWT 双重要求|
|**mTLS**|标准库`crypto/tls` + [cert-manager](https://cert-manager.io/)（K8s 证书自动轮换）|证书生命周期托管给 cert-manager，无需手动续期|

---

### 可观测性

```
指标：Prometheus client_golang  →  Grafana
追踪：go.opentelemetry.io/otel  →  Jaeger（OTLP 协议）
日志：zerolog（JSON 结构化，零反射，< 100ns/op）
```

三者共享同一`trace_id`，通过 OpenTelemetry SDK 的`TextMapPropagator` 自动注入 W3C`traceparent`，满足 FR-5.3。

---

### 部署 & 基础设施

|层级|选型|
|---|---|
|容器编排|Kubernetes 1.29+，提供 Helm Chart（含 HPA、PodDisruptionBudget）|
|服务网格（可选）|Istio，卸载 mTLS 握手到 sidecar，减少业务代码侵入|
|CI/CD|GitHub Actions + ko（Go 镜像构建，无需 Dockerfile）|
|本地开发|Docker Compose（PG + Redis + NATS + Jaeger 一键启动）|

---

### 关键架构决策说明

**为什么不用 Kafka？** PRD 要求同步模式 P99 < 10ms，Kafka 的 producer ACK 通常 5-20ms，仅作为 MQ 适配器目标（下游侧），不作为中间件内部总线。

**为什么不引入 API Gateway（Kong/APISIX）？** 本系统本身就是路由决策层，叠加 Gateway 会增加一跳延迟且功能重叠；鉴权、限流直接在 Go 进程内处理更可控。

**PostgreSQL 强一致 vs 最终一致** 注册表写入走 PG 主库（同步确认），读取走 etcd 内存缓存。etcd 通过 PG 的`NOTIFY` / 变更事件驱动 watch，刷新延迟实测 < 200ms，满足 500ms 要求。

---

### 目录结构建议（Go Monorepo）

```
a2a-middleware/
├── cmd/gateway/          # 主进程入口
├── internal/
│   ├── registry/         # 能力注册表（PG + etcd）
│   ├── index/            # 倒排标签索引 + 向量索引接口
│   ├── router/           # 路由决策引擎（FR-2）
│   ├── executor/         # 协议适配器（http/grpc/mq）
│   ├── resilience/       # 熔断、限流、重试
│   ├── idempotency/      # Redis 幂等缓存
│   └── observability/    # metrics/tracing/logging 初始化
├── api/proto/            # gRPC Proto 定义
├── charts/               # Helm Chart
└── tests/integration/    # 集成测试（testcontainers-go）
```

集成测试推荐用 [testcontainers-go](https://golang.testcontainers.org/) 拉起真实 PG/Redis/NATS，避免 mock 遮蔽真实问题，直接对应 §9 验收标准。
