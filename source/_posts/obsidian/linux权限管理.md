---
title: "linux权限管理"
date: 2026-07-05 12:59:29
updated: 2026-07-05 12:59:29
permalink: /notes/linux权限管理/
categories:
  - 🛠️ 服务器与运维
tags: []
toc: true
comments: true
---
```bash
# sudo：以管理员权限执行命令
sudo apt update

# chown：修改文件/目录所有者
chown user file.txt
chown -R user:group project/

# chmod：修改权限
chmod 755 script.sh
chmod 644 file.txt
chmod +x script.sh
```

权限数字：

```text
r = 4  (读)
w = 2  (写)
x = 1  (执行)

7 = rwx
6 = rw-
5 = r-x
4 = r--
```

常见权限：

```text
755  rwxr-xr-x  可执行程序
644  rw-r--r--  普通文件
777  rwxrwxrwx  不推荐
```

查看权限：

```bash
ls -l
```

一句话：

```text
sudo  → 提权
chown → 改所有者
chmod → 改权限
ls -l → 看权限
```
