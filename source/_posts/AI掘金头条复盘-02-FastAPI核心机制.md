---
title: "AI掘金头条复盘（二）：FastAPI 核心机制"
date: 2026-11-09 20:01:00
updated: 2026-11-09 20:01:00
categories:
  - python_web
tags:
  - "FastAPI"
  - "APIRouter"
  - "Pydantic"
  - "依赖注入"
  - "中间件"
toc: true
comments: true
---
## FastAPI 核心机制

> 本篇把 FastAPI 最常用的几块核心机制过一遍：路由怎么组织、参数从哪来、Pydantic 怎么校验、依赖注入怎么复用、中间件和异常怎么兜底。

## 一、路由组织：APIRouter

项目没有把所有接口塞进入口文件，而是按业务模块拆成 4 个 `APIRouter`：

```python
# routers/users.py
router = APIRouter(prefix="/api/user", tags=["users"])

@router.post("/register")
async def register(...):
    ...
```

`prefix` 给整个模块加上统一前缀，`tags` 用于 Swagger 文档分组。入口 `main.py` 里用 `app.include_router()` 挂载即可。这样每个路由文件只关心自己的业务，`main.py` 保持轻薄。

## 二、参数来源：Path / Query / Body / Header

FastAPI 根据参数类型和注解自动判断来源：

| 来源   | 写法                       | 项目里的例子                                                    |
| ---- | ------------------------ | --------------------------------------------------------- |
| 路径参数 | `news_id: int` 写在路径里     | `history.delete("/delete/{history_id}")`                  |
| 查询参数 | `Query(..., alias=...)`  | `news_id: int = Query(..., alias="id")`                   |
| 请求体  | Pydantic 模型              | `user_data: UserRequest`                                  |
| 请求头  | `Header(..., alias=...)` | `authorization: str = Header(..., alias="Authorization")` |

新闻列表接口同时用到了 Query 和默认值：

```python
@router.get("/list")
async def get_news_list(
    category_id: int = Query(..., alias="categoryId"),
    page: int = 1,
    page_size: int = Query(10, alias="pageSize", le=100),
    db: AsyncSession = Depends(get_db)
):
    offset = (page - 1) * page_size
    ...
```

- `category_id` 用 `alias="categoryId"` 对接前端驼峰命名。
- `page` 默认 1，`page_size` 默认 10 且 `le=100` 限制上限。
- 缺少 `category_id` 时，FastAPI 直接返回 422，不用手写校验。

## 三、Pydantic：请求校验与响应裁剪

注册和登录用 `UserRequest` 接收 JSON body：

```python
class UserRequest(BaseModel):
    username: str
    password: str
```

FastAPI 收到请求后会自动把 JSON 解析成 `UserRequest`，校验字段存在与类型，失败直接 422，同时生成 OpenAPI 文档。

响应侧用 `UserAuthResponse` 统一结构，并通过 `alias` 输出驼峰字段：

```python
class UserAuthResponse(BaseModel):
    token: str
    user_info: UserInfoResponse = Field(..., alias="userInfo")

    model_config = ConfigDict(
        populate_by_name=True,   # alias / 字段名兼容
        from_attributes=True     # 允许从 ORM 对象属性取值
    )
```

`from_attributes=True` 让 Pydantic 可以直接从 ORM 对象取值，配合 `model_validate(user)` 把数据库对象转成响应模型。

![[Pasted image 20261109160316.png]]

## 四、依赖注入：Depends

依赖注入是 FastAPI 复用逻辑的核心。项目里有两个关键依赖：

**1. 数据库会话 `get_db`**

```python
async def get_db():
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()
```

路由里声明 `db: AsyncSession = Depends(get_db)`，就能拿到一个带事务收尾的 Session：成功 commit、失败 rollback、最终 close，不用每个接口写 try/finally。

**2. 当前用户 `get_current_user`**

```python
async def get_current_user(
    authorization: str = Header(..., alias="Authorization"),
    db: AsyncSession = Depends(get_db)
):
    token = authorization.replace("Bearer ", "")
    user = await users.get_user_by_token(db, token)
    if not user:
        raise HTTPException(401, detail="无效的令牌或已经过期的令牌")
    return user
```

这个依赖自己又依赖了 `get_db`，形成依赖链。需要鉴权的接口只要写 `user: User = Depends(get_current_user)`，就完成了「取头 → 查 Token → 校验过期 → 注入用户」全部逻辑。

依赖还有一个特性：**同一请求内会被缓存**，`get_db` 不会重复创建 Session。

## 五、中间件

浏览器有**同源策略**：页面来源（协议 + 域名 + 端口）和请求地址不同，就叫**跨域**
项目只注册了一个中间件 `CORSMiddleware`，用于处理跨域：

```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

中间件在请求进入路由之前、响应返回之前执行，适合做跨域、日志、限流等横切逻辑。当前只需要跨域，所以一个就够了。

## 六、异常处理与统一响应

业务错误用 `HTTPException` 抛出，由全局处理器统一包装：

```python
raise HTTPException(status_code=400, detail="用户已存在")
```

成功响应统一走 `success_response`：

```python
def success_response(message="success", data=None):
    return JSONResponse(content=jsonable_encoder({
        "code": 200,
        "message": message,
        "data": data
    }))
```

需要注意：参数校验失败的 422 由 FastAPI 内置校验器直接处理，不经过项目的全局处理器，返回结构是 `{"detail": [...]}`，和 `{code, message, data}` 不同。

## 七、小结

第二篇掌握的核心：

- 用 `APIRouter(prefix, tags)` 按业务拆路由，入口只负责挂载。
- 参数四类来源：Path / Query / Body / Header，用 `alias` 对接前端命名。
- Pydantic 负责请求校验和响应裁剪，`from_attributes` 对接 ORM。
- `Depends` 复用数据库会话和鉴权逻辑，同一请求内自动缓存。
- 中间件处理跨域等横切逻辑；`HTTPException` + 全局处理器统一错误响应。

下一篇进入数据库与 ORM：SQLAlchemy 2.0 异步引擎、模型关系、CRUD、分页、事务边界。

> FastAPI「自动文档 + 类型校验」，在自己做简单例子的时候，响应和异常都是一个例子写一个的；到了真正做项目的时候就要封装成方法了，因为如果出现差错或者要改方法，封装的价值就体现出来了。都放在utils文件夹下，表明是工具
