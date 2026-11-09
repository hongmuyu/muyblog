---
title: "MySQL"
date: 2026-11-03 20:10:09
updated: 2026-11-03 20:10:09
permalink: /notes/MySQL/
categories:
  - 🐍 Web 后端
tags: []
toc: true
comments: true
---
基础：
SQL、函数、约束、多表查询、事务
进阶：
存储引擎、索引、SQL优化、视图/存储过程/触发器、锁、InnoDB核心、MySQL管理
运维：
日志、主从复制、分库分表、读写分离

---

关系型数据库
SQL分类：DDL、DML、DQL、DCL（定义、操作、查询、控制）
数据库操作：
show
select
create
drop
use
表操作：
show
desc
show create table
create
alter table __ add/drop/change/modify/rename to/   对表结构进行修改
drop table __
insert/update/delete 对表的数据进行增删改操作
truncate table __

comment：在创建表或修改字段时，你可以给表名或字段名加上`COMMENT` 说明。

---

外键约束
删除/更新行为：(on update,on delete)
NO ACTION,RESTRICT,CASCADE,SET NULL,SET DEFAULT.

---

DML
insert into    values
update  set
delete from

DQL
select    from   where    group by    having     oder by     limit
as 给字段起别名
distinct 去重
聚合函数作用于字段列表，进行纵向计算
分组查询：where是分组之前过滤，having是分组之后对结果过滤
排序查询、分页查询
联合查询  Union

---

子查询 （from , select , where)

---

事务：一组 SQL，要么全部成功，要么全部失败回滚
 ACID
- A 原子性 Atomicity：不可分割，全成或全回滚
- C 一致性 Consistency：事务前后数据合法（约束不变）
- I 隔离性 Isolation：多个事务互不干扰（靠隔离级别控制）
- D 持久性 Durability：提交后数据永久写入磁盘，宕机不丢
脏读（读已提交）、不可重复读（可重复读）、幻读（串行化）
