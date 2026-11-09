---
title: "Task 文档(gemini pro)"
date: 2026-06-04 22:44:24
updated: 2026-06-04 22:44:24
permalink: /notes/Task-文档(gemini-pro)/
categories:
  - 🚀 项目实战
tags: []
toc: true
comments: true
---
## A2A 中间件 (动态路由中枢) 开发任务看板

### 阶段一：项目初始化与基础设施 (Phase 1: Infrastructure)

_目标：搭建本地开发环境，跑通 CI 流水线，确立工程规范。_

- [ ] **Task 1.1:** 初始化 Go 1.22+ Monorepo 项目结构（按照规范创建`cmd/`,`internal/`,`api/` 等目录）。

- [ ] **Task 1.2:** 编写本地开发环境的`docker-compose.yml`（包含 PostgreSQL 16, Redis 7, etcd, NATS, Jaeger）。

- [ ] **Task 1.3:** 引入并配置`golangci-lint`，编写项目`Makefile`（包含 run, build, test, lint 指令）。

- [ ] **Task 1.4:** 搭建 GitHub Actions CI 工作流（集成`ko` 镜像构建，无需 Dockerfile）。

- [ ] **Task 1.5:** 核心基础库选型引入（`fiber v3`,`zerolog`,`viper` 配置加载）。

---

### 阶段二：存储层与核心数据模型 (Phase 2: Data & Storage)

_目标：完成基础数据结构定义，打通主存储与缓存。_

- [ ] **Task 2.1:** 定义核心 Go Struct（Capability, RouteRequest, ExecutionResult），并完成 JSON tag 映射。

- [ ] **Task 2.2:** 设计 PostgreSQL 的`capabilities` 表结构（Schema），编写初始化的 SQL 迁移脚本（Migration）。

- [ ] **Task 2.3:** 封装 PostgreSQL 客户端（引入`pgx` 或`gorm`），实现连接池配置。

- [ ] **Task 2.4:** 实现 Capability 在 PG 中的 CRUD 仓储层（Repository）基础方法。

- [ ] **Task 2.5:** 封装 Redis 7 客户端（支持 Cluster 模式），用于后续幂等和限流。

- [ ] **Task 2.6:** 封装 etcd 客户端，测试本地基础读写连通性。

---

### 阶段三：能力注册与内存索引层 (Phase 3: Registry & Index)

_目标：实现能力注册的 API，并打通 PG -> etcd -> 内存索引的极速刷新链路（确保 ≤500ms 刷新且检索 < 1ms）。_

- [ ] **Task 3.1:** 基于 Fiber v3 实现能力注册管理 API（POST, GET, PUT, DELETE /v1/capabilities）。

- [ ] **Task 3.2:** 实现基于事件驱动的配置下发。使用 PostgreSQL 的`LISTEN/NOTIFY` 机制（配合`pgx` 驱动），在 PG 表数据变更时触发事件，由单独的 Goroutine 监听到事件后异步写入 etcd，彻底避免双写导致的数据不一致。

- [ ] **Task 3.3:** 实现`internal/index` 模块：定义内存倒排索引结构`map[tag][]capID` 和读写锁（`sync.RWMutex`）。

- [ ] **Task 3.4:** 编写 etcd`Watch` 监听器，接收增量事件并更新内存倒排索引。

- [ ] **Task 3.5:** 编写内存索引层的单元测试（并发读写测试，验证无 data race 且耗时 < 1ms）。

---

### 阶段四：核心路由决策引擎 (Phase 4: Routing Engine)

_目标：实现 FR-2，完成 P99 < 10ms 的热路径路由计算。_

- [ ] **Task 4.1:** 开发路由 API 接口（`POST /v1/route`）及参数绑定校验。

- [ ] **Task 4.2:** 实现**召回阶段**逻辑：通过 Request 中的 tags 从内存索引中快速取回候选`Capability` 列表。

- [ ] **Task 4.3:** 实现**过滤阶段**逻辑：基于 Constraints（延迟、成本限制）剔除不合规的候选者。
- [ ] **Task 4.4:** 实现 **Schema 预编译与校验**：在内存索引加载 Capability 时，利用`gojsonschema` 等库将输入输出 Schema 预编译为验证器实例并缓存。在路由热路径上直接调用缓存实例进行请求体校验。
- [ ] **Task 4.5:** 实现**排序阶段**逻辑：按“最小成本优先 -> 最低延迟优先”完成最优能力选择（Pick Best）。

- [ ] **Task 4.6:** 针对路由策略编写全面的单元测试（正常匹配、无匹配、降级匹配）。
- [ ] **Task 4.7:** 编写**热路径基准测试 (Benchmark)**：立即引入`go test -bench`，对“召回 -> 过滤 -> Schema 校验 -> 排序”的纯内存链路进行打压，确保单次路由计算开销严格 < 2ms。

---

### 阶段五：多协议执行器与协议适配 (Phase 5: Executors)

_目标：实现 FR-3，支持路由命中后的真实流量转发。_

- [ ] **Task 5.1:** 定义标准的`Executor` 接口（`Execute(ctx, req) (ExecutionResult, error)`）。

- [ ] **Task 5.2:** 实现 **HTTP 执行器**（基于`fasthttp` 客户端），处理同步请求并封装统一返回格式。

- [ ] **Task 5.3:** 引入`google.golang.org/grpc`，实现 **gRPC 执行器**及 protobuf 动态调用。

- [ ] **Task 5.4:** 引入 NATS JetStream，实现 **MQ 执行器**（异步发信）。

- [ ] **Task 5.5:** 实现异步模式（`execution_mode=async`）：生成`task_id`，将结果暂存 Redis，并提供异步查询接口（`GET /v1/tasks/{task_id}`）。
- [ ] **Task 5.6:** 实现**异步回调机制 (Webhook Callback)**：针对`execution_mode=async` 且携带`callback_url` 的请求，在任务执行完成后，通过可靠队列（NATS）触发 Webhook 推送，将`ExecutionResult` 主动 POST 给上游。

---

### 阶段六：高可用与可观测性 (Phase 6: Resilience & Observability)

_目标：满足 FR-4 和 FR-5，确保系统抗压能力和全链路透明。_

- [ ] **Task 6.1:** 实现幂等校验：基于 Request 中的`idempotency_key` 在 Redis 中使用`SET NX` 拦截重复请求（TTL 1h）。

- [ ] **Task 6.2:** 引入`sony/gobreaker`，为每个下游 Capability ID 动态创建并维护独立的熔断器。

- [ ] **Task 6.3:** 实现**两级高并发限流器**。由于 10K QPS 下每次请求查 Redis 会耗尽延迟预算，需实现“本地内存 Token Bucket（应对突发流量） + 后台 Goroutine 异步同步 Redis（维持全局配额）”的混合限流方案。

- [ ] **Task 6.4:** 实现自动重试逻辑（指数退避算法），以及在熔断/失败时的 Fallback 调度策略（Pick Next Best）。

- [ ] **Task 6.5:** 接入`golang-jwt/jwt v5`，编写 API 鉴权中间件。

- [ ] **Task 6.6:** 全局日志替换为`zerolog`，并注入结构化 TraceID；接入 OpenTelemetry SDK 和 Jaeger 导出器。

- [ ] **Task 6.7:** 注册 Prometheus 核心指标（P99 耗时、QPS、熔断次数等），并暴露`/metrics` 接口。

---

### 阶段七：测试、压测与 K8s 部署 (Phase 7: Testing & Deployment)

_目标：验证 10K QPS 验收标准，完成生产级别容器化部署。_

- [ ] **Task 7.1:** 使用`testcontainers-go` 编写核心路由链路的端到端（E2E）集成测试。

- [ ] **Task 7.2:** 编写 Helm Chart 基础模板（Deployment, Service, ConfigMap）。

- [ ] **Task 7.3:** 在 Helm 中配置 HPA（Horizontal Pod Autoscaler）和 PodDisruptionBudget。

- [ ] **Task 7.4:** 配置 Kubernetes`cert-manager`，实现 mTLS 证书自动签发与轮换（测试环境下跑通）。

- [ ] **Task 7.5:** 使用`wrk` 或`k6` 编写压测脚本，对`/v1/route` 接口进行 10,000 QPS 压力测试。

- [ ] **Task 7.6:** 根据压测结果，使用 Go`pprof` 进行 CPU/Memory 热点分析并优化代码（如减少逃逸、复用 fasthttp 对象）。
