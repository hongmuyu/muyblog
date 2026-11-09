---
title: "AI掘金头条复盘（五）：Redis 与 AI"
date: 2026-11-09 20:04:00
updated: 2026-11-09 20:04:00
categories:
  - python_web
tags:
  - "Redis"
  - "缓存"
  - "Cache-Aside"
  - "AI 问答"
  - "SSE"
toc: true
comments: true
---
## Redis 与 AI

> 本篇讲项目的两个特色：后端的 Redis 缓存，以及前端直连的 AI 问答。

## 一、Redis 缓存封装

项目用 `redis.asyncio` 创建客户端，封装了三个基础方法：

```python
redis_client = redis.Redis(
    host="localhost", port=6379, db=0,
    decode_responses=True
)

async def get_cache(key):          # 读字符串
    try:
        return await redis_client.get(key)
    except Exception:
        return None

async def get_json_cache(key):     # 读列表/字典（自动 json.loads）
    ...

async def set_cache(key, value, expire=3600):   # 写（setex，自动 json.dumps）
    ...
```

封装的好处是统一处理异常：读失败返回 `None`（触发回源查库），写失败返回 `False`（不影响主流程）。这样即使 Redis 挂了，接口也能降级到 MySQL，不会直接报错。

## 二、缓存 Key 与 TTL 设计

新闻模块有四类缓存，每类用不同的 key 规则和过期时间：

| 数据   | Key                       | TTL   | 说明             |
| ---- | ------------------------- | ----- | -------------- |
| 分类   | `news:categories`         | 7200s | 低频变化，缓存时间长     |
| 列表   | `news_list:{分类}:{页}:{数量}` | 1800s | 按分类和分页维度存      |
| 详情   | `news:detail:{id}`        | 300s  | 变化稍频繁（浏览量），时间短 |
| 相关推荐 | `news:related:{id}:{分类}`  | 1800s | 按详情页维度存        |

设计思路：**数据越稳定，缓存时间越长**。分类几乎不变，给 2 小时；详情的浏览量会变，给 5 分钟。

## 三、Cache-Aside 模式

所有读接口都遵循「先读缓存 → 命中返回 → 未命中查库 → 写缓存」的流程：

```python
async def get_news_detail(db, news_id):
    cached = await get_cached_news_detail(news_id)
    if cached:
        return News(**cached)            # 命中：直接返回

    news = await db.execute(select(News).where(News.id == news_id)).scalar_one_or_none()
    if news:
        news_dict = NewsDetailResponse.model_validate(news).model_dump(
            by_alias=False, mode="json", exclude={"related_news"}
        )
        await cache_news_detail(news_id, news_dict)   # 未命中：查库后写缓存
    return news
```

写缓存时用 `model_dump(mode="json")` 把 ORM 对象转成可 JSON 序列化的字典，读缓存时再 `News(**cached)` 还原成 ORM 对象。

## 四、缓存三大问题

理解了项目的实现，可以对照看缓存的三个经典问题：

**缓存穿透**：查不存在的数据，缓存永远不命中，请求直接打到数据库。项目里详情接口在数据不存在时不写缓存，所以同一个不存在 ID 的重复请求会持续回源。

**缓存击穿**：热点 key 过期瞬间，大量请求同时回源。项目没有互斥锁/单飞机制，如果热点新闻的详情缓存刚好过期，短时间内可能出现多个请求同时查库。

**缓存雪崩**：大量 key 同时过期，或 Redis 整体不可用。项目的 TTL 是固定值，同一批写入的 key 可能在同一时间过期；Redis 不可用时读操作会降级回源，流量直接落到 MySQL。

## 五、AI 问答：前端直连

项目的 AI 问答完全由前端实现，后端没有参与。

前端 `AIChat.vue` 调用 DashScope 的 OpenAI 兼容接口：

```js
export const aiChatConfig = {
  apiEndpoint: 'https://dashscope.aliyuncs.com/compatible-mode/v1/chat/completions',
  apiKey: 'sk-...',
  model: 'qwen3.8-max'
}
```

请求头带 `Authorization: Bearer ${apiKey}` 和 `X-DashScope-SSE: enable`，开启 SSE 流式输出。前端逐行解析 `data:` 开头的事件，拼接 `choices[0].delta.content`，再用 `marked` + `DOMPurify` 渲染 Markdown。


## 六、后端在 AI 链路里的角色

后端没有 AI 路由，也没有模型 SDK 依赖（`requirements.txt` 里没有 `openai` / `dashscope` / `httpx`）。AI 调用、API Key 管理、请求日志、限流、成本统计都在前端完成。

如果后续希望统一鉴权、控制调用成本，可以把 AI 调用收到后端：由后端持有 Key，增加登录鉴权、超时、限流和日志。这是一个可选的扩展方向，不是当前项目的实现。

## 七、小结

第五篇掌握的核心：

- Redis 封装三个基础方法，异常时降级，保证缓存故障不影响主流程。
- 四类缓存 key，按数据稳定度设置不同 TTL。
- Cache-Aside：先读缓存，未命中查库再回填。
- 缓存三大问题：穿透（不存在数据不缓存）、击穿（热点过期无互斥）、雪崩（TTL 固定）。
- AI 问答由前端直连 DashScope，SSE 流式解析；后端不参与。

下一篇进入测试与部署：接口测试、异常测试、环境配置、Docker 部署。
