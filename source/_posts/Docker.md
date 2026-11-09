---
title: "Docker"
date: 2026-07-05 12:59:29
updated: 2026-11-09 13:04:11
categories:
  - 后端运维
tags:
  - "Docker"
  - "容器"
toc: true
comments: true
---
## Docker 笔记（精简版）

## 1. Docker 基础概念

### 什么是 Docker

Docker 是一个容器化平台，用于将应用及其依赖打包后运行在容器中。

### 镜像（Image）

镜像是应用运行的模板。

```text
镜像 = 类
容器 = 对象
```

例如：

```bash
redis:8.0
mongo:4.2
nginx:latest
```

### 容器（Container）

镜像运行后产生的实例。

```bash
docker run redis
```

执行后：

```text
redis镜像 → redis容器
```

---

## 2. Docker 与虚拟机

| Docker容器 | 虚拟机    |
| -------- | ------ |
| 共享宿主机内核  | 独立操作系统 |
| 启动秒级     | 启动分钟级  |
| 占用资源少    | 占用资源多  |
| 轻量级      | 较重     |

---

## 3. 镜像操作

### 拉取镜像

```bash
docker pull redis
docker pull redis:8.0
docker pull mongo:4.2
```

Docker Hub 完整写法：

```bash
docker pull docker.io/library/mongo:4.2
```

AWS ECR：

```bash
docker pull 520697001743.dkr.ecr.eu-central-1.amazonaws.com/my-app:1.0
```

### 查看镜像

```bash
docker images
```

### 删除镜像

```bash
docker rmi IMAGE_ID
```

---

## 4. 容器操作

### 创建并运行

```bash
docker run redis
```

后台运行：

```bash
docker run -d redis
```

指定名称：

```bash
docker run -d --name my-redis redis
```

端口映射：

```bash
docker run -p 6000:6379 redis
```

格式：

```text
宿主机端口:容器端口
```

### 查看容器

```bash
docker ps
```

查看全部容器：

```bash
docker ps -a
```

### 停止容器

```bash
docker stop CONTAINER_ID
```

### 启动容器

```bash
docker start CONTAINER_ID
```

### 删除容器

```bash
docker rm CONTAINER_ID
```

---

## 5. 容器调试

### 查看日志

```bash
docker logs CONTAINER_ID
```

实时查看：

```bash
docker logs -f CONTAINER_ID
```

### 进入容器

```bash
docker exec -it CONTAINER_ID /bin/sh
```

或

```bash
docker exec -it CONTAINER_ID /bin/bash
```

---

## 6. Docker 网络

查看网络：

```bash
docker network ls
```

创建网络：

```bash
docker network create my-network
```

容器加入网络：

```bash
docker run -d \
  --network my-network \
  --name mongo \
  mongo
```

Mongo 示例：

```bash
docker run -d \
  --network some-network \
  --name some-mongo \
  -e MONGO_INITDB_ROOT_USERNAME=mongoadmin \
  -e MONGO_INITDB_ROOT_PASSWORD=secret \
  mongo
```

作用：

```text
同一网络中的容器可以直接通过容器名通信。
```

---

## 7. Docker Compose

用于管理多个容器。
### 示例：MongoDB + Mongo Express

Mongo Express 是 MongoDB 的 Web 管理界面。

```YAML
services:  
	mongo:  
		image: mongo:4.2  
		container_name: mongo  
		restart: always  
		environment:  
			MONGO_INITDB_ROOT_USERNAME: admin  
			MONGO_INITDB_ROOT_PASSWORD: 123456  
		volumes:  
			- mongo-data:/data/db  
  
	mongo-express:  
		image: mongo-express  
		container_name: mongo-express  
		restart: always  
		ports:  
			- "8081:8081"  
		environment:  
			ME_CONFIG_MONGODB_ADMINUSERNAME: admin  
			ME_CONFIG_MONGODB_ADMINPASSWORD: 123456  
			ME_CONFIG_MONGODB_URL: mongodb://admin:123456@mongo:27017/  
  
volumes:  
	mongo-data:
```

启动：

```
docker compose up -d
```

访问：

```
http://localhost:8081
```

停止：

```bash
docker compose down
```

典型场景：

```text
Node.js
MongoDB
Redis
Nginx
```

统一使用一个 compose 文件管理。

---

## 8. Dockerfile

用于构建自己的镜像。

### Dockerfile 示例

```dockerfile
FROM node:20

WORKDIR /app

COPY . .

RUN npm install

CMD ["npm","start"]
```

### 构建镜像

```bash
docker build -t my-app .
```

### 运行镜像

```bash
docker run my-app
```

---

## 9. Docker Hub 与镜像仓库

### 登录

```bash
docker login
```

### 给镜像打标签

```bash
docker tag my-app username/my-app:1.0
```

### 推送镜像

```bash
docker push username/my-app:1.0
```

### 服务器部署

开发服务器拉取：

```bash
docker pull username/my-app:1.0
```

启动：

```bash
docker run -d username/my-app:1.0
```

---

## 10. Docker Volume（数据卷）

### 为什么需要 Volume

容器删除后：

```text
容器数据会丢失
```

数据库尤其需要持久化存储。

### 创建 Volume

```bash
docker volume create mongo-data
```

### 挂载 Volume

```bash
docker run -d \
  -v mongo-data:/data/db \
  mongo
```

### 查看 Volume

```bash
docker volume ls
```

---

## 11. Docker 开发部署流程

```text
编写代码
    ↓
编写 Dockerfile
    ↓
docker build
    ↓
生成镜像
    ↓
docker run
    ↓
测试容器
    ↓
docker push
    ↓
上传 Docker Hub/ECR
    ↓
服务器 docker pull
    ↓
docker compose up -d
    ↓
部署完成
```

---

## 12. 最常用命令速查

```bash
# 镜像
docker pull redis
docker images
docker rmi IMAGE_ID

# 容器
docker run redis
docker run -d redis
docker ps
docker ps -a
docker stop CONTAINER_ID
docker start CONTAINER_ID
docker rm CONTAINER_ID

# 调试
docker logs CONTAINER_ID
docker exec -it CONTAINER_ID /bin/sh

# 网络
docker network ls

# 数据卷
docker volume ls

# 构建
docker build -t my-app .

# Compose
docker compose up -d
docker compose down

# 仓库
docker login
docker tag IMAGE USER/IMAGE:TAG
docker push USER/IMAGE:TAG
```

### 一句话记忆

```text
Docker = 镜像(Image) + 容器(Container) + 网络(Network) + 数据卷(Volume)

Dockerfile → build → Image
Image → run → Container
Container → push/pull → Registry(Docker Hub/ECR)
Volume → 持久化数据
Compose → 管理多个容器
```
