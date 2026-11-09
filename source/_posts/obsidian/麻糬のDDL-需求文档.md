---
title: "麻糬のDDL 需求文档"
date: 2026-06-04 22:44:24
updated: 2026-07-05 12:59:29
permalink: /notes/麻糬のDDL-需求文档/
categories:
  - 🚀 项目实战
tags: []
toc: true
comments: true
---
## 1. 应用概述

### 1.1 应用名称

麻糬のDDL

### 1.2 副标题

一个会陪你一起崩溃的DDL模拟器

### 1.3 应用描述

麻糬のDDL是一个大学生精神状态模拟器，将大学生面对DDL、熬夜、摸鱼、崩溃的过程做成具有「可爱发疯」演出感的互动产品。核心目标：有趣、抽象、有代入感、有分享欲、有互联网梗文化。

### 1.4 产品定位

不是传统Todo App，而是通过精神状态可视化+吉祥物情绪演出，让用户在崩溃中获得快乐。用户不是在管理任务，而是在努力活过这周。

### 1.5 版本说明

本文档为v2.5版本PRD，涵盖麻糬のDDL从功能定义、交互设计、数据模型、业务规则到工程交付的完整需求。核心目标：工程级完全可落地。

---

## 2. 用户与使用场景

### 2.1 目标用户

- 大学生群体
- 经常赶DDL、熬夜、有拖延症
- 喜欢互联网抽象文化和游戏化产品
- 下载过多个Todo App但很难长期坚持
- 喜欢有情绪反馈的产品，喜欢截图分享

### 2.2 核心使用场景

- 添加作业、考试、实验、项目等DDL任务
- 查看当前生存状态和最危险DDL
- 记录学习、摸鱼、熬夜时间
- 体验UI情绪演出效果（可爱崩坏）
- 查看动态生成的人格称号和吐槽文案
- 解锁成就系统
- 生成并分享每日精神状态卡片到社交平台
- 查看数据统计与历史记录
- 自定义激励语录

---

## 3. 页面结构与功能说明

### 3.1 页面结构

```
麻糬のDDL App
├── 底部导航栏
│   ├── 状态（首页）
│   ├── DDL
│   ├── 摸鱼
│   ├── 卡片
│   └── 设置
├── 首页（生存状态总览）
├── DDL页面（Boss战列表）
├── 摸鱼页面（时间统计）
├── 卡片页面（生存日报）
├── 设置页
│   ├── 我的成就
│   ├── 主题与外观
│   ├── DDL提醒
│   ├── 数据统计
│   ├── 自定义语录
│   ├── 日切点设置
│   └── 关于DDLife
├── 成就页面
├── 数据统计页面
├── 自定义语录管理页面
└── 日切点设置页面
```

### 3.2 首页（生存状态总览）

#### 3.2.1 吉祥物展示

- 展示圆滚滚糯米团子形象的吉祥物（麻糬）
- 根据精神状态动态变化表情和动作
- 精神好：戴小花，蹦蹦跳跳
- 有点累：黑眼圈出现，发呆
- 红温：全身橙红色，头顶冒蒸汽，眼睛变漩涡
- 完成任务：瘫软成一滩，旁边有小音响
- 濒死状态（HP<10%）：吉祥物呈现濒死状态
- 功德值负数时：吉祥物头上出现「功德-∞」漂浮特效
- 点击吉祥物随机显示激励语录（从自定义语录库+内置语录库中抽取）

#### 3.2.2 生存状态面板

- 展示生命值（今日）（0-100%）
- 展示磨损值（累计）（0-100%）
- 展示理智值（0-100%）
- 展示睡眠债（+Xh格式，0-24h上限）
- 展示功德值（负数，无上限）
- 使用荧光笔高亮效果展示数据
- 理智值<20%时「一键摸鱼」按钮闪烁

#### 3.2.3 当前最危险DDL展示

- 显示任务名称
- 显示血条进度（果汁状液体晃动效果）
- 显示剩余时间（跳动数字+小沙漏）
- 高优先级任务血条有金色镶边效果
- 示例：高数作业 Lv.92 ⭐⭐⭐ | 剩余生命：13h

#### 3.2.4 今日人格检测结果

- 显示今日人格称号
- 显示生成原因
- 显示系统建议
- 示例：今日人格：濒危脆皮大学生 | 原因：连续熬夜2天，DDL数量>5 | 系统建议：建议直接冬眠。

#### 3.2.5 宿舍精神状态语录

- 随机位置出现彩蛋文案
- 示例：你室友已经开始写第二遍了。 / 隔壁床还在刷短视频。 / 现在打开PPT，你还有机会。

#### 3.2.6 UI情绪演出效果

动画效果根据设备性能动态分级（详见§7.3动态UI效果分级）：

- DDL安全/状态良好：奶油白背景，吉祥物睡觉/吃零食，元素轻微浮动
- DDL临近/轻度紧张：血条变成果汁状液体晃动，倒计时数字霓虹闪烁，吉祥物流汗、瞳孔地震，背景开始渐变淡粉
- 红温/濒危：背景从奶油白渐变为淡粉色，文字轻微歪斜，局部出现贴纸错位，吉祥物全身橙红、头顶冒蒸汽
- 极限压线完成：全屏炸出彩色纸花+表情包烟花，任务卡片裂开后出现完成涂鸦

#### 3.2.7 通知权限提示（Level 1）

通知权限提示条增加「不再提示」按钮，用户可永久关闭。

- 通知权限关闭时，首页常驻粉红提示条
- 提示文案：「开启通知可在DDL截止前1小时收到提醒 → 去开启权限」
- 点击跳转到系统设置页

### 3.3 DDL页面（Boss战列表）

#### 3.3.1 任务创建

- 用户输入任务名称
- 用户选择截止时间
- 用户选择优先级（低/中/高）
- **系统自动记录任务创建时间戳（created_at），用于血条分母计算**

#### 3.3.2 任务展示

- 每个任务显示为圆角小卡片
- 卡片颜色按难度渐变（粉→橙→红）
- 显示任务名称
- 显示等级（Lv.XX）
- 显示星级（⭐数量）
- 显示剩余生命（Xh格式）
- 剩余时间用跳动数字+小沙漏展示
- 高优先级任务血条有金色镶边效果
- 任务按优先级倒序排列（高→中→低）
- 示例：⚠ 高数作业 Lv.92 ⭐⭐⭐ | 剩余生命：13h

#### 3.3.3 任务操作

- 标记任务完成（触发彩色纸花动画效果）
- 删除任务
- 编辑任务
- **过期任务支持"补完成"操作**：任务截止时间过后，卡片变灰，"完成"按钮文案变为"补完成"。点击后弹窗确认："超时完成，功德值-10，确定吗？"确认后任务标记为超时完成状态，扣减功德值10，不触发正面加分。

**惩罚性删除（Anti-Cheat §1）**

统一惩罚条件为：删除时剩余时间 < 12h（含濒死<3h子集），或优先级 ≥ 中 的未完成任务，均触发惩罚。

- 当用户删除一个**当前状态为"红温"（剩余时间<12h，其中<3h为"濒死"子状态），或优先级 ≥ 中**的未完成任务时，弹出警告：

    > ⚠️ 临时删除DDL可不会让你的身体免于伤害！删除此任务将**立即扣除5点生命值和10点功德值**作为惩罚。确定要临阵脱逃吗？

- 用户确认后，惩罚**立即生效**：扣减当前HP和功德值，并写入操作日志。

**过期任务编辑限制（Anti-Cheat §2）**

- 任务进入"已过期"状态（`is_expired = 1`，由`deadline < now && status != 'completed'`自动推导）后，**其`截止时间`字段锁定为只读**，在编辑弹窗中显示为置灰不可交互。
- 用户只能对已过期任务执行"补完成"或"删除"操作，**不得将截止时间改回未来以绕过惩罚**。

#### 3.3.4 危险等级系统

- 剩余时间>48h：安全，粉色卡片
- 剩余时间24~48h：注意，橙色卡片
- 剩余时间12~24h：危险，橙红色卡片
- 剩余时间<12h：红温，红色卡片+UI情绪演出
- 剩余时间<3h：濒死，红色卡片+极限UI情绪演出
- 同剩余时间的任务，优先级越高越倾向提前一级标红

#### 3.3.5 通知权限提示（Level 1）

通知权限提示条增加「不再提示」按钮，用户可永久关闭。

- 通知权限关闭时，DDL列表页顶部显示粉红提示条
- 提示文案：「开启通知可在DDL截止前1小时收到提醒 → 去开启权限」
- 点击跳转到系统设置页

### 3.4 摸鱼页面（时间统计）

#### 3.4.1 时间记录

明确用户输入的是"实际睡眠小时数"，UI将其转译为"熬夜时长"（`8 - sleep_hours`）。

- 用户记录学习时间（手动输入或计时器）
- 用户记录摸鱼时间（手动输入或计时器）
- 用户记录睡眠时间（手动输入，底层存储为`sleep_hours`，UI转译见§4.15b）

#### 3.4.2 计时器功能

- 学习计时器：开始/停止按钮，记录开始和结束时间戳
- 摸鱼计时器：开始/停止按钮，记录开始和结束时间戳
- 计时会话写入`timer_sessions`表（见§4.12.2）

**计时器异常恢复流程**（Anti-Cheat §3）：

统一异常恢复上限为4小时，修正伪代码。

- App启动时，若检测到未结束的计时会话（`timer_sessions`中存在`end_timestamp IS NULL`的行），计算`elapsed = now_ts - start_ts`。
- **若`elapsed > 4 × 3600`（超过4小时），本次会话直接强制作废**，弹窗提示："这次的计时记录超过了4小时，麻糬判定为异常会话，已自动作废。下次不要忘记关计时器哦~"，不给予任何时长收益。
- 若`elapsed ≤ 4 × 3600`，弹窗提示："检测到上次学习/摸鱼未结束，已过去X小时Y分钟，是否记录？"
    - **记录**：将 elapsed 按日切点拆分累加到`daily_aggregates`对应日期，清除会话。
    - **丢弃**：清除会话，不记录任何数据。
    - **继续**：重置`start_ts = now`，保留`session_type`，重新开始计时。
- 用户不操作时默认保留会话，下次启动再次询问。
- 若检测到单日通过"异常恢复"累计超过12小时，计时器功能锁定，显示提示："今日计时异常次数过多，为保证数据真实性，麻糬暂时收走了计时器。"并引导用户使用手动输入。

#### 3.4.3 手动输入功能

- 手动输入学习时间（0-24小时）
- 手动输入摸鱼时间（0-24小时）
- 手动输入睡眠时间（0-24小时）
- 手动录入存入`time_records`表的`manual_study_minutes`/`manual_slack_minutes`/`sleep_hours`字段
- 输入超过24小时时提示：「一天最多24小时哦~」
- 手动修改时显示确认弹窗：「手动输入将覆盖今日计时器记录，确定吗？」

#### 3.4.4 时间展示

- 显示今日学习时间（有手动值时优先显示手动值）
- 显示今日摸鱼时间（有手动值时优先显示手动值）
- 显示今日睡眠时间（UI转译为熬夜时长）
- 显示累计统计数据
- 使用手账风格卡片展示

### 3.5 卡片页面（生存日报）

#### 3.5.1 当日生存日报预览

- 展示当日生成的《生存日报》卡片
- 卡片内容：生命值（今日）、磨损值（累计）、理智值、今日DDL数量、连续熬夜天数、今日人格、系统评价、#今日发疯浓度
- 卡片样式：拍立得/手机相册质感，有胶带、贴纸痕迹，手写体文字，荧光笔高亮数据
- 卡片具有轻微动态效果（数字跳动、血条流动）

#### 3.5.2 操作按钮

- 「保存到相册」按钮：保存当日卡片图片到手机相册
- 「分享」按钮：分享卡片到社交平台

**相册权限申请闭环**：

- 触发时机：用户首次点击"保存到相册"时申请相册写入权限（iOS NSPhotoLibraryAddUsageDescription / Android MediaStore API）。
- 授权成功：直接保存，Toast提示"已保存到相册 📸"。
- 首次拒绝：弹窗引导——"麻糬需要相册权限才能保存你的生存日报，请去设置中开启。"，提供"去设置"和"取消"按钮。
- 再次拒绝：不再重复弹窗，Toast提示"权限未开启，无法保存"。

#### 3.5.3 历史卡片回顾

- 简单列表展示最近生成的卡片
- 每条记录显示生成时间戳
- 点击可查看历史卡片详情

#### 3.5.4 无数据状态

- 若当天无数据，显示麻糬插画
- 提示文案：「今天还没有状态，先去添加 DDL 吧~」

### 3.6 设置页

#### 3.6.1 菜单列表

按顺序展示以下菜单项：

1. 🏆 我的成就

    - 跳转到成就页面
2. 🌈 主题与外观

    - 主题选择（糖果色 Y2K）
3. 🔔 DDL 提醒

    - 通知设置
    - 通知权限关闭时显示「⚠️ 已关闭」标签
4. 📊 数据统计

    - 跳转到数据统计页面
5. 💬 自定义语录

    - 跳转到自定义语录管理页面
6. ⏰ 日切点设置

    - 跳转到日切点设置页面
7. ❓ 关于 DDLife

    - 跳转到关于页面
    - 显示换机数据迁移风险提示

### 3.7 成就页面（成就展示）

#### 3.7.1 成就列表

- 展示已解锁成就
- 展示未解锁成就（灰色状态）
- 每个成就包含：成就名称、成就图标（贴纸）、解锁条件说明

#### 3.7.2 成就解锁动画

- 全屏弹出大贴纸
- 啪一下盖在屏幕上
- 可拖拽分享

#### 3.7.3 新增成就

- 《修不完的功德》：功德值低于-100时触发

### 3.8 数据统计页面

#### 3.8.1 数据来源

数据统计页面的数据来源统一为`daily_aggregates`（已结算数据）+`timer_sessions`（今日未结算数据）的UNION视图，不再直接从`time_records`读取。

- 从SQLite`daily_aggregates`表读取已结算数据（study_seconds, slack_seconds, sleep_hours）
- 今日未结算数据从`timer_sessions`实时聚合补充

#### 3.8.2 时间切换

- 今日 / 本周 / 本月（默认今日）

#### 3.8.3 今日模式

- 饼图展示学习、摸鱼、睡眠占比
- 中央显示总小时数
- 下方数值列表展示具体时长

#### 3.8.4 本周/本月模式

- 分组条形图展示每天学习、摸鱼、睡眠柱子
- 支持横向滚动查看

#### 3.8.5 累计统计

- 总学习时长
- 总摸鱼时长
- 平均睡眠时长
- 有数据总天数
- 累计总时长字段单独展示作为彩蛋（展示原始未截断的`timer_sessions`时长总和）

#### 3.8.6 每日明细列表

- 按日期倒序展示
- 显示每日学习/摸鱼/睡眠小时数
- 热点数据（7天内）：允许自由修改，**修改后自动触发增量重算，从修改日起向后逐日重新计算HP、SAN、磨损值、功德值，最多重算至当日，耗时需 < 500ms（中端设备）**
- 冷数据（7~30天）：允许修改，弹窗提示风险
- 冻结数据（30天以上）：禁止修改，置灰显示「太久远啦，麻糬记不清了~」

#### 3.8.7 无数据状态

- 显示麻糬插画
- 提示文案

#### 3.8.8 彩蛋

- 累计统计底部随机显示幽默结论

#### 3.8.9 视觉风格

- 手账风格（奶油白背景，圆角卡片）

### 3.9 自定义语录管理页面

#### 3.9.1 页面路由

- /(app)/quotes

#### 3.9.2 页面标题

- 「我的激励语录」

#### 3.9.3 语录列表

- 显示所有激活语录
- 每条语录带编辑✏️按钮
- 每条语录带删除🗑️按钮

#### 3.9.4 添加按钮

- 底部「+ 添加新语录」按钮

#### 3.9.5 开关设置

- 「仅使用我的语录」开关
- 开启后不显示内置默认语录

#### 3.9.6 添加/编辑语录

- 弹出输入框
- 限制50字以内
- 保存到本地SQLite

#### 3.9.7 内置默认语录（10条）

1. 「再写两行，我就能光明正大地摸鱼了——战术性努力。」
2. 「今天只要打开文档，就算我对这个DDL有过诚意。」
3. 「先做五分钟，不行就逃——但万一我停不下来呢？」
4. 「这个DDL很难，但我的临时抱佛脚技能可是 Lv.99。」
5. 「摸鱼够了，现在让'限时版高效的我'上线5分钟。」
6. 「写完这一part，奖励自己刷一个短视频——就一个。」
7. 「我不一定会做完，但我一定会开始（大概）。」
8. 「能爬起来面对今天，已经很对得起昨晚熬夜的自己了。」
9. 「不需要完美，只需要'算了先交一版'。」
10. 「管他结果如何，做完就是英雄。」

### 3.10 日切点设置页面

#### 3.10.1 页面标题

- 「日切点设置」

#### 3.10.2 设置说明

- 显示说明文案：「天亮之前都算昨天，天亮了才算今天~」
- 增加风险提示：「调整日切点仅影响未来数据，历史数据不会重新结算。」

#### 3.10.3 时间选择

- 默认凌晨4:00
- 允许0:00~6:00之间调整
- 使用时间选择器组件

#### 3.10.4 保存按钮

- 保存用户选择的日切点时间

---

## 4. 业务规则与逻辑

### 4.1 血条生成规则

- 系统根据任务截止时间自动生成倒计时
- **血条百分比公式**：`血条% = min(100, max(0, (截止时间 - 当前时间) / (截止时间 - created_at) × 100))`
    - 分母 = 截止时间 - created_at（任务创建时间戳）
    - 若 created_at 缺失（旧数据迁移），默认分母为 72 小时
    - 若当前时间早于 created_at，血条显示 100%
- 系统根据剩余时间判定危险等级
- 血条呈现果汁状液体晃动效果

### 4.2 精神状态计算规则（HP/SAN双轨制）

以精算表§4.21为唯一公式基准，统一正文公式，补充变量定义。

#### 4.2.1 生命值（今日）计算

统一为精算表版本，补充lateHours和wearPenalty定义。

- **基础公式**：`生命值（今日）= 80 - lateHours×5 - Σ(未完成ddl × 8 × priority_weight) - slackHours×2 + studyHours×3 - wearPenalty`
- **lateHours**：当日所有未完成任务中，已过期的小时数总和（`max(0, now - deadline)`按小时取整，仅统计未完成的任务）。
- **slackHours**：当日累计摸鱼小时数（`total_slack_seconds / 3600`）。
- **studyHours**：当日累计学习小时数（`total_study_seconds / 3600`）。
- **wearPenalty**：`min(40, wear × 0.5)`，其中`wear`为当前累计磨损值。
- **优先级权重系数**：低×1.0、中×1.5、高×2.0
- 生命值范围：0-100
- HP<10%时吉祥物呈现濒死状态

#### 4.2.2 磨损值（累计）计算

- **惰性结算**：每次 App 冷启动或从后台切回前台时，检查 last_settle_date，若 last_settle_date < today（按日切点），则逐天补算缺失天数据（详见 4.22 跨日惰性结算规则）。
- 公式：`磨损值 = 磨损值 + max(0, 30 - 当日生命值)`
- 衰减系数：每休息一天（HP>80）磨损值减10%（`wear *= 0.9`）
- 磨损值范围：0-100

#### 4.2.3 理智值计算

**完整公式**：

```
理智值 = 80
        - (连续熬夜天数 × 8)        // 连续熬夜，每天-8
        - (红温DDL数量 × 12)        // 每个紧急任务（剩余<12h且未完成）-12
        - (摸鱼小时数 × 1.5)        // 摸鱼越久越不理智
        + (学习小时数 × 2)          // 学习稍微回理智
限制：clamp(0, 100)
```

- 连续熬夜天数：每天实际睡眠 < 6 小时则累加，中断一天（睡眠 ≥ 6 小时）重置为 0
- 红温 DDL：剩余时间 < 12 小时且未完成的任务数量
- 摸鱼/学习小时数取当日有效值（手动值优先于计时器值）
- 理智值范围：0-100
- 理智值 < 20% 时「一键摸鱼」按钮闪烁

#### 4.2.4 功德值计算

**完整公式（每日累加）**：

```
功德值 = 前一日功德值
        + (当日按时完成任务数 × 5)         // 按时完成+5
        - (摸鱼>8h的天数 × 20)             // 单日摸鱼超8小时-20
        - (压线完成次数 × 3)               // 剩余<1小时且未过期完成-3
        - (超时完成次数 × 10)              // 过期后补完成-10
        + (连续学习>4h的天数 × 2)          // 专注学习奖励+2
初始值：0，无下限
```

- **按时完成**：标记完成时任务未过期（`completion_type = 'on_time'`）
- **压线完成**：标记完成时剩余时间 < 1 小时且未过期（`completion_type = 'rush'`）
- **超时完成**：任务已过期后用户点击"补完成"（`completion_type = 'overtime'`）
- 功德值负数时吉祥物头上出现「功德-∞」漂浮特效
- 功德值低于 -100 时触发《修不完的功德》成就

#### 4.2.5 睡眠债计算

补充睡眠债公式。

- **公式**：`睡眠债 = max(0, 8 - sleep_hours)`
- 睡眠债范围：0-24h上限

### 4.3 吉祥物状态变化规则

- 根据生命值、理智值、DDL危险等级动态切换吉祥物表情和动作
- 生命值>70%且理智值>70%：精神好状态
- 生命值50%-70%或理智值50%-70%：有点累状态
- 生命值<50%或理智值<50%或存在红温DDL：红温状态
- 生命值<10%：濒死状态
- 完成任务时：瘫软状态
- 功德值负数时：头上出现「功德-∞」漂浮特效

### 4.4 每日人格检测规则

补充完整决策矩阵与`generatePersonality(date)`实现逻辑，消除最大算法留白。

**输入数据**（取自`daily_aggregates[date]`）：
-`final_hp`：生命值
-`final_san`：理智值
-`final_karma`：功德值
-`streak_sleepless_days`：连续熬夜天数
-`total_slack_seconds`：摸鱼时长（秒）
-`total_study_seconds`：学习时长（秒）
-`unfinished_task_weighted_sum`：未完成任务加权总和
-`red_ddl_count`：红温DDL数量

**决策矩阵（优先级降序，命中即返回）**：

| 优先级 | 条件表达式 | 人格称号 | 生成原因模板 | 系统建议 |
|---|---|---|---|---|
| 1 |`final_hp < 10 AND final_san < 20` | 濒危脆皮大学生 | 生命值<10%且理智值<20%，身体和精神双双崩盘 | 建议直接冬眠，明天再努力 |
| 2 |`final_hp < 10` | 极限求生者 | 生命值<10%，在死亡边缘反复横跳 | 先活下去，其他再说 |
| 3 |`streak_sleepless_days >= 3 AND final_san < 30` | 阴间作息生物 | 连续熬夜{streak_sleepless_days}天，SAN值跌破30 | 太阳见过你吗？ |
| 4 |`red_ddl_count >= 3 AND final_san < 40` | 极限施法大师 | 同时面对{red_ddl_count}个红温DDL，SAN值<40 | 你是时间管理鬼才，可惜管的是倒计时 |
| 5 |`total_slack_seconds > 4*3600 AND total_study_seconds < 1*3600` | 战略性摆烂专家 | 摸鱼{slack_h}h但学习不足1h，摆得很彻底 | 摸鱼这么努力，学习怎么不跟进？ |
| 6 |`final_karma < -50` | 功德负数人 | 功德值{final_karma}，麻糬头上的功德-∞在闪烁 | 多完成任务积德吧 |
| 7 |`final_hp > 80 AND final_san > 80 AND total_study_seconds >= 2*3600` | 高效自律卷王 | HP/SAN双高且学习时长>=2h，状态极佳 | 保持住，你已经是大学生天花板了 |
| 8 |`total_study_seconds >= 4*3600` | 图书馆钉子户 | 学习时长>=4h，今日专注度拉满 | 注意休息，别学傻了 |
| 9 |`total_slack_seconds > 2*3600 AND total_study_seconds >= 2*3600` | 劳逸结合表演艺术家 | 学习和摸鱼都超过2h，平衡大师 | 你是懂生活的 |
| 10 |`red_ddl_count >= 1` | 火烧屁股赶Due人 | 有{red_ddl_count}个DDL正在红温 | 关掉手机，现在开始还来得及 |
| 默认 | 以上均不满足 | 普通大学生 | 今日状态平稳，无极端特征 | 平平淡淡才是真 |

**伪代码**：

```
FUNCTION generatePersonality(date):
  row = daily_aggregates[date]
  slack_h = row.total_slack_seconds / 3600
  study_h = row.total_study_seconds / 3600

  // 按优先级顺序匹配
  IF row.final_hp < 10 AND row.final_san < 20:
    RETURN {
      title: "濒危脆皮大学生",
      reason: f"生命值{row.final_hp}%且理智值{row.final_san}%，身体和精神双双崩盘",
      advice: "建议直接冬眠，明天再努力"
    }
  ELSE IF row.final_hp < 10:
    RETURN { title: "极限求生者", ... }
  ELSE IF row.streak_sleepless_days >= 3 AND row.final_san < 30:
    RETURN { title: "阴间作息生物", ... }
  // ... 依次匹配优先级4-10 ...
  ELSE:
    RETURN { title: "普通大学生", reason: "今日状态平稳", advice: "平平淡淡才是真" }
```

**输出写入**：生成结果写入`daily_aggregates.personality_title` /`personality_desc`，作为当日卡片和历史回顾的展示数据。

### 4.5 成就系统规则

- 连续3天熬夜 → 解锁《阴间作息》成就
- 所有任务压线完成 → 解锁《极限施法》成就
- 一天摸鱼>8小时 → 解锁《工位流浪汉》成就
- 一周未完成任务 → 解锁《战略性摆烂》成就
- 功德值低于-100 → 解锁《修不完的功德》成就
- 解锁时全屏弹出贴纸提示

**成就解锁不可逆原则（Anti-Cheat §4）**

- 成就一旦解锁，永久保留，**绝不因历史数据修改或增量重算而回滚**。
- 实现机制：`achievements`表包含`unlocked_at`时间戳字段。触发增量重算时，系统会重新检查成就条件，但**仅在尚未解锁的情况下才能触发解锁**；已解锁成就的状态字段不受重算影响。
- 原则：用户的荣誉感优先于数据一致性，接受"成就早于真实数据"的情况。

### 4.6 宿舍精神状态语录规则

- 在首页、加载页、卡片底部、待机时随机出现
- 语录库示例：你室友已经开始写第二遍了。 / 隔壁床还在刷短视频。 / 现在打开PPT，你还有机会。 / 别看了，DDL不会自己消失。

### 4.7 UI情绪演出规则

- DDL安全/状态良好：奶油白背景，吉祥物睡觉/吃零食，元素轻微浮动
- DDL临近/轻度紧张：血条变成果汁状液体晃动，倒计时数字霓虹闪烁，吉祥物流汗、瞳孔地震，背景开始渐变淡粉
- 红温/濒危：背景从奶油白渐变为淡粉色，文字轻微歪斜，局部出现贴纸错位，吉祥物全身橙红、头顶冒蒸汽
- 极限压线完成：全屏炸出彩色纸花+表情包烟花，任务卡片裂开后出现完成涂鸦

### 4.8 分享卡片生成规则

- 系统自动生成《DDLife 生存日报》卡片
- 卡片内容：生命值（今日）、磨损值（累计）、理智值、今日DDL数量、连续熬夜天数、今日人格、系统评价、#今日发疯浓度
- 卡片样式：拍立得/手机相册质感，有胶带、贴纸痕迹，手写体文字，荧光笔高亮数据
- 卡片具有轻微动态效果（数字跳动、血条流动）
- 支持一键保存图片到相册
- 支持分享到社交平台

### 4.9 音效播放规则

- 点击：气泡声、拍纸声、可爱的pop
- 红温：心跳加速声+远处下课铃（不刺耳）
- 完成任务：短促的欢呼合唱团Yeah！
- 背景音乐（可选）：Lo-fi hip hop/轻电子

### 4.10 数据存储规则

- 使用本地SQLite存储任务数据
- 使用本地SQLite存储状态数据
- 使用本地SQLite存储成就数据
- 使用本地SQLite存储时间记录数据（`time_records`表保留用于手动录入）
- 使用本地SQLite存储自定义语录数据（quotes表）
- 使用本地SQLite存储日切点设置
- 使用本地SQLite存储操作日志（最近30天）
- **日志清理策略**：App每次冷启动时，异步执行过期日志清理：`DELETE FROM operation_log WHERE timestamp < strftime('%s', 'now', '-30 days')`。为避免频繁清理，设置 last_cleanup_date 配置项，每周只清理一次，清理后无需立即 VACUUM（SQLite 自动复用空间）。

**反作弊现实定位声明**：

> 纯本地SQLite架构下，Anti-Cheat机制依赖App代码完整性，无法防御Root/越狱后的数据库直接篡改。核心反作弊针对误操作和轻度滥用，而非专业攻击者。未来云同步版本可引入服务端校验。

**SQLite性能配置**：

为支持高频写入（跨天拆分、操作日志追加、惰性结算批量写入）并避免UI卡顿，数据库初始化时必须执行以下配置：

```sql
-- 启用WAL模式，避免DELETE journaling的频繁文件锁和fsync阻塞
PRAGMA journal_mode = WAL;

-- 降低同步级别至NORMAL，在崩溃安全与写入性能间取得平衡
PRAGMA synchronous = NORMAL;

-- 增大缓存页数（假设4KB页，2000页≈8MB），减少磁盘IO
PRAGMA cache_size = -2000;

-- 启用外键约束（如后续版本引入外键关系）
PRAGMA foreign_keys = ON;
```

**维护策略**：
- App冷启动时异步执行`PRAGMA optimize`，让SQLite自动分析索引并优化查询计划
- 每周异步执行一次`VACUUM`（仅在观察到显著空间膨胀时，WAL模式下空间自动复用，VACUUM频率可降低）
- 操作日志和timer_sessions归档后，手动执行`PRAGMA wal_checkpoint(TRUNCATE)` 控制WAL文件大小

### 4.11 自定义语录随机抽取规则

- 从所有激活语录（用户自定义 + 内置未被删除/禁用）中随机抽取
- 若「仅使用我的语录」开关开启，仅从用户自定义语录中抽取
- 若所有激活语录为空，降级显示：「麻糬暂时词穷了，快去添加新语录吧~」
- 首页吉祥物点击、待机时随机语录均从合并库中抽取

### 4.11b 本地推送通知规则

纯本地架构下，惰性结算在用户下次打开App时才触发，推送通知与数值扣减之间存在时间差——这是**可接受的设计特性**，而非缺陷。

**接受机制，优化文案**：将这一时间差转化为"沉浸式命运预告"叙事体验。

|推送场景|文案示例|
|---|---|
|任务进入红温（<12h）|`⚠️ [任务名] 已进入最后倒计时！当你再次打开App时，将知晓麻糬的最终命运……`|
|任务进入濒死（<3h）|`🚨 [任务名] 只剩3小时！麻糬已开始颤抖，快回来拯救Ta！`|
|任务已过期|`💀 [任务名] 截止时间已过。麻糬在颤抖地等你回来宣判……`|

**打开App时的体验强化**：惰性结算后若检测到任务过期，吉祥物入场动画应强化为"回放判决"——吉祥物先捂脸、不敢看，然后表情从惊恐变为大哭，配合数值跳动特效，强化情感代入。

### 4.12 SQLite数据表结构

#### 4.12.1 quotes表

- id：主键
- text：语录文本
- is_active：是否激活
- is_builtin：是否内置语录

#### 4.12.2 timer_sessions表与time_records表

明确Schema 3.0的最终表清单：`time_records`表职责收缩为仅存储手动录入数据，不废弃；新增`timer_sessions`（计时器原始会话）和`daily_aggregates`（日聚合）。

**会话表 (`timer_sessions`)** — 记录原始粒度数据：

```sql
CREATE TABLE timer_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_type TEXT NOT NULL,       -- 'study' 或 'slack'
    start_timestamp INTEGER NOT NULL, -- Unix时间戳（秒）
    end_timestamp INTEGER,            -- Unix时间戳（秒），NULL表示进行中
    duration_seconds INTEGER DEFAULT 0, -- 有效计时时长（秒），由App写入
    is_valid INTEGER DEFAULT 1,       -- 0=异常/作弊会话（超4h或12h锁定触发）
    assigned_date TEXT,               -- 预计算归属日期（YYYY-MM-DD），含跨天拆分
    split_from_session_id INTEGER,    -- 若为跨天拆分生成，记录来源会话ID
    settled_date TEXT                 -- 已结算日期，NULL表示未结算，用于增量聚合
);

-- 复合索引（性能优化）
CREATE INDEX idx_timer_sessions_start_valid ON timer_sessions(start_timestamp, is_valid, session_type);
CREATE INDEX idx_timer_sessions_settled ON timer_sessions(settled_date, assigned_date);
```

**手动录入表 (`time_records`)** — 保留用于手动录入：

```sql
CREATE TABLE time_records (
    date TEXT PRIMARY KEY,            -- YYYY-MM-DD
    manual_study_minutes INTEGER DEFAULT 0,
    manual_slack_minutes INTEGER DEFAULT 0,
    sleep_hours REAL DEFAULT 0
);
```

**聚合表 (`daily_aggregates`)** — 存储按日聚合结果：

补全缺失字段，统一为唯一日聚合表。

```sql
CREATE TABLE daily_aggregates (
    date TEXT PRIMARY KEY,                 -- YYYY-MM-DD
    total_study_seconds INTEGER DEFAULT 0,
    total_slack_seconds INTEGER DEFAULT 0,
    total_sleep_hours REAL DEFAULT 0,
    final_hp INTEGER DEFAULT 80,           -- 结算后HP，默认80避免NULL传播
    final_san INTEGER DEFAULT 80,          -- 结算后SAN，默认80避免NULL传播
    final_karma INTEGER DEFAULT 0,         -- 结算后功德值，默认0避免NULL传播
    wear_snapshot REAL DEFAULT 0,          -- 当日磨损值快照
    karma_snapshot INTEGER DEFAULT 0,      -- 当日功德值快照
    sleep_debt REAL DEFAULT 0,             -- 睡眠债
    streak_sleepless_days INTEGER DEFAULT 0, -- 连续熬夜天数
    red_ddl_count INTEGER DEFAULT 0,       -- 红温DDL数量
    completed_on_time INTEGER DEFAULT 0,   -- 按时完成次数
    completed_rush INTEGER DEFAULT 0,      -- 压线完成次数
    completed_overtime INTEGER DEFAULT 0,  -- 超时完成次数
    slack_over_8h_flag INTEGER DEFAULT 0,  -- 单日摸鱼超8h标记
    study_over_4h_flag INTEGER DEFAULT 0,  -- 连续学习>4h标记
    personality_title TEXT DEFAULT '未知人格', -- 当日人格称号，默认避免UI空卡片
    personality_desc TEXT DEFAULT '麻糬正在分析你的精神状态……', -- 当日人格描述，默认避免UI空卡片
    unfinished_task_weighted_sum REAL DEFAULT 0 -- 未完成任务加权总和（HP公式用）
);
```

> **UI文案转译层（§1 补丁）**：前端UI展示的"熬夜时长"等文案，通过对`total_sleep_hours`字段进行转译生成，底层始终以`sleep_hours`（睡眠小时数）作为唯一物理度量单位参与公式计算：
>
>```
> display_text =
>   sleep_hours ≤ 4 → "修仙时长：熬夜肝帝 {8-sleep_hours}h"
>   sleep_hours ≤ 6 → "脆弱时长：浅浅眯了 {sleep_hours}h"
>   else            → "睡眠富豪：无敌休息 {sleep_hours}h"
> ```

#### 4.12.3 achievements表

补充完整Schema。

```sql
CREATE TABLE achievements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    achievement_key TEXT UNIQUE NOT NULL,  -- 'night_owl', 'last_minute', 'office_vagrant', 'strategic_slacker', 'endless_karma'
    unlocked_at INTEGER,                   -- Unix timestamp（秒）, NULL=未解锁
    unlock_context TEXT                    -- JSON: 触发时的上下文数据
);
```

#### 4.12.4 operation_log表

补充完整Schema与完整性校验。

```sql
CREATE TABLE operation_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp INTEGER NOT NULL,            -- Unix timestamp（秒）
    action_type TEXT NOT NULL,             -- 'delete_penalty', 'cross_day_truncated', 'timer_abnormal', etc.
    target_type TEXT,                      -- 'task', 'timer_session', 'daily_aggregates'
    target_id INTEGER,
    details TEXT,                          -- JSON
    user_visible INTEGER DEFAULT 0,        -- 1=用户可见
    row_hash TEXT                          -- HMAC-SHA256行级哈希，用于完整性校验
);

CREATE INDEX idx_oplog_time ON operation_log(timestamp);
CREATE INDEX idx_oplog_action ON operation_log(action_type);
```

**HMAC行级哈希安全边界声明**：

- **覆盖范围**：`row_hash`仅存在于`operation_log`表，用于检测操作日志的无意篡改和文件损坏。核心数据表（`daily_aggregates`、`timer_sessions`、`achievements`、`tasks`）不覆盖HMAC哈希。
- **密钥管理**：HMAC密钥使用Keychain（iOS）/ Keystore（Android）存储，非硬编码于源码。密钥在首次安装时随机生成并持久化到安全存储区。
- **哈希计算时机**：操作日志写入时**同步计算**`row_hash`（在后台线程的写入队列中同步完成，非独立异步任务），消除"写入与哈希计算"之间的TOCTOU竞态窗口。row_hash字段在INSERT语句中直接携带，避免先写入再补算导致的完整性盲区。
- **启动时补扫**：冷启动时扫描`operation_log`表中`row_hash IS NULL`的记录（通常为异常崩溃导致的写入中断），补充计算并更新，消除历史空洞。
- **哈希失败处理**：启动时校验`operation_log`最近100条记录的`row_hash`，若校验失败，标记该记录为`integrity_failed`，提示用户"检测到日志异常，建议核对近期操作"。
- **安全定位声明**：本地SQLite架构下的HMAC机制目标是"防无意文件损坏和非技术用户的直接编辑"，无法防御Root/越狱后具备文件访问能力的专业攻击者（攻击者可提取密钥后重新计算合法哈希）。此类场景需依赖未来云同步版本的服务端校验。

#### 4.12.5 tasks表

补充核心任务表Schema，消除全文最大架构遗漏。

```sql
CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,                   -- 任务名称
    deadline INTEGER NOT NULL,             -- 截止时间 Unix timestamp（秒）
    priority TEXT NOT NULL,                -- 'low' | 'medium' | 'high'
    status TEXT NOT NULL DEFAULT 'active', -- 'active' | 'completed' | 'deleted'
    completion_type TEXT,                  -- NULL | 'on_time' | 'rush' | 'overtime'
    is_expired INTEGER DEFAULT 0,          -- 0=未过期, 1=已过期（计算列，由deadline推导）
    created_at INTEGER NOT NULL,           -- 创建时间 Unix timestamp（秒）
    completed_at INTEGER,                  -- 完成时间 Unix timestamp（秒），NULL=未完成
    overdue_at INTEGER                     -- 过期时间 Unix timestamp（秒），NULL=未过期
);

-- 核心查询索引
CREATE INDEX idx_tasks_status_deadline ON tasks(status, deadline);
CREATE INDEX idx_tasks_priority ON tasks(priority);
CREATE INDEX idx_tasks_created_at ON tasks(created_at);
```

> **字段说明**：`is_expired`为推导字段，App层根据`deadline < now AND status != 'completed'`计算，不单独维护状态机，避免过期判定与完成判定的竞态条件。

#### 4.12.6 global_config表

补充全局配置表Schema，统一惰性结算、反作弊、日切点等基础设施配置项存储。

```sql
CREATE TABLE global_config (
    key TEXT PRIMARY KEY,                  -- 配置项键名
    value TEXT NOT NULL,                   -- 配置项值（统一字符串存储，读取时按value_type转换）
    value_type TEXT NOT NULL,              -- 'int' | 'real' | 'text' | 'bool'
    updated_at INTEGER NOT NULL            -- 最后更新时间 Unix timestamp（秒）
);

-- 核心配置项清单（开发初始化时插入）
-- 'last_settled_date'        | text | YYYY-MM-DD
-- 'last_settled_date_signature' | text | HMAC-SHA256(last_settled_date + wear_value + salt)，防篡改校验
-- 'wear_value'               | real | 当前全局磨损值
-- 'karma_value'              | int  | 当前全局功德值
-- 'day_cutoff_hour'          | int  | 日切点小时（默认4）
-- 'last_cleanup_date'        | text | YYYY-MM-DD
-- 'first_ntp_sync_at'        | int  | 首次成功NTP同步的Unix时间戳（存储于Keychain/Keystore的备份）
-- 'last_known_good_time'     | int  | 上次验证通过的单调时钟值
-- 'schema_version'           | int  | 数据库Schema版本号（Migration用）
-- 'formula_version'          | int  | 当前公式版本号（默认1，公式变更时触发全量重算）
```

> **安全说明**：
> -`first_ntp_sync_at`同时在Keychain/Keystore中存储备份，防止SQLite文件被直接篡改后NTP锚点丢失。
> -`last_settled_date_signature`：对`last_settled_date` + 当前`wear_value`进行HMAC-SHA256签名，密钥存储于Keychain/Keystore。启动时校验签名，若`last_settled_date`被回溯篡改（如从2024-06-01改为2024-01-01），签名校验失败，触发`settlement_rollback_suspicious`标记，进入安全模式（仅允许查看，禁止修改直到用户确认）。
> - 单调性校验：`last_settled_date`必须单调递增，若检测到新值 < 旧值，立即触发篡改警报。

### 4.13 日切点结算规则

- 默认日切点为凌晨4:00
- 用户可在设置页调整日切点（0:00~6:00）
- 计时器记录开始和结束时间戳
- 结算时按实际区间归属对应日期
- 跨天数据按时间戳比例自动拆分归属

**跨天拆分算法**：

```
FUNCTION splitCrossDaySession(start_ts, end_ts, cutoff_hour):
  MAX_SPLIT_SEGMENTS = 2    // 硬上限：最多拆分为2段（昨日+今日）
  elapsed = end_ts - start_ts

  // 前置校验：单个会话时长不得超过4小时硬上限
  IF elapsed > 4 * 3600:
    THROW "elapsed exceeds 4h hard limit, session invalid"

  segments = []
  current = start_ts
  segment_count = 0

  WHILE current < end_ts AND segment_count < MAX_SPLIT_SEGMENTS:
    day_start = floorToDay(current) + cutoff_hour * 3600
    day_end = day_start + 86400
    segment_end = min(end_ts, day_end)
    segments.append({
      date: formatYYYYMMDD(day_start),
      seconds: segment_end - current
    })
    current = segment_end
    segment_count = segment_count + 1

  // 安全兜底：若因异常触发硬上限，将剩余时间归入最后一段并记录异常
  IF current < end_ts:
    segments.last.seconds = segments.last.seconds + (end_ts - current)
    LOG_WARNING("cross_day_split_hit_max_segments", {start_ts, end_ts, cutoff_hour})

  RETURN segments
```

- 拆分后的子会话写入`timer_sessions`时生成多行记录，并通过`split_from_session_id`追溯来源。
- 各子会话`duration_seconds`之和严格等于原始`elapsed`（硬上限兜底情况下略有偏差，记录操作日志`cross_day_truncated`标记）。

### 4.14 输入字段极值限制（三层防线）

- 前端：手机端输入面板限制0~24，超过提示「一天最多24小时哦~」
- 后端：>24记录为24，<0记录为0
- UI：进度条对0~100做clamp处理

**跨天拆分24h截断规则（Data Integrity §8）**：

- 在进行跨天拆分（§4.13日切点结算）时，写入目标日期前，先检查`daily_aggregates`中该日期的当前累积时长。
- 若累加后超过24小时（`total_study_seconds + total_slack_seconds > 86400`），则**按后入先出（LIFO）截断**超出部分，仅累加至当日上限为止。
- 丢弃的部分在操作日志中标记为`cross_day_truncated`。
- 最终写入`daily_aggregates`表时，使用`MIN(拟写入值, 86400)` 进行强制兜底。
- 同一日期多次结算使用UPSERT（`INSERT ... ON CONFLICT(date) DO UPDATE`）保证幂等性。

### 4.15 手动记录与计时器混用策略

明确字段归属表。

- 计时器记录经拆分后累加到`daily_aggregates`的`total_study_seconds`/`total_slack_seconds`
- 手动录入存入`time_records`表的`manual_study_minutes`/`manual_slack_minutes`/`sleep_hours`字段
- 显示逻辑：有手动值时优先显示手动值（手动值覆盖计时器值）
- 手动修改时显示确认弹窗：「手动输入将覆盖今日计时器记录，确定吗？」
- 本地日志保留最近30天操作记录
- HP公式引入优先级权重系数：低×1.0、中×1.5、高×2.0
- 未完成DDL数量 × 8 × 优先级权重系数
- DDL列表按优先级倒序排列
- 高优先级任务血条有金色镶边效果
- 危险等级：同剩余时间的任务，优先级越高越倾向提前一级标红

### 4.16 数据归档策略

补充数据生命周期管理与归档规则，消除编号跳跃，并为长期运行提供数据量控制策略。

**数据分层**：
- **热点数据（7天内）**：允许自由修改，触发增量重新计算
- **冷数据（7~30天）**：允许修改，弹窗提示风险
- **冻结数据（30天以上）**：禁止修改，置灰显示「太久远啦，麻糬记不清了~」

**自动清理策略**：
- 操作日志：保留最近30天，`DELETE FROM operation_log WHERE timestamp < strftime('%s', 'now', '-30 days')`，每周清理一次
- timer_sessions归档：已结算超过30天的会话迁移至`timer_sessions_archive`表或删除（控制主表行数）
- 数据库维护：每周异步执行一次`VACUUM`（仅在WAL模式下空间回收效果有限时执行）

**惰性结算上限**：
- 最多补算30天，超出部分显示轻量Loading提示
- 首次安装不补算历史（`last_settled_date`初始化为`today-1`）

**归档表Schema**（可选，用于审计和调试）：
```sql
CREATE TABLE timer_sessions_archive (
    id INTEGER PRIMARY KEY,
    session_type TEXT,
    start_timestamp INTEGER,
    end_timestamp INTEGER,
    duration_seconds INTEGER,
    assigned_date TEXT,
    archived_at INTEGER DEFAULT (strftime('%s', 'now'))
);
```

### 4.17 时间篡改防御规则

补充NTP具体方案、离线降级策略与单调时钟基准，修复逻辑悖论。

**三层防御架构**：

- **第一层：系统时间倒流检测**
  - App启动时比较当前系统时间与上次持久化的`last_known_wall_time`
  - 若新时间 < 旧时间，弹窗警告：「检测到时光倒流，麻糬很困惑~」
  - 攻击者可篡改SQLite中的`last_known_wall_time`，因此该层仅作辅助检测

- **第二层：NTP时间同步与离线降级**
  - NTP服务器：iOS使用`time.apple.com`，Android使用`pool.ntp.org`
  - Fallback：支持HTTPS时间API（如`https://worldtimeapi.org/api/ip`）
  - **锚点机制**：首次成功NTP同步后，将Unix时间戳写入`global_config.first_ntp_sync_at`，同时在Keychain/Keystore中备份。后续离线降级不再依赖"安装时间"，而是依赖"最近一次成功NTP同步的时间"
  - **单调时钟基准**：引入系统单调时钟（iOS`mach_absolute_time` / Android`CLOCK_MONOTONIC`）作为不可篡改的相对时间基准。每次启动记录单调时钟增量，若系统时间跳跃但单调时钟正常，可检测出时间篡改
  - **离线降级策略**：
    - 首次成功NTP同步前：允许离线使用，但标记为「未校验模式」（UI角标提示）
    - 距离最近一次成功NTP同步 ≤72小时：允许完整操作
    - 距离最近一次成功NTP同步 >72小时：进入「受限模式」（允许查看数据，禁止DDL创建/编辑/完成/删除、计时器启动/停止、手动时间输入、成就解锁等关键操作）
    - 完全无网络且单调时钟正常：最长允许离线168小时（7天），超过后强制进入受限模式
  - **关键操作白名单**：以下操作必须在NTP校验通过（偏差≤60秒）或处于非受限模式下才允许执行：DDL创建/编辑/完成/删除、计时器启动/停止、手动时间输入、成就解锁检查
  - **偏差容忍度**：
    - 偏差1~60秒：记录警告日志，不阻断操作
    - 偏差>60秒：禁止关键操作，提示"系统时间与网络时间偏差过大"

- **第三层：行为异常检测与数据合理性校验（不阻断操作）**
  - 单日学习时长>16小时、单日摸鱼时长>16小时：标记为`data_anomaly`，提示用户核对
  - 连续7天完全相同的时间记录模式：标记为`pattern_suspicious`
  -`last_settled_date`被回溯超过7天：触发`settlement_rollback_suspicious`标记

**安全边界声明**：时间篡改防御的目标是"防误操作和非技术用户的轻度滥用"。对于Root/越狱后具备SQLite文件访问能力的专业攻击者，本地时间防御无法完全阻止篡改——此类场景需依赖未来云同步版本的服务端校验。

### 4.18 历史数据修改窗口期规则

- 热点数据（7天内）：允许自由修改，触发增量重新计算
- 冷数据（7~30天）：允许修改，弹窗提示风险
- 冻结数据（30天以上）：禁止修改，置灰显示「太久远啦，麻糬记不清了~」
- 修改后从当天起向后最多7天重新计算

### 4.19 通知权限降级体验规则（分级）

延迟申请时机，增加永久关闭选项，文案合规化。

- Level 0：完整体验
- Level 1：首页常驻粉红提示条「开启通知可在DDL截止前1小时收到提醒 → 去开启权限」；增加「不再提示」按钮，用户可永久关闭
- DDL列表页顶部同款提示条
- 设置页「DDL提醒」菜单项显示「⚠️ 已关闭」标签
- Level 2：连续3次拒绝后不再主动弹窗，保持常驻提示（用户可手动关闭提示条）
- 首次通知权限申请移至用户创建第一个DDL之后

### 4.20 全局状态机与极值定义

删除"待开始→进行中"自动触发，明确双字段设计，补充状态转换图。

- HP: 0-100，<10%吉祥物「濒死」状态
- SAN: 0-100，<20%「一键摸鱼」按钮闪烁
- 功德值：无下限，负数显示特效
- 睡眠债：0-24h上限

**任务状态机（双字段设计）**：

|字段|类型|说明|
|---|---|---|
 |status|ENUM('active', 'completed', 'deleted')|任务主状态|
|completion_type|ENUM(NULL, 'on_time', 'rush', 'overtime')|完成子类型，仅status='completed'时有效|
|is_expired|BOOLEAN|由截止时间自动推导：`deadline < now && status != 'completed'`|

**状态转换图**：

```
[任意状态] --用户删除--> deleted（触发惩罚性删除检查）

active --用户标记完成--> completed + completion_type
  - 若未过期且剩余>1h: on_time
  - 若未过期且剩余<=1h: rush
  - 若已过期: overtime

active --deadline < now && 未操作--> is_expired = 1（自动推导，非持久化状态转换）

completed --不允许直接转换--> 其他状态（成就不可逆）
```

- 删除"待开始→进行中（<7天自动）"的自动触发逻辑。任务创建时由用户选择初始状态（默认pending），或根据用户操作直接置为active。"进行中"仅为UI展示概念，不在数据库中持久化独立状态。

---

### 4.21 数值精算表（Mathematical Formulas Sheet）

所有计算公式汇总，以下为开发与测试核对基准：

|数值|公式|取值范围|
|---|---|---|
|生命值（今日）|`80 - lateHours×5 - Σ(未完成ddl × 8 × priority_weight) - slackHours×2 + studyHours×3 - wearPenalty`|0-100|
|磨损值|`wear = wear + max(0, 30 - today_hp)`；若`today_hp > 80`则`wear *= 0.9`|0-100|
|磨损惩罚|`wearPenalty = min(40, wear × 0.5)`|0-40|
|理智值|`80 - (sleepless_days×8) - (red_ddl_count×12) - (slack_hours×1.5) + (study_hours×2)`|0-100|
|功德值|`prev + (on_time_completed×5) - (slack_over_8h_flag×20) - (rush_completed×3) - (overtime_completed×10) + (study_over_4h_flag×2)`|无下限|
|睡眠债|`max(0, 8 - sleep_hours)`|0-24|
|血条%|`min(100, max(0, (due - now) / (due - created_at) × 100))`；分母缺失默认72h|0-100|
|今日发疯浓度|`min(100, ((100-hp) + (100-san)) / 2)`|0-100|
|熬夜小时|`max(0, 6 - sleep_hours)`（6小时以下才算熬夜）|0-6|

**优先级权重系数**：

|优先级|权重|
|---|---|
|低|1.0|
|中|1.5|
|高|2.0|

**衰减系数**：

- 若`today_hp > 80`：`decay = 0.9`（wear × 0.9）
- 否则：`decay = 1.0`（wear 不衰减）

---

### 4.22 跨日惰性结算规则

纯本地 App 无法依赖后台定时进程，改用惰性计算（Lazy Evaluation）：

**触发时机**：App 每次冷启动或从后台切回前台时执行。

**执行方式**：

改为异步线程执行，分层结算策略，批量GROUP BY聚合。

- **异步化**：将结算逻辑移至独立线程/Isolate（Flutter）或后台队列（React Native），主线程仅展示Loading/骨架屏。
- **分层结算**：
  - ≤7天缺失：同步快速结算，保证数据即时性。
  - >7天缺失：异步后台结算+进度提示。
- **批量聚合**：使用单次`GROUP BY assigned_date`查询聚合所有待结算日期的`timer_sessions`数据，将30次查询合并为1次。
- **任务预聚合**：惰性结算时同步计算每日任务中间值，一次性写入`daily_aggregates`，避免后续N+1查询：
  -`unfinished_task_weighted_sum` = Σ(未完成DDL × 8 × priority_weight)
  -`red_ddl_count` = 剩余时间<12h且未完成的任务数量
  -`completed_on_time` /`completed_rush` /`completed_overtime` = 当日各类完成次数
  - 上述预聚合字段在惰性结算时一次性计算并写入，后续HP/SAN实时计算直接读取`daily_aggregates`，无需逐日扫描`tasks`表
- **幂等保护**：结算前检查`last_settled_date`，已结算日期直接跳过，避免重复计算。

**完整状态机伪代码**：

```
FUNCTION settleCrossDays(lastSettledDate):
  today = getCurrentDateByCutoff()
  IF lastSettledDate >= today: RETURN  // 无需结算

  // 异步执行（主线程展示Loading）
  RUN_IN_BACKGROUND:
    // 单次批量聚合查询（仅未结算会话）
    sessions = SELECT assigned_date, session_type, SUM(duration_seconds)
               FROM timer_sessions
               WHERE settled_date IS NULL AND is_valid = 1
               GROUP BY assigned_date, session_type

    // 签名校验与单调性校验
    stored_sig = global_config['last_settled_date_signature']
    computed_sig = HMAC_SHA256(lastSettledDate + global_config['wear_value'] + KEYCHAIN_SALT)
    IF stored_sig != computed_sig OR lastSettledDate 被检测到回溯:
      TRIGGER_SECURITY_ALERT('settlement_rollback_suspicious')
      ENTER_SAFE_MODE()  // 仅允许查看，禁止修改直到用户确认
      RETURN

    FOR date IN (lastSettledDate+1 ... today-1):   // 逐日补算（不含今日）
      1. 从批量聚合结果提取 date 的 study_seconds, slack_seconds
         // 截断规则：累加不超过 86400 秒（见§4.14），LIFO截断
      2. 读取 time_records[date] 的 sleep_hours（手动录入值）
      3. 计算每日任务预聚合值：
         unfinished_task_weighted_sum = SELECT SUM(8 * priority_weight) FROM tasks WHERE status='active' AND deadline > date_start AND deadline <= date_end
         red_ddl_count = SELECT COUNT(*) FROM tasks WHERE status='active' AND deadline - now < 12*3600
         completed_on_time = SELECT COUNT(*) FROM tasks WHERE status='completed' AND completion_type='on_time' AND DATE(completed_at)=date
         completed_rush = SELECT COUNT(*) FROM tasks WHERE status='completed' AND completion_type='rush' AND DATE(completed_at)=date
         completed_overtime = SELECT COUNT(*) FROM tasks WHERE status='completed' AND completion_type='overtime' AND DATE(completed_at)=date
      4. 基于公式计算 date 的 HP、SAN、磨损值、功德值
         // 继承 date-1 日的 wear_snapshot 和 karma_snapshot
      5. 调用 generatePersonality(date) 函数，
         基于当天 HP/SAN/功德值/任务数据生成"每日人格称号"和描述，
         将结果存入 daily_aggregates.personality_title / personality_desc
      6. 更新 daily_aggregates 的最终值（final_hp, final_san, final_karma, wear_snapshot, karma_snapshot, unfinished_task_weighted_sum, red_ddl_count, completed_on_time, completed_rush, completed_overtime 等）
      7. 更新全局磨损值状态（global_config wear_value）
      8. 标记该日期涉及的 timer_sessions 的 settled_date = date
      9. 检查并解锁成就（仅在用户尚未解锁的情况下触发，绝不回滚已解锁成就）

    UPDATE global_config SET value = today-1 WHERE key = 'last_settled_date'
    UPDATE global_config SET value = HMAC_SHA256(today-1 + global_config['wear_value'] + KEYCHAIN_SALT) WHERE key = 'last_settled_date_signature'
    NOTIFY_UI_SETTLEMENT_COMPLETE
```

**边界处理**：

- 最多补算 30 天（避免性能问题），超出部分显示轻量 Loading 提示
- 今日数据在用户记录或查看时实时计算，不等结算
- 若 last_settle_date 不存在（首次安装），设置为 today-1，不补算历史
- 首次启动时在后台预插入今日`daily_aggregates`行零值初始化，避免后续实时计算空指针

---

### 4.23 历史数据增量重算规则

引入快照缓存机制，说明性能保证前提，增加分批异步重算策略。

当用户修改 D 日的时间记录后，触发以下增量重算：

1. 重新计算 D 日的 HP、SAN（基于当天数据，包含磨损惩罚 wearPenalty）
2. 从 D 日开始，继承 D-1 日的`daily_aggregates.wear_snapshot`，逐日应用磨损值公式，更新 D 日及之后每天的磨损值
3. 从 D 日开始，继承 D-1 日的`daily_aggregates.karma_snapshot`，逐日重新计算，更新 D 日及之后每天的功德值
4. 重算范围：D 日到当前日期，最大跨度 7 天（仅热点数据允许修改）
5. 性能要求与降级策略：
   - 修改单日数据后，即时重算仅D日，目标<100ms
   - 后台异步重算D+1日至今日，UI先展示D日更新结果
   - **任务数 ≤ 200**：中端设备（Android骁龙7系 / 天玑800系 / iPhone 12）目标整体<500ms
   - **任务数 > 200**：允许修改但取消硬性SLA承诺。UI显示"计算中"Loading，后台异步重算，弹性目标<1000ms。建议长期用户归档已完成的历史任务（保留最近200个活跃任务），避免任务表无限膨胀
   - **500ms超时保护**：整体重算设置500ms超时，超时后中断当前重算并提示"数据量较大，后台计算中"，避免ANR
   - **超时回滚机制**：采用"临时表+原子替换"策略，避免事务长时间持有写锁导致UI卡顿。具体流程：
```
     FUNCTION incrementalRecalculate(D):
       CREATE TEMP TABLE daily_aggregates_temp AS SELECT * FROM daily_aggregates WHERE date >= D
       FOR date IN (D ... today):
         recalc = computeDailyValues(date)
         UPDATE daily_aggregates_temp SET ... WHERE date = date.date
         IF elapsed > 500ms:
           DROP TABLE daily_aggregates_temp
           SET_FLAG('recalculation_pending', true)
           SHOW_TOAST("数据量较大，后台计算中")
           RETURN  // 不提交任何变更，原数据保持完整
       // 500ms内完成，原子替换
       BEGIN TRANSACTION
         DELETE FROM daily_aggregates WHERE date >= D
         INSERT INTO daily_aggregates SELECT * FROM daily_aggregates_temp
       COMMIT
       DROP TABLE daily_aggregates_temp
       CLEAR_FLAG('recalculation_pending')
     ```
     关键约束：①临时表操作在后台线程执行；②COMMIT必须在主线程空闲时同步完成（确保UI展示的数据与数据库一致）；③`recalculation_pending`标志在下次启动时检测，若存在则优先完成后台重算
   - **复合索引**：`tasks`表必须建立`(status, deadline)`复合索引，加速"未完成且截止时间在范围"的查询

---

## 5. 数据埋点设计

### 5.1 关键事件埋点

#### 5.1.1 任务相关

- task_created：任务创建
- task_completed：任务完成
- task_red_alert_triggered：任务红温触发

#### 5.1.2 计时器相关

- timer_session_start：计时器开始
- timer_session_stop：计时器停止

#### 5.1.3 卡片相关

- card_generated：卡片生成
- card_share_click：点击分享按钮
- card_share_success：分享成功
- card_share_completed：分享完成

#### 5.1.4 成就相关

- achievement_unlocked：成就解锁

#### 5.1.5 交互相关

- mochi_click：吉祥物点击

#### 5.1.6 通知相关

- push_notification_received：通知接收
- push_notification_tapped：通知点击

#### 5.1.7 应用相关

- app_open：应用打开

### 5.2 北极星指标

- 卡片分享率

### 5.3 支撑指标

- 次日留存率
- 任务红温率
- 成就解锁率

---

## 6. 异常与边界情况

|场景|处理方式|
|---|---|
|用户未添加任何DDL|首页显示默认提示文案，吉祥物呈现放松状态|
|所有DDL已完成|首页显示庆祝文案，吉祥物呈现欢呼状态，触发彩色纸花动画|
|用户选择的音效文件格式不支持|提示用户选择mp3/wav格式文件|
|用户未记录摸鱼/学习时间|摸鱼页面显示默认数据为0|
|任务截止时间已过|任务is_expired自动推导为1，卡片变灰，"完成"按钮文案变为"补完成"，点击后弹窗确认（功德值-10），确认后status='completed' AND completion_type='overtime'|
|用户关闭音效|所有音效不播放|
|首次打开App|显示欢迎页面，介绍吉祥物和核心玩法；显示换机数据迁移风险提示；数据库初始化异步化；通知权限请求推迟到进入首页后3-5秒|
|卡片页面当天无数据|显示麻糬插画+提示文案|
|数据统计页面无数据|显示麻糬插画+提示文案|
|自定义语录超过50字|提示用户限制50字以内|
|所有激活语录为空|显示降级文案：「麻糬暂时词穷了，快去添加新语录吧~」|
|用户输入时间超过24小时|前端提示「一天最多24小时哦~」，后端记录为24|
|用户输入时间小于0|后端记录为0|
|检测到系统时间倒流|弹窗警告：「检测到时光倒流，麻糬很困惑~」|
|NTP时间同步偏差>60秒|禁止关键操作（DDL创建/编辑/完成/删除、计时器启动/停止、手动时间输入、成就解锁检查）|
|用户修改30天以上历史数据|禁止修改，置灰显示「太久远啦，麻糬记不清了~」|
|用户修改7~30天历史数据|允许修改，弹窗提示风险|
|通知权限关闭|首页和DDL列表页显示粉红提示条（可关闭），设置页显示「⚠️ 已关闭」标签|
|连续3次拒绝通知权限|不再主动弹窗，保持常驻提示条（用户可手动关闭）|

---

## 7. UI风格与视觉规范

### 7.1 整体风格

- Y2K千禧风+多巴胺美学+日系手账
- 活泼明亮+轻抽象+可爱发疯
- 大圆角、软乎乎卡片、手绘涂鸦感、贴纸错位效果
- 风格参考：韩国Bubble/小宇宙App、游戏《Muse Dash》《LP》

### 7.2 配色方案

#### 7.2.1 背景色

- 主背景：奶油白 #FFFDF2
- 卡片背景：纯白 #FFFFFF

#### 7.2.2 主色调

- 俏皮粉红：#FF5E7C
- 电光紫：#6C63FF
- 亮黄：#FFD166
- 薄荷绿：#2EC4B6

#### 7.2.3 危险等级配色

- 安全：薄荷绿 #2EC4B6
- 注意：亮黄 #FFD166
- 危险：橙色 #FF8C00
- 红温：俏皮粉红 #FF5E7C
- 濒死：深红 #FF003C

#### 7.2.4 文字颜色

- 主文字：深灰 #333333
- 次文字：中灰 #666666
- 浅灰文字：#999999
- 高亮文字：使用主色调

### 7.3 动态UI效果

增加动画性能分级。

- 果汁状液体晃动效果
- 霓虹闪烁效果
- 彩色纸花动画效果
- 贴纸错位效果
- 文字轻微歪斜效果
- 背景渐变效果
- 元素轻微浮动效果
- 金色镶边效果（高优先级任务）
- 「功德-∞」漂浮特效

**动画性能分级**：

|设备等级|判定标准|动画策略|
|---|---|---|
|高端|iPhone 13+ / 骁龙8系+ / 天玑9000+|完整效果，60fps|
|中端|iPhone 12 / 骁龙7系 / 天玑800系|简化粒子数量，霓虹闪烁改为间歇式，背景渐变降低帧率至30fps|
|低端|Android 8.0入门机 / 老旧设备|禁用粒子效果，液体晃动改为静态渐变，霓虹闪烁改为纯色，贴纸错位/文字歪斜关闭，仅保留基础浮动|

- 使用原生驱动动画（React Native`useNativeDriver: true` / Flutter直接渲染），避免JS线程阻塞
- 纸花动画使用对象池复用粒子节点
- 监听系统低电量模式，自动降级为非动画状态

### 7.4 特殊文本渲染规则

"功德-∞"、"Lv.92 ⭐⭐⭐"等组合文本在不同屏幕宽度下禁止被换行截断，需统一处理：

- 徽章、等级标签、成就贴纸使用`white-space: nowrap` +`display: inline-block`，整体不换行
- 对于极小屏幕（如 iPhone SE），允许容器横向滑动查看完整内容（`overflow-x: auto`）
- 关键梗词（如"功德-∞"）在文本插值时用不换行空格` ` 连接关键部分：`功德- ∞`
- React Native 实现：对徽章文本组件设置`numberOfLines={1}` +`ellipsizeMode="clip"`，外层容器设置`flexShrink: 0`

### 7.5 目标效果

从《黑客任务控制台》变成《大学生活发疯手账本 – 荧光笔版》，让大学生一看就想下载，一玩就想截图。

---

## 8. 技术约束与上线计划

### 8.1 技术约束

- iOS最低14.0+
- Android最低8.0(API 26)+

### 8.2 交付里程碑

- 设计：2周
- 开发：6周
- 联调：2周
- 内测：2周
- 提审：1周

### 8.3 换机数据迁移风险提示

- 首次启动弹窗提示
- 隐私政策中明确告知
- 关于页三处明确告知

---

## 9. 版本规划

### 9.1 P0（上线前必须）

- HP/SAN持久化
- 优先级权重
- 跨日惰性结算（替代凌晨定时后台结算）
- 输入极值限制
- **本地推送通知集成**（iOS UNUserNotificationCenter / Android AlarmManager，工作量约3人日）
- 埋点设计

### 9.2 P1（首版后补丁）

- 时间篡改检测
- 记录模式优先级
- 历史修改窗口
- 通知权限降级
- 免责声明

### 9.3 P2

- 完整时间防御
- 增量重算
- 全量数据导出导入

---

## 10. 验收标准

1. 用户打开App，查看首页吉祥物状态和生存状态面板（生命值（今日）、磨损值（累计）、理智值、睡眠债、功德值）
2. 用户进入DDL页面，创建一个高优先级任务（输入任务名称、选择截止时间、选择优先级为高）
3. 用户返回首页，查看当前最危险DDL展示（任务名称、血条进度带金色镶边、剩余时间）和吉祥物情绪变化
4. 用户点击吉祥物，查看随机显示的激励语录
5. 用户进入摸鱼页面，使用计时器记录学习时间，停止后查看时间记录
6. 用户进入设置页，点击「日切点设置」，调整日切点为凌晨3:00，保存设置
7. 用户进入卡片页面，查看当日生成的《生存日报》预览（包含生命值（今日）、磨损值（累计）），点击「保存到相册」按钮保存卡片
8. 用户进入设置页，点击「数据统计」，查看今日学习/摸鱼/睡眠数据饼图和累计统计，尝试修改7天内数据成功，尝试修改30天以上数据被禁止
9. 用户进入设置页，点击「自定义语录」，添加一条新语录（输入文本，保存），返回首页点击吉祥物验证新语录出现
10. 用户完成任务，标记任务完成，观看彩色纸花动画效果，听到完成音效

### 10.5 系统健壮性测试

> 由于反作弊、惰性结算、计时器异常恢复等核心机制涉及大量时间边界、极值逻辑，纯手动点按无法充分验证，**开发团队必须提供内置 Debug 后门**，以支持 QA 团队对以下场景进行完整边界验证。

#### Debug 后门触发方式

- 在「关于」页面，**连续点击麻糬 🍡 吉祥物图标 10 次**，进入开发者/测试模式（Developer Mode）。
- 必须通过编译期宏（如`#if DEBUG` /`BuildConfig.IS_DEBUG`）完全包裹，生产包绝对不可达。
- Debug后门代码必须完全隔离在独立的源代码文件中，通过构建脚本在Release构建时物理删除该文件，而非仅依赖条件编译。
- CI/CD流水线中增加Release包扫描步骤，使用`strings`、`grep`扫描APK/IPA中是否包含"测试过期任务"、"Developer Mode"等Debug特征字符串。

#### Debug 后门核心能力

|功能|说明|
|---|---|
|一键添加 100 个过期任务|生成任务名为「测试过期任务 #N」、截止时间为过去 N 小时的任务，覆盖各优先级|
|查看任务状态统计|按「已完成/进行中/已过期」分类统计当前任务数量|
|查看今日 timer_sessions & daily_aggregates|打印当日`timer_sessions`和`daily_aggregates`行的完整JSON，便于验证计时器写入与结算结果|

#### 需验证的核心边界场景

|场景编号|测试场景|期望行为|
|---|---|---|
|HC-01|计时器运行超过 4 小时后停止|会话强制作废，不写入任何时长，提示用户|
|HC-02|单日累计异常恢复 > 12 小时|计时器功能锁定，引导手动输入|
|HC-03|删除「红温」且优先级≥中任务|弹出惩罚警告，确认后扣 HP-5 / 功德-10|
|HC-04|编辑已过期任务的截止时间|截止时间字段不可编辑（只读锁定）|
|HC-05|单日学习时长手动输入 + 跨天拆分合计超过 24h|截断到 24h，多余部分丢弃并记录日志|
|HC-06|解锁成就后触发增量重算|成就状态不回滚，永久保留|
|HC-07|惰性结算跨多天回补|每天的「每日人格」均正常生成并写入 daily_aggregates|
|HC-08|修改系统时间到过去|弹窗「时光倒流」警告，关键操作被禁止|

---

## 11. 本期不实现功能

- AI功能
- 社交功能
- 排行榜
- 云同步
- 多人系统
- 主题切换功能（仅保留入口）
- 数据导出功能（P2规划）
- 任务分类功能
- 任务标签功能
- 历史记录查询（除卡片历史回顾外）
- 账号系统
- 用户登录/注册
- 多设备适配优化
- 文件限制（类型、大小、上传数量）
- 多媒体参数（分辨率、尺寸、帧率、压缩率）
- 兼容性/适配（多设备适配、浏览器适配）
- 性能/时延（加载速度、响应时间、动画流畅度、网络异常/超时）
- 社交能力（点赞、评论、分享按钮之外的社交功能、聊天）

---

## 12. 全局权限申请与降级矩阵（Permission Matrix）

|权限类型|触发场景|首次弹窗文案|拒绝后UI降级|二次引导|跳转系统设置|
|---|---|---|---|---|---|
|**通知权限**|用户创建第一个DDL后|"是否需要麻糬在DDL截止前提醒你？"|首页/DDL页常驻粉红提示条（可关闭）；设置页"DDL提醒"显示⚠️已关闭|用户点击提示条跳转系统设置；连续拒绝3次后不再自动弹窗，仅保留提示条（可关闭）|✅|
|**相册写入权限**|首次点击"保存到相册"|"麻糬想把你超棒的生存日报存到相册里，可以吗？"|弹窗引导（含"去设置"按钮）；再次拒绝后改为Toast提示"权限未开启，无法保存"|弹窗提供"去设置"按钮|✅|
|**后台运行权限（可选）**|首次使用计时器|"为了记录你的学习/摸鱼时长，麻糬需要在后台运行，不然会被系统打断哦~"|计时器仍可用，锁屏后可能暂停（差值恢复兜底）|无强制引导，接受降级|❌|

**通知权限分级**：

- Level 0（已授权）：完整体验，DDL 到期前按时推送
- Level 1（首次拒绝）：首页/DDL页常驻提示条（可关闭），设置页"DDL提醒"标红显示⚠️已关闭
- Level 2（连续拒绝3次）：不再主动弹出系统请求框，仅保留常驻提示条（用户可手动关闭）

---

## 13. 应用生命周期与状态恢复流图（App Lifecycle & Recovery）

### 13.1 冷启动（onLaunch）

```
→ 检查本地数据库是否存在（首次安装则初始化表结构）
  → 异步执行表创建和种子数据插入（后台线程），主线程立即展示欢迎页/引导页
  → 设置 is_db_ready = false
→ 异步执行过期操作日志清理（每周一次）
→ 检测未结束的计时会话
    ├── 有会话 → 弹出恢复选择弹窗（记录/丢弃/继续）
    └── 无会话 → 继续
→ 执行跨日惰性结算（检查 last_settle_date < today-1，异步逐天补算）
  → 签名校验 last_settled_date_signature，失败则进入安全模式
→ 更新 last_settle_date = today-1
→ 更新 last_settled_date_signature（HMAC-SHA256签名）
→ 设置 is_db_ready = true，释放初始化期间排队的用户操作
→ 刷新首页 UI（显示最新 HP/SAN/磨损值/功德值）
→ 请求通知权限（首次启动，推迟到用户创建第一个DDL后3-5秒，见§4.19）
```

**DB初始化并发控制**：
-`is_db_ready`布尔标志：数据库初始化完成前设为`false`，完成后设为`true`
- 用户操作队列：初始化期间用户点击创建DDL、保存语录等操作进入内存队列，初始化完成后依次执行
- 快速跳过引导页防护：若用户快速跳过引导页，首页展示骨架屏/Loading，直到`is_db_ready = true`才允许交互
- 初始化超时保护：若数据库初始化超过10秒（极端低端设备），展示"麻糬正在整理房间……"进度提示，防止用户认为App卡死

### 13.2 从后台切回前台（onForeground）

```
→ 检测未结束的计时会话（同冷启动逻辑）
→ 执行跨日惰性结算（若 last_settled_date < today-1，异步执行，标记脏数据+后台结算+结算完成通知UI刷新）
→ 刷新 UI
```

### 13.3 进入后台（onBackground）

后台任务仅在计时器运行时启动。

```
→ 若计时器运行中：
    ├── iOS：申请后台任务时间（BGTask）
    └── Android：启动前台服务（Foreground Service）
→ 若计时器未运行：不申请后台任务，不启动前台服务
→ 保存计时器状态到本地（active_timer_type, start_timestamp, accum_secs）
```

### 13.4 被系统杀死

```
→ 无回调可用
→ 依赖下次冷启动时的会话检测逻辑自动恢复
```

### 13.5 计时器异常恢复流程（详细）

修正上限为4小时。

```
检测到未结束会话
→ elapsed = min(now_ts - start_ts, 4 × 3600)  // 最长4小时
→ IF elapsed == 4 × 3600:
     弹窗："这次的计时记录超过了4小时，麻糬判定为异常会话，已自动作废。下次不要忘记关计时器哦~"
     标记 is_valid = 0，不记录时长
→ ELSE:
     弹窗："检测到上次学习/摸鱼未结束，已过去X小时Y分钟，是否记录？"
       ├── "记录"：按日切点拆分 elapsed 累加到对应日期 daily_aggregates 字段，清除会话
       ├── "丢弃"：清除会话，不记录
       └── "继续"：重置 start_ts = now，保留 type，重新开始计时
→ 用户不操作：保留会话，下次启动再次询问
```

---

## 14. 工程交付附录

### 14.1 模块一：反作弊与防逃课机制声明（Anti-Cheat & Exploit Prevention）

> 一次性解决机制漏洞，明确"禁止事项"及"惩罚措施"。
> 免责声明：纯本地SQLite架构下，Anti-Cheat机制依赖App代码完整性，无法防御Root/越狱后的数据库直接篡改。核心反作弊针对误操作和轻度滥用，未来云同步版本可引入服务端校验。

#### 14.1.1 任务删除惩罚（Task Deletion Penalty）

统一惩罚条件。

- 删除**红温（<12h）**或**濒死（<3h），或优先级 ≥ 中**的未完成任务：
    - 立即扣除`生命值 -5` 和`功德值 -10`（写入操作日志 operation_log）。
    - 弹出确认弹窗警告，用户取消则不扣分不删除。

#### 14.1.2 过期任务编辑限制（Expired Task Edit Restriction）

-`is_expired = 1`（由`deadline < now && status != 'completed'`自动推导）的任务，其`截止时间`字段在编辑弹窗中锁定为**只读**。
- 显示提示：「⚠️ 防逃课规则：已过期任务截止时间不可修改」。
- 用户仍可修改任务名称和优先级。

#### 14.1.3 异常计时器保护（Abnormal Timer Protection）

- **单次会话 4h 硬上限**：`stopTimer()` 或后台恢复时，若`elapsed > 4 * 3600`，本次会话**强制作废**，不计入统计。
- **每日 12h 锁定**：通过`recordAbnormalSecs(secs, date)` 累计异常秒数，若当日累计超过 43200 秒，计时器按钮禁用，显示锁定提示。
- 锁定状态次日自动解除（新日期重置计数）。

---

### 14.2 模块二：底层数据结构修正（DB Schema 3.0）

采用"单一数据源"原则，所有SQL定义以§4.12为唯一基准。本模块不再重复完整的CREATE TABLE语句，避免Schema漂移。

>`time_records`表职责收缩为仅存储手动录入数据，新增`timer_sessions`（计时器原始会话）和`daily_aggregates`（日聚合），遵循数据库第三范式。

**Schema 3.0 表清单**（详见§4.12）：
| 表名 | 职责 |
|---|---|
|`timer_sessions` | 计时器原始会话（原始粒度） |
|`time_records` | 手动录入数据（职责收缩） |
|`daily_aggregates` | 按日聚合结果 |
|`quotes` | 自定义语录 |
|`achievements` | 成就数据 |
|`operation_log` | 操作日志（含row_hash） |
|`tasks` | 核心任务数据 |
|`global_config` | 全局配置（惰性结算基础设施） |
|`timer_sessions_archive` | 已结算会话归档（可选） |

**关键Schema设计**：
-`daily_aggregates.final_hp` /`final_san` /`final_karma` 增加`DEFAULT` 值（80/80/0），消除NULL传播风险
-`tasks`表补充完整Schema
-`global_config`表补充正式Schema
- SQLite初始化启用WAL模式（`PRAGMA journal_mode=WAL`）与`synchronous=NORMAL`

#### 操作日志表`operation_log`（保留Schema示例，完整定义见§4.12.4）

```sql
CREATE TABLE IF NOT EXISTS operation_log (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp   INTEGER NOT NULL,              -- Unix timestamp（秒）
    action_type TEXT    NOT NULL,              -- 'delete_penalty', 'cross_day_truncated', etc.
    target_type TEXT,                          -- 'task', 'timer_session', etc.
    target_id   INTEGER,
    details     TEXT,                          -- JSON
    user_visible INTEGER DEFAULT 0,            -- 1=用户可见
    row_hash    TEXT                           -- HMAC-SHA256行级哈希
);

CREATE INDEX idx_oplog_time ON operation_log(timestamp);
CREATE INDEX idx_oplog_action ON operation_log(action_type);
```

---

### 14.3 模块三：惰性结算完整状态机（Lazy Settlement State Machine）

> 替换原有`4.22 跨日惰性结算` 伪代码，确保人格生成、成就检查等所有计算均不遗漏。

```
FUNCTION settleCrossDays(lastSettledDate):
  today = getCurrentDateByCutoff()

  // 异步执行，主线程展示Loading/骨架屏
  RUN_IN_BACKGROUND:
    // 单次批量聚合查询（仅未结算且有效会话）
    sessions = SELECT assigned_date, session_type, SUM(duration_seconds)
               FROM timer_sessions
               WHERE settled_date IS NULL AND is_valid = 1
               GROUP BY assigned_date, session_type

    FOR date IN (lastSettledDate+1 ... today-1):

      1. 从批量聚合结果提取 date 的 total_study_secs, total_slack_secs

      2. 读取 time_records[date] 的 sleep_hours（手动录入值）

      3. 数据截断兜底（Data Integrity §8）：
         combined_secs = total_study_secs + total_slack_secs
         IF combined_secs > 86400: 按LIFO截断至总计 ≤ 86400 秒
         丢弃部分在 operation_log 中标记为 'cross_day_truncated'

      4. 根据公式计算 HP、SAN、磨损值、功德值（见 §4.21）
         // 继承 date-1 日的 wear_snapshot 和 karma_snapshot

      5. 【新增】调用 generatePersonality(date)：
         基于 HP/SAN/功德值生成「每日人格」称号和吐槽文案
         将 personality_title / personality_desc 写入 daily_aggregates[date]

      6. 将最终值写入 daily_aggregates[date]（UPSERT）
         // 包含 final_hp, final_san, final_karma, wear_snapshot, karma_snapshot, 等

      7. 更新全局磨损值状态（global_config wear_value）

      8. 标记该日期涉及的 timer_sessions 的 settled_date = date

      9. 【成就不可逆 §4】checkAndUnlockAchievements(date)：
         仅在尚未解锁时判断条件，已解锁则跳过，绝不回滚

    UPDATE global_config SET value = today-1 WHERE key = 'last_settled_date';
    NOTIFY_UI_SETTLEMENT_COMPLETE
```

关键新增：

- 异步执行+分层结算：≤7天同步快速结算，>7天异步后台结算+进度提示。
- 批量聚合查询：单次GROUP BY替代30次独立查询，避免N+1问题。
- 快照缓存：`daily_aggregates`增加`wear_snapshot`和`karma_snapshot`，支撑增量重算。
- 幂等保护：已结算日期直接跳过，避免重复计算。
- 复合索引：`idx_timer_sessions_start_valid`和`idx_timer_sessions_settled`优化查询性能。

---

### 14.4 §9.5 系统健壮性测试说明（QA Debug 后门）

开发团队**必须**在「关于」页面提供吉祥物 10 连点触发的 Debug 后门，支持以下 QA 场景验证：

- Debug后门代码必须通过编译期宏（`#if DEBUG` /`BuildConfig.IS_DEBUG`）完全包裹。
- Debug后门代码必须隔离在独立源文件中，通过构建脚本在Release构建时物理删除。
- CI/CD流水线增加Release包扫描，使用`strings`、`grep`扫描APK/IPA中是否包含"测试过期任务"、"Developer Mode"等特征字符串。
- 生产包绝对不可达。

| 场景编号  | 测试场景                | 期望行为                  |
| ----- | ------------------- | --------------------- |
| HC-01 | 计时器运行超过 4 小时后停止     | 会话强制作废，不写入任何时长        |
| HC-02 | 单日累计异常恢复 > 12 小时    | 计时器功能锁定，引导手动输入        |
| HC-03 | 删除「红温」且优先级≥中任务     | 弹惩罚确认，确认后扣 HP-5/功德-10 |
| HC-04 | 编辑已过期任务的截止时间        | 截止时间字段只读，无法修改         |
| HC-05 | 跨天拆分 + 手动输入合计超过 24h | 截断至 24h，多余部分丢弃并记录     |
| HC-06 | 解锁成就后触发增量重算         | 成就状态不回滚，永久保留          |
| HC-07 | 惰性结算跨多天回补           | 每天的「每日人格」均正常生成并写入 daily_aggregates |
| HC-08 | 修改系统时间到过去           | 弹「时光倒流」警告，关键操作禁止      |

---

## 15. 错误码与异常处理体系

补充全局错误码体系，统一工程实现语言，消除各模块"各自发明魔法数字"的维护风险。

### 15.1 错误码格式

```
ERR-{模块}-{级别}-{序号}

模块：DB(数据库) | NET(网络/NTP) | SEC(安全) | UI(界面) | CALC(计算) | PERM(权限)
级别：F(致命) | E(错误) | W(警告) | I(信息)
```

### 15.2 核心错误码表

| 错误码 | 模块 | 场景 | 用户可见文案 | 处理建议 |
|---|---|---|---|---|
| ERR-DB-F-001 | 数据库 | 初始化失败，无法创建表 | 「麻糬的房间塌了，重启试试？」 | 重启App，若持续失败引导清除数据重装 |
| ERR-DB-E-002 | 数据库 | WAL模式切换失败 | （静默） | 降级为DELETE journaling模式，上报埋点 |
| ERR-DB-W-003 | 数据库 | VACUUM执行超时 | （静默） | 跳过本次VACUUM，下次启动再试 |
| ERR-SEC-F-001 | 安全 | NTP校验失败且>72h未同步 | 「系统时间校验失败，部分功能受限」 | 引导联网或检查系统时间设置 |
| ERR-SEC-E-002 | 安全 | last_settled_date签名校验失败 | 「检测到数据异常，建议核对近期操作」 | 进入安全模式（只读），用户确认后恢复 |
| ERR-SEC-W-003 | 安全 | 单日学习时长>16h标记异常 | 「今日学习时长异常，麻糬帮你标记了一下」 | 提示用户核对，不阻断操作 |
| ERR-SEC-W-004 | 安全 | 系统时间倒流检测触发 | 「检测到时光倒流，麻糬很困惑~」 | 弹窗警告，禁止关键操作直到NTP校验通过 |
| ERR-NET-E-001 | 网络 | NTP服务器全部不可达 | 「网络时间同步失败，离线模式已启动」 | 进入离线降级模式，72h内允许完整操作 |
| ERR-CALC-E-001 | 计算 | 增量重算500ms超时 | 「数据量较大，后台计算中」 | 保留recalculation_pending标志，后台异步完成 |
| ERR-CALC-W-002 | 计算 | 跨天拆分命中MAX_SPLIT_SEGMENTS硬上限 | （静默，记录操作日志） | 将剩余时间归入最后一段，标记cross_day_truncated |
| ERR-UI-E-001 | 界面 | 动画组件初始化失败（低端设备） | （静默降级） | 自动降级为静态UI，不上报崩溃 |
| ERR-PERM-E-001 | 权限 | 通知权限被拒绝 | 「权限未开启，无法保存」 | 不再重复弹窗，保留常驻提示条 |
| ERR-PERM-E-002 | 权限 | 相册写入权限被拒绝 | 「权限未开启，无法保存」 | Toast提示，提供"去设置"入口 |

### 15.3 异常处理原则

1. **致命错误（F）**：必须阻断当前操作，提示用户，建议重启或重装。
2. **错误（E）**：阻断当前操作，提供降级方案或恢复路径，记录日志。
3. **警告（W）**：不阻断操作，提示用户核对，记录日志，用于事后审计。
4. **信息（I）**：仅记录日志，不上报用户，用于埋点和性能监控。

### 15.4 崩溃防护

- 所有数值计算入口必须包裹`try-catch`，任何未捕获异常不得导致App崩溃
- 公式计算中出现除以零、NULL传播等边界情况时，返回默认值（HP=80, SAN=80, wear=0, karma=0）并记录`ERR-CALC-W-003`
- SQLite查询出现`SQLITE_BUSY`时，指数退避重试（100ms → 200ms → 400ms），最多3次，仍失败则记录`ERR-DB-E-003`并提示用户
