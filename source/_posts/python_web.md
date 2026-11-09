---
title: "python_web"
date: 2026-11-02 20:36:33
updated: 2026-11-02 20:36:33
categories:
  - 🐍 Web 后端
tags: []
toc: true
comments: true
---
代码变成服务

app=FastAPI()   # 创建FastAPI实例

uvicorn 运行FastAPI项目的服务器
uvicorn 项目文件名:FastAPI实例名 --reload  重载，修改项目代码会自动重启服务，不需要手动

路由就是URL地址和处理函数之间的映射关系
FastAPI的路由定义基于python的装饰器模式
@实例.请求方法("请求路径)
异步函数

参数就是客户端发送请求时附带的额外信息和指令
参数的作用是实现多态

路径参数、查询参数、请求体
/book/{id}
形参类型注解

path作额外的类型注解

路径参数-类型注解Path
async def get_book(id: int = Path(..., gt=0, lt=101, description="书籍id，取值范围1-100")):
async def get_name(name: str = Path(..., min_length=2, max_length=10)):

查询参数
async def get_news_list(skip: int = Query(0, description="跳过的记录数", lt=100))
Query作额外的类型注解

请求体参数
请求体：实际要发送的内容
class User(BaseModel):
    username: str = Field(default="张三", min_length=2, max_length=10, description="用户名，长度要求2-10个字")
    password: str = Field(min_length=3, max_length=20)

---

处理函数的响应数据格式和定义的响应类型一致
响应类型：Jason/HTML/文件
自定义响应数据格式
class News(BaseModel):
    id: int
    title: str
    content: str
路径装饰器
@app.get("/news/{id}", response_model=News)
装饰器中设置响应类和返回响应对象

异常响应处理
raise HTTPException()

---

使用中间件为每个请求前后添加统一的处理逻辑
@app.middleware("http")   装饰器函数
async def 异步函数(请求, 传递请求的函数):
	await call_next(request)  异步等待响应结果

多个中间件自下而上执行

使用依赖注入系统来共享通用逻辑，减少代码重复
依赖项 ##
async def common_parameters(
    skip: int = Query(0, ge=0),
    limit: int = Query(10, le=60)
):
    return {"skip": skip, "limit": limit}
依赖注入  ##
@app.get("/news/news_list")
async def get_news_list(commons=Depends(common_parameters)):
    return commons

---

ORM，操作对象的方式与数据库进行交互
SQLALchemy ORM
创建数据库引擎->定义模型类->启动应用时建表
async def create_tables():
    # 获取异步引擎，创建事务 - 建表
    async with async_engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)  # Base 模型类的元数据创建

@app.on_event("startup")
async def startup_event():
    await create_tables()

层层嵌套，联系到一起

依赖注入数据库会话对象，能查询到结果说明注入成功

ORM 核心：将数据库中的“表”映射为编程语言中的“类”，将“行”映射为“对象”，将“SQL 操作”映射为“对象方法调用”。

ORM 把常用的数据库操作翻译成了 Python 语法：

- **Create**：`session.add(user)` ➡️ 翻译为`INSERT INTO user (...)`

- **Read**：`select(User).where(User.age > 18)` ➡️ 翻译为`SELECT * FROM user WHERE age > 18`

- **Update**：修改属性后`commit()` ➡️ 翻译为`UPDATE user SET ...`

- **Delete**：`session.delete(user)` ➡️ 翻译为`DELETE FROM user WHERE ...`

`Python语法/对象操作` ➡️`ORM引擎翻译` ➡️`执行底层SQL` ➡️`数据库返回原始数据` ➡️`ORM封装成对象` ➡️`获取对象属性数据`

更新和删除都得先查数据是否存在
