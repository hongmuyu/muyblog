---
title: "AI掘金头条复盘（三）：数据库与 ORM"
date: 2026-11-09 20:02:00
updated: 2026-11-09 20:02:00
categories:
  - python_web
tags:
  - "SQLAlchemy"
  - "ORM"
  - "异步编程"
  - "数据库事务"
  - "分页查询"
toc: true
comments: true
---
## 数据库与 ORM

> 本篇深入数据层：SQLAlchemy 2.0 的异步引擎怎么配、模型怎么定义、CRUD 怎么写、分页和联表怎么处理、事务边界在哪。

## 一、异步引擎与会话

项目用 `aiomysql` 作为异步驱动，配合 SQLAlchemy 2.0 的 `create_async_engine`：

```python
ASYNC_DATABASE_URL = "mysql+aiomysql://root:***@localhost:3306/news_app?charset=utf8mb4"

async_engine = create_async_engine(
    ASYNC_DATABASE_URL,
    echo=True,           # 打印 SQL，便于调试
    pool_size=10,        # 连接池持久连接数
    max_overflow=20      # 允许超出的连接数
)

AsyncSessionLocal = async_sessionmaker(
    bind=async_engine,
    class_=AsyncSession,
    expire_on_commit=False   # commit 后不立即过期属性
)
```

`expire_on_commit=False` 很关键：默认情况下 commit 后 ORM 对象的属性会被标记为过期，再次访问会触发隐式查询。异步环境下这种隐式查询容易报错，所以关闭它。

## 二、模型定义：DeclarativeBase + Mapped

用 SQLAlchemy 2.0 的 `Mapped` / `mapped_column` 语法定义模型：

```python
class Base(DeclarativeBase):
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)
    updated_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.now, onupdate=datetime.now)


class News(Base):
    __tablename__ = "news"

    __table_args__ = (
        Index("fk_news_category_idx", "category_id"),
        Index("idx_publish_time", "publish_time"),
    )

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    category_id: Mapped[int] = mapped_column(Integer, ForeignKey("news_category.id"))
    views: Mapped[int] = mapped_column(Integer, default=0)
    publish_time: Mapped[datetime] = mapped_column(DateTime, default=datetime.now)
```

要点：

- `Base` 里定义 `created_at` / `updated_at`，所有模型继承后自动拥有。
- `default=datetime.now`（不加括号）表示插入时调用函数取当前时间；如果写成 `datetime.now()`，会在模块导入时就执行，所有记录拿到同一个时间。
- `ForeignKey` 建立表关系，`Index` 提升高频查询的速度。
- 收藏表用 `UniqueConstraint("user_id", "news_id")` 保证「一用户对一新闻只能收藏一次」。

## 三、CRUD 的四种基本操作

所有查询通过 `AsyncSession.execute(stmt)` 执行，再从结果中取值。

**查列表**：

```python
async def get_news_list(db, category_id, skip=0, limit=10):
    stmt = select(News).where(News.category_id == category_id).offset(skip).limit(limit)
    result = await db.execute(stmt)
    return result.scalars().all()
```

**查单个**：

```python
async def get_news_detail(db, news_id):
    stmt = select(News).where(News.id == news_id)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()
```

**更新**：

```python
async def increase_news_views(db, news_id):
    stmt = update(News).where(News.id == news_id).values(views=News.views + 1)
    result = await db.execute(stmt)
    await db.commit()
    return result.rowcount > 0
```

**删除**：

```python
stmt = delete(Favorite).where(Favorite.user_id == user_id, Favorite.news_id == news_id)
result = await db.execute(stmt)
await db.commit()
```

取值方式：`scalars().all()` 取对象列表，`scalar_one_or_none()` 取单个或 None，`rowcount` 看影响行数。

## 四、分页与联表

新闻列表分页：路由算 `offset = (page - 1) * page_size`，CRUD 用 `offset(skip).limit(limit)`，再单独查 `count` 算总量和 `hasMore`。

收藏列表是典型的联表查询：同时需要新闻内容和收藏时间、收藏 ID：

```python
query = (
    select(News, Favorite.created_at.label("favorite_time"), Favorite.id.label("favorite_id"))
    .join(Favorite, Favorite.news_id == News.id)
    .where(Favorite.user_id == user_id)
    .order_by(Favorite.created_at.desc())
    .offset(offset).limit(page_size)
)
result = await db.execute(query)
rows = result.all()   # 每行是 (News 对象, favorite_time, favorite_id)
```

用 `label()` 给字段起别名，`result.all()` 返回行元组，路由层再组装成响应。

## 五、事务边界

`get_db` 依赖负责事务收尾：

```python
async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()       # 正常结束统一提交
        except Exception:
            await session.rollback()     # 异常回滚
            raise
        finally:
            await session.close()
```

项目里部分 CRUD（如 `increase_news_views`、`add_news_favorite`）会在内部 `commit`，请求结束时 `get_db` 又会提交一次，所以同一请求可能出现多次 commit。理解这种写法后，可以通过「一次请求只在一个地方提交」来获得更清晰的事务边界。

另一个值得注意的点：如果 CRUD 已经 commit 了前一步，之后再抛异常，前面已提交的数据不会回滚。例如注册分「建用户」和「发 Token」两步，如果第一步已提交、第二步失败，数据库就会留下没有 Token 的用户。如果要求两步同生共死，应放在同一个事务里。

## 六、异步编程要点

| 要点            | 说明         | 项目对应                           |
| ------------- | ---------- | ------------------------------ |
| 必须用异步驱动       | 同步库会阻塞事件循环 | aiomysql、redis.asyncio         |
| Session 每请求一个 | 跨请求复用会状态污染 | `get_db` 每次新建                  |
| commit 后属性不过期 | 避免隐式查询     | `expire_on_commit=False`       |
| 不用懒加载         | 异步下关系访问易出错 | 显式 `join` 代替 `relationship()`  |
| 及时归还连接        | 防止连接池耗尽    | `async with` + `finally close` |


## 七、小结

第三篇掌握的核心：

- `create_async_engine` + `async_sessionmaker` 配异步引擎，`expire_on_commit=False` 规避异步坑。
- 用 `Mapped` / `mapped_column` 定义模型，`default` 传函数不加括号。
- CRUD 四种操作：`select` / `update` / `delete`，用 `scalars()` / `scalar_one_or_none()` / `rowcount` 取结果。
- 分页靠 `offset/limit`，联表用 `join` + `label` 起别名。
- 事务由 `get_db` 统一收尾，多次提交是项目现状，理解后可以优化。

下一篇进入业务模块：把新闻、用户认证、收藏、浏览历史四条链路串起来讲。
