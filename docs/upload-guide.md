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

### 方法三：使用优化脚本
本博客提供了强大的图片处理脚本：

1. **批量图片处理** (`bin/process-images.sh`):
```bash
# 基本用法：压缩uploads目录中的图片
./bin/process-images.sh -s source/images/uploads -d source/images/optimized

# 转换为WebP格式
./bin/process-images.sh -f webp -q 85

# 创建备份并重命名文件
./bin/process-images.sh -b -r -v
```

2. **WebP专门优化** (`bin/optimize-images.sh`):
```bash
# 交互式WebP优化工具
./bin/optimize-images.sh
# 然后选择优化模式（单个目录、批量转换、文章资源文件夹等）
```

3. **图片引用更新** (`bin/update-image-refs.sh`):
```bash
# 批量更新文章中的图片引用（运行optimize-images.sh后生成）
./bin/update-image-refs.sh
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

### 批量上传与优化
```bash
# 1. 使用PicGo命令行批量上传
picgo upload 图片1.jpg 图片2.png

# 2. 使用博客脚本批量优化
./bin/process-images.sh --source ~/Downloads --format webp

# 3. 批量更新文章引用
find source/_posts -name "*.md" -exec sed -i 's/\.jpg/.webp/g' {} \;
```

### 自动压缩与转换
1. **PicGo插件配置**:
   - 安装 `picgo-plugin-compress` 插件
   - 启用自动压缩功能
   - 设置压缩质量

2. **博客自动化脚本**:
   - `bin/optimize-images.sh`: 交互式WebP转换工具
   - 支持响应式图片生成 (srcset)
   - 自动生成图片使用指南

### 响应式图片支持
博客支持生成响应式图片，为不同设备提供合适尺寸：

```bash
# 生成响应式图片
./bin/optimize-images.sh
# 选择模式4: "生成响应式图片(srcset)"
```

生成的文件结构:
```
source/images/responsive/
├── 图片名_400w.jpg
├── 图片名_400w.webp
├── 图片名_800w.jpg
├── 图片名_800w.webp
└── 图片名_1200w.jpg
```

### 图片懒加载
已配置图片懒加载功能，在 `source/_data/styles.styl` 中定义：
- 图片加载时淡入效果
- 支持原生 `loading="lazy"` 属性
- 移动端优化

## 注意事项与最佳实践

### 存储管理
1. **GitHub存储限制**：免费账户1GB，注意监控使用量
2. **图片压缩**：上传前使用脚本压缩，目标质量80-85%
3. **格式选择**：优先使用WebP格式，节省30-50%空间
4. **定期清理**：每季度检查并删除未使用的图片

### 性能优化
1. **图片尺寸**：博客图片宽度建议不超过1200px
2. **懒加载**：所有图片添加 `loading="lazy"` 属性
3. **响应式图片**：为重要图片生成srcset多尺寸版本
4. **缓存策略**：利用GitHub Pages的CDN缓存

### 工作流程
1. **上传前**：使用 `process-images.sh` 压缩和转换格式
2. **上传后**：运行 `optimize-images.sh` 生成优化版本
3. **发布前**：检查所有图片引用，确保使用WebP优先
4. **定期维护**：每月运行一次图片优化脚本

### 备份策略
1. **本地备份**：重要图片保留原始文件
2. **版本控制**：GitHub仓库自动版本管理
3. **多重备份**：考虑使用多个图床服务冗余备份
4. **导出备份**：每年导出一次完整图片库