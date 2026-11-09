---
title: "Linux 常用终端命令速查"
date: 2026-07-05 12:59:29
updated: 2026-07-05 12:59:29
permalink: /notes/Linux-常用终端命令速查/
categories:
  - 🛠️ 服务器与运维
tags: []
toc: true
comments: true
---
## 目录操作

```bash
pwd              # 当前目录
cd               # 回到主目录
cd ..            # 上级目录
cd -             # 上一次目录

ls               # 列出目录内容
ls -a            # 包含隐藏文件
ls -l            # 详细信息
ls -h            # 人类可读格式
ls -lah          # 常用组合
```

## 文件与目录

```bash
mkdir dir        # 创建目录
mkdir -p a/b/c   # 递归创建目录

rmdir dir        # 删除空目录
rmdir -p a/b/c   # 递归删除空目录

touch file.txt   # 创建文件
file file.txt    # 查看文件类型
```

## 文件查看

```bash
cat file.txt         # 查看全部内容
head file.txt        # 前10行
head -n 20 file.txt  # 前20行

tail file.txt        # 后10行
tail -n 20 file.txt  # 后20行
tail -f log.txt      # 实时查看日志

more file.txt
less file.txt

echo "hello"
echo "hello" > file.txt
echo "hello" >> file.txt
```

## 复制、移动、删除

```bash
cp file1 file2       # 复制文件
cp -r dir1 dir2      # 复制目录

mv old new           # 重命名
mv file dir/         # 移动文件

rm file.txt          # 删除文件
rm -i file.txt       # 删除前确认
rm -r dir/           # 删除目录
rm -rf dir/          # 强制递归删除
```

## 查找

```bash
find . -name "*.txt"
find / -name nginx.conf

which python
whereis python
```

## 系统信息

```bash
uptime          # 运行时长
free -h         # 内存使用
df -h           # 磁盘使用
lsblk           # 磁盘设备
fdisk -l        # 分区信息

uname -a        # 内核信息
hostnamectl     # 系统信息
```

## 进程管理

```bash
ps
ps aux

top
htop

kill PID
kill -9 PID

pkill nginx

ps aux | grep python
```

## 网络管理

```bash
ip a            # 查看IP
ip route        # 查看路由

ifconfig        # 老命令

ping baidu.com

curl URL
wget URL

ss -tulpn       # 查看端口
netstat -tulpn  # 老命令
```

## 权限管理

```bash
sudo command

whoami
id

chmod +x run.sh
chown user:user file.txt
```

## 软件管理（Ubuntu）

```bash
sudo apt update
sudo apt upgrade

sudo apt install nginx
sudo apt remove nginx

apt search nginx
apt list --installed
```

## 文本编辑

### Nano

```bash
nano file.txt
```

常用快捷键：

```text
Ctrl + O    保存
Ctrl + X    退出
Ctrl + K    剪切行
Ctrl + U    粘贴
```

### Vim

```bash
vim file.txt
```

```text
i      插入模式
Esc    命令模式
:w     保存
:q     退出
:wq    保存并退出
:q!    强制退出
```

## Ubuntu 服务器高频命令

```bash
pwd
ls -lah
cd
mkdir -p
rm -rf

cp -r
mv

cat
tail -f

find

ps aux
top
kill -9

free -h
df -h
lsblk

ip a
ss -tulpn

sudo apt update
sudo apt upgrade
```
