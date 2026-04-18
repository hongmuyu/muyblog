# 图片上传指南

## 方案选择
推荐使用 **PicGo + GitHub图床** 方案，无需服务器，永久免费。

## 配置步骤

### 1. 创建GitHub图床仓库
1. 登录 GitHub，创建新仓库，如：`blog-images`
2. 设置为 **私有仓库** (Private)
3. 记录仓库地址：`你的用户名/blog-images`

### 2. 生成GitHub Token
1. 访问：GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. 点击 "Generate new token (classic)"
3. 权限选择：`repo` (全选)
4. 生成并保存Token（只显示一次）

### 3. 安装配置PicGo
1. 下载安装 [PicGo](https://github.com/Molunerfinn/PicGo/releases)
2. 打开 PicGo → 图床设置 → GitHub图床
3. 填写配置：
   - 仓库名：`你的用户名/blog-images`
   - 分支：`main`
   - Token：刚才生成的Token
   - 存储路径：`blog/{year}/{month}/`
   - 自定义域名：`https://raw.githubusercontent.com/你的用户名/blog-images/main`

### 4. Hexo配置优化
已启用 `post_asset_folder: true`，创建文章时会自动生成同名文件夹存放图片。

## 使用方式

### 方法一：PicGo上传（推荐）
1. 截图或复制图片
2. PicGo自动上传并复制Markdown链接
3. 在文章中粘贴：`![描述](图片链接)`

### 方法二：本地图片
1. 将图片放入文章对应的资源文件夹：`source/_posts/文章标题/`
2. 文章中引用：`![描述](图片文件名.jpg)`
3. Hexo会自动处理路径

### 方法三：命令行工具
```bash
# 使用脚本辅助上传（需自定义）
./bin/image-upload.sh 图片路径
```

## 最佳实践

1. **命名规范**：使用英文、小写、连字符，如 `react-hooks-example.png`
2. **图片优化**：上传前压缩图片，推荐工具：
   - [TinyPNG](https://tinypng.com/) - 在线压缩
   - [ImageOptim](https://imageoptim.com/) - 本地工具
3. **备份策略**：GitHub仓库自动备份，建议每月本地备份一次

## 故障排除

### 图片不显示
- 检查GitHub仓库是否为私有（私有仓库需要Token）
- 检查Token是否过期
- 检查PicGo配置中的自定义域名

### 本地图片路径错误
- 确保已安装 `hexo-asset-image` 插件
- 检查 `_config.yml` 中 `post_asset_folder: true`
- 重启Hexo服务：`hexo clean && hexo server`

## 高级功能

### 批量上传
```bash
# 使用PicGo命令行
picgo upload 图片1.jpg 图片2.png
```

### 自动压缩
配置PicGo插件：
1. 安装 `picgo-plugin-compress` 插件
2. 启用自动压缩功能

## 注意事项
1. GitHub免费账户有存储限制（1GB）
2. 大图片建议先压缩再上传
3. 定期清理未使用的图片
4. 重要图片建议本地备份