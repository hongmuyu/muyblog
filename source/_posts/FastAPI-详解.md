---
title: "FastAPI 详解"
date: 2026-11-09 13:04:11
updated: 2026-11-09 13:04:11
categories:
  - 后端运维
tags:
  - "FastAPI"
  - "Web 框架"
toc: true
comments: true
---
## FastAPI 详解

## 为什么用 FastAPI（Web 框架）

用 socket 来构建 web 框架太麻烦了，要处理的请求信息繁杂，因此直接用现成的 web 框架来搭建。

![Pasted image 20260328160547.png](/images/notes/FastAPI-详解/计算机网络体系结构.webp)

## 前后端处理

- 前后端不分离：后端不仅要处理数据，而且要构建前端模板，渲染到前端界面中。
- 前后端分离：后端只需要专注于数据处理即可，不负责前端页面处理。

## 接口实现规范：RESTful

RESTful 是一种专门为 Web 开发而定义 API 接口的设计风格，尤其适用于前后端分离：

- 面向资源开发
- 分别使用 POST、DELETE、GET、UPDATE 等请求表示对数据的增删改查
- 不通过路径区分函数（`/student/add` → add、`/student/update` → update），而是在同一路径下通过请求方式实现不同功能（`/student` → add / update）

![rest方法.png](/images/notes/FastAPI-详解/rest方法.webp)
![client、server、app关系.png](/images/notes/FastAPI-详解/client、server、app关系.webp)

uvicorn 是 web 服务器，接收 http 请求转换成 python 函数调用，实现路由映射：

```
路由系统 → 逻辑函数（请求参数、响应方式）→ 数据库操作（ORM）
```

## 快速开始

```python
app = FastAPI()  # 创建 FastAPI 实例
```

uvicorn 运行 FastAPI 项目的服务器：

```bash
uvicorn 项目文件名:FastAPI实例名 --reload  # 重载，修改项目代码会自动重启服务
```

## 路由

路由就是 URL 地址和处理函数之间的映射关系。FastAPI 的路由定义基于 Python 的装饰器模式：

```python
@实例.请求方法("请求路径")
async def 异步函数(...):
    ...
```

## 参数

参数就是客户端发送请求时附带的额外信息和指令，作用是实现多态。分为路径参数、查询参数、请求体。

**路径参数**（`/book/{id}`，形参类型注解）：

```python
async def get_book(id: int = Path(..., gt=0, lt=101, description="书籍id，取值范围1-100")):
    ...
async def get_name(name: str = Path(..., min_length=2, max_length=10)):
    ...
```

**查询参数**（`Query` 做额外类型注解）：

```python
async def get_news_list(skip: int = Query(0, description="跳过的记录数", lt=100)):
    ...
```

**请求体参数**（实际要发送的内容）：

```python
class User(BaseModel):
    username: str = Field(default="张三", min_length=2, max_length=10, description="用户名，长度要求2-10个字")
    password: str = Field(min_length=3, max_length=20)
```

## 响应处理

处理函数的响应数据格式和定义的响应类型一致。响应类型：JSON / HTML / 文件。

自定义响应数据格式：

```python
class News(BaseModel):
    id: int
    title: str
    content: str

@app.get("/news/{id}", response_model=News)
```

异常响应处理：`raise HTTPException()`

## 中间件

使用中间件为每个请求前后添加统一的处理逻辑：

```python
@app.middleware("http")
async def 异步函数(请求, 传递请求的函数):
    await call_next(request)  # 异步等待响应结果
```

多个中间件自下而上执行。

## 依赖注入

使用依赖注入系统共享通用逻辑，减少代码重复：

```python
async def common_parameters(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, le=60)
):
    return {"skip": skip, "limit": limit}

@app.get("/news/news_list")
async def get_news_list(commons=Depends(common_parameters)):
    return commons
```

## ORM

ORM 用操作对象的方式与数据库交互（SQLAlchemy ORM）。核心：将数据库中的“表”映射为编程语言中的“类”，将“行”映射为“对象”，将“SQL 操作”映射为“对象方法调用”。

创建数据库引擎 → 定义模型类 → 启动应用时建表：

```python
async def create_tables():
    async with async_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)  # Base 模型类的元数据创建

@app.on_event("startup")
async def startup_event():
    await create_tables()
```

ORM 把常用数据库操作翻译成 Python 语法：

- **Create**：`session.add(user)` →`INSERT INTO user (...)`
- **Read**：`select(User).where(User.age > 18)` →`SELECT * FROM user WHERE age > 18`
- **Update**：修改属性后`commit()` →`UPDATE user SET ...`
- **Delete**：`session.delete(user)` →`DELETE FROM user WHERE ...`

流程：`Python语法/对象操作` →`ORM引擎翻译` →`执行底层SQL` →`数据库返回原始数据` →`ORM封装成对象` →`获取对象属性数据`

更新和删除都得先查数据是否存在。
