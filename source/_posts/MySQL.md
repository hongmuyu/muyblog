---
title: "MySQL"
date: 2026-11-09 13:04:11
updated: 2026-11-09 13:16:44
categories:
  - 后端运维
tags:
  - "MySQL"
  - "数据库"
toc: true
comments: true
---
## MySQL 基础部分

## 一、知识框架

### 基础
SQL、函数、约束、多表查询、事务

### 进阶
存储引擎、索引、SQL 优化、视图 / 存储过程 / 触发器、锁、InnoDB 核心、MySQL 管理

### 运维
日志、主从复制、分库分表、读写分离

---

## 二、关系型数据库与 SQL 分类

关系型数据库以表的形式组织数据，并通过 SQL 进行管理与操作。

SQL 按功能可分为四类：

- **DDL（数据定义语言）**：定义数据库、表等结构；
- **DML（数据操作语言）**：对表中的数据进行增、删、改；
- **DQL（数据查询语言）**：查询数据；
- **DCL（数据控制语言）**：控制访问权限等。

---

## 三、数据库与表操作

### 1. 数据库操作

常用命令包括：

-`show`：查看数据库；
-`select`：查询当前数据库等；
-`create`：创建数据库；
-`drop`：删除数据库；
-`use`：切换数据库。

### 2. 表操作

常用命令包括：

-`show`：查看表；
-`desc`：查看表结构；
-`show create table`：查看建表语句；
-`create`：创建表；
-`alter table ... add / drop / change / modify / rename to`：修改表结构；
-`drop table`：删除表；
-`insert / update / delete`：对表数据进行增、删、改；
-`truncate table`：清空表数据。

### 3. 注释说明

创建表或修改字段时，可以通过`COMMENT` 为表名或字段名添加说明，便于后续维护和理解。

---

## 四、外键约束

外键用于维护表与表之间的引用关系。

删除或更新外键关联数据时，常见行为包括：

-`NO ACTION`
-`RESTRICT`
-`CASCADE`
-`SET NULL`
-`SET DEFAULT`

这些行为分别对应`ON UPDATE` 和`ON DELETE` 场景。

---

## 五、DML 与 DQL

### 1. DML

DML 主要用于操作表中的数据：

-`insert into ... values ...`：插入数据；
-`update ... set ...`：更新数据；
-`delete from ...`：删除数据。

### 2. DQL

DQL 查询的基本结构为：

`select ... from ... where ... group by ... having ... order by ... limit ...`

常用查询能力包括：

-`as`：为字段起别名；
-`distinct`：去重；
- 聚合函数：作用于字段列表，进行纵向计算；
- 分组查询：`where` 在分组前过滤，`having` 在分组后对结果过滤；
- 排序查询；
- 分页查询；
- 联合查询：`union`。

---

## 六、子查询

子查询可出现在：

-`from` 子句中；
-`select` 子句中；
-`where` 子句中。

---

## 七、事务

事务是一组 SQL 操作，要么全部成功，要么全部失败并回滚。

事务具有 ACID 特性：

- **A 原子性（Atomicity）**：事务不可分割，全部成功或全部回滚；
- **C 一致性（Consistency）**：事务前后数据合法，约束保持不变；
- **I 隔离性（Isolation）**：多个事务之间互不干扰，通过隔离级别控制；
- **D 持久性（Durability）**：事务提交后数据永久写入磁盘，宕机不丢失。

常见并发问题及对应隔离级别：

- **脏读**：可通过“读已提交”及以上隔离级别避免；
- **不可重复读**：可通过“可重复读”及以上隔离级别避免；
- **幻读**：可通过“串行化”隔离级别避免。
