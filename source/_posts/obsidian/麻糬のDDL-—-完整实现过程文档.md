---
title: "麻糬のDDL — 完整实现过程文档"
date: 2026-06-04 22:44:24
updated: 2026-06-04 22:44:24
permalink: /notes/麻糬のDDL-—-完整实现过程文档/
categories:
  - 🚀 项目实战
tags: []
toc: true
comments: true
---
> 本文档记录从零到 v2.2（v36）的完整实现过程，包含每个模块的技术选型、核心问题与解决方案。

---

## 目录

1. [项目技术栈总览](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#1-%E9%A1%B9%E7%9B%AE%E6%8A%80%E6%9C%AF%E6%A0%88%E6%80%BB%E8%A7%88)
2. [第一阶段：基础架构搭建](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#2-%E7%AC%AC%E4%B8%80%E9%98%B6%E6%AE%B5%E5%9F%BA%E7%A1%80%E6%9E%B6%E6%9E%84%E6%90%AD%E5%BB%BA)
3. [第二阶段：DDL 任务系统](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#3-%E7%AC%AC%E4%BA%8C%E9%98%B6%E6%AE%B5ddl-%E4%BB%BB%E5%8A%A1%E7%B3%BB%E7%BB%9F)
4. [第三阶段：精神状态算法](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#4-%E7%AC%AC%E4%B8%89%E9%98%B6%E6%AE%B5%E7%B2%BE%E7%A5%9E%E7%8A%B6%E6%80%81%E7%AE%97%E6%B3%95)
5. [第四阶段：计时器系统](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#5-%E7%AC%AC%E5%9B%9B%E9%98%B6%E6%AE%B5%E8%AE%A1%E6%97%B6%E5%99%A8%E7%B3%BB%E7%BB%9F)
6. [第五阶段：每日结算与磨损系统](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#6-%E7%AC%AC%E4%BA%94%E9%98%B6%E6%AE%B5%E6%AF%8F%E6%97%A5%E7%BB%93%E7%AE%97%E4%B8%8E%E7%A3%A8%E6%8D%9F%E7%B3%BB%E7%BB%9F)
7. [第六阶段：UI 情绪演出系统](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#7-%E7%AC%AC%E5%85%AD%E9%98%B6%E6%AE%B5ui-%E6%83%85%E7%BB%AA%E6%BC%94%E5%87%BA%E7%B3%BB%E7%BB%9F)
8. [第七阶段：生存日报卡片](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#8-%E7%AC%AC%E4%B8%83%E9%98%B6%E6%AE%B5%E7%94%9F%E5%AD%98%E6%97%A5%E6%8A%A5%E5%8D%A1%E7%89%87)
9. [第八阶段：成就系统与人格称号](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#9-%E7%AC%AC%E5%85%AB%E9%98%B6%E6%AE%B5%E6%88%90%E5%B0%B1%E7%B3%BB%E7%BB%9F%E4%B8%8E%E4%BA%BA%E6%A0%BC%E7%A7%B0%E5%8F%B7)
10. [第九阶段：推送通知系统](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#10-%E7%AC%AC%E4%B9%9D%E9%98%B6%E6%AE%B5%E6%8E%A8%E9%80%81%E9%80%9A%E7%9F%A5%E7%B3%BB%E7%BB%9F)
11. [第十阶段：自定义语录与语录数据库](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#11-%E7%AC%AC%E5%8D%81%E9%98%B6%E6%AE%B5%E8%87%AA%E5%AE%9A%E4%B9%89%E8%AF%AD%E5%BD%95%E4%B8%8E%E8%AF%AD%E5%BD%95%E6%95%B0%E6%8D%AE%E5%BA%93)
12. [第十一阶段：数据统计与可视化](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#12-%E7%AC%AC%E5%8D%81%E4%B8%80%E9%98%B6%E6%AE%B5%E6%95%B0%E6%8D%AE%E7%BB%9F%E8%AE%A1%E4%B8%8E%E5%8F%AF%E8%A7%86%E5%8C%96)
13. [第十二阶段：v2.2 反作弊系统（HC-01 ~ HC-08）](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#13-%E7%AC%AC%E5%8D%81%E4%BA%8C%E9%98%B6%E6%AE%B5v22-%E5%8F%8D%E4%BD%9C%E5%BC%8A%E7%B3%BB%E7%BB%9Fhc-01--hc-08)
14. [数据存储架构总览](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#14-%E6%95%B0%E6%8D%AE%E5%AD%98%E5%82%A8%E6%9E%B6%E6%9E%84%E6%80%BB%E8%A7%88)
15. [Bug 修复记录](https://www.miaoda.cn/projects/app-bmlmo7hbv9c1#15-bug-%E4%BF%AE%E5%A4%8D%E8%AE%B0%E5%BD%95)

---

## 1. 项目技术栈总览

|层次|技术|版本|作用|
|---|---|---|---|
|框架|React Native|0.83.2|跨平台移动应用基础|
|开发平台|Expo SDK|55|构建工具链 + 原生模块封装|
|路由|expo-router|55.0.5|文件系统路由，基于 React Navigation|
|样式|NativeWind v4 + TailwindCSS|4.2.3|原子化 CSS 类名样式|
|动画|react-native-reanimated|4.2.1|声明式 UI 动画（worklet 线程）|
|本地数据库|expo-sqlite|55.0.15|结构化本地持久化（WAL 模式）|
|键值存储|AsyncStorage|2.2.0|轻量配置/状态持久化|
|推送通知|expo-notifications|55.0.22|本地定时推送（无服务器）|
|触觉反馈|expo-haptics|55.0.14|按键震动反馈|
|截图|react-native-view-shot|4.0.3|卡片截图保存|
|相册|expo-media-library|55.0.16|图片保存到系统相册|
|文件|expo-file-system|55.0.19|本地文件读写（语录导入导出）|
|文件选择|expo-document-picker|55.0.13|JSON 文件导入|
|分享|expo-sharing|55.0.19|系统分享面板|
|TypeScript|TypeScript|5.9.2|全量类型检查|
|Lint|Biome + OxLint|2.4.5 / 1.60|代码质量|

**架构特点：纯本地，零服务器依赖。** 所有数据存储在设备本地 SQLite 和 AsyncStorage，无需网络连接，无隐私泄露风险。

---

## 2. 第一阶段：基础架构搭建

### 2.1 路由结构设计

**技术**：expo-router（文件系统路由）

**问题**：需要把 5 个 Tab 页面 + 若干子页面（成就、统计、语录、关于）组织在一起，同时兼容"无需登录"的纯本地场景。

**解决方案**：采用 Expo Router 的 Group 路由约定：

```
src/app/
├── _layout.tsx          ← 根 Stack，无 header
├── index.tsx            ← 重定向到 /(app)/(tabs)/home
├── (auth)/              ← 已预留但未启用（无需登录）
└── (app)/
    ├── _layout.tsx      ← 子页面 Stack（成就/统计/语录/关于/日切点设置）
    └── (tabs)/
        ├── _layout.tsx  ← 底部 TabBar 配置（5 个 Tab）
        ├── home.tsx     ← 精神状态首页
        ├── ddl.tsx      ← DDL 任务列表
        ├── slack.tsx    ← 摸鱼计时器
        ├── card.tsx     ← 生存日报卡片
        └── settings.tsx ← 设置菜单
```

`ctx.tsx` 保留`SessionContext` 接口但 session 恒为 null，兼容框架路由守卫逻辑，同时实现"不登录直接进入"。

### 2.2 全局样式

**技术**：NativeWind v4 + TailwindCSS + theme.ts

通过`src/global.css` 引入 NativeWind，在`tailwind.config.js` 声明扫描范围。业务颜色常量统一定义在`theme.ts`：

```
奶油白 #FFFDF2  — 全局背景
霓虹粉 #FF5E7C  — 摸鱼计时、主按钮
赛博紫 #6C63FF  — 标题、链接
多巴胺黄 #FFD166 — 警告状态
薄荷绿 #2EC4B6  — 学习计时、积极状态
危机红 #FF003C  — 极低血量、红温 DDL
```

### 2.3 SQLite 单例初始化

**技术**：expo-sqlite（异步 API）

**问题**：多个页面同时进入时可能触发`openDatabaseAsync` 并发调用，导致数据库实例冲突。

**解决方案**：`database.ts` 用单例 Promise：

```typescript
const dbReady: Promise<SQLiteDatabase> = initDb();
export async function getDb() { return dbReady; }
```

首次调用时`initDb()` 执行`CREATE TABLE IF NOT EXISTS`（幂等），后续调用复用同一实例。共建 5 张表：`tasks`、`time_records`、`daily_stats`、`timer_sessions`、`daily_aggregates`。

---

## 3. 第二阶段：DDL 任务系统

### 3.1 任务数据模型

**表结构（SQLite）**：

```sql
tasks (
  id TEXT PRIMARY KEY,          -- 36 字符随机 ID（Date.now(36) + random）
  name TEXT NOT NULL,
  deadline TEXT NOT NULL,       -- ISO datetime string
  priority INTEGER DEFAULT 2,   -- 1=低 2=中 3=高
  completed INTEGER DEFAULT 0,
  completed_at TEXT,
  created_at TEXT NOT NULL,
  is_overtime_complete INTEGER DEFAULT 0  -- 是否"超时补完成"
)
```

`is_overtime_complete` 字段是 v2.1 版本通过`ALTER TABLE ... ADD COLUMN ... CATCH` 兼容升级加入的。

### 3.2 智能日期解析（`lib/ddl.ts`）

**问题**：用户输入 DDL 时间格式多样，不能强制要求日历选择器。

**解决方案**：`parseDeadlineInput()` 函数支持 8 种格式：

|输入格式|示例|解析结果|
|---|---|---|
|自然语言|`明天` /`后天`|次日/隔日 23:59|
|月-日|`5-20` /`5.20` /`5/20`|当年 5月20日 23:59|
|中文日期|`5月20日` /`5月20`|当年 5月20日 23:59|
|完整日期|`2026-5-20`|2026年 5月20日 23:59|
|带时间|`2026-5-20 14:30`|精确到分钟|

**年份自动推断**：若解析出的日期早于今天，自动加一年（防止用户输"5-1"时跨年错误）。

### 3.3 危险等级与血条

**危险等级**（`getDangerLevel()`）：

```
> 48h  → safe（安全）  颜色：#39FF14 荧光绿
24-48h → warning（注意）颜色：#FFD700 金黄
12-24h → danger（危险） 颜色：#FF8C00 橙色
 3-12h → critical（红温）颜色：#FF003C 危机红
  <3h  → dying（濒死）  颜色：#FF003C 危机红（闪烁）
```

**优先级加成**：高优先级（`priority=3`）任务提前一级告警，`LEVELS` 数组`indexOf` 后`+1`，防止越界。

**血条**（`getHealthBarPercent()`）：

```
% = (剩余时间 / 总可用时间) × 100
总可用时间 = max(创建到截止的实际时间, 48h)
```

### 3.4 惩罚性删除（HC-03）

**问题**：用户可能通过删除任务绕过扣分惩罚。

**解决方案**：删除操作触发`addDeletePenalty(karmaDeduct=10, hpDeduct=5)`，数据持久化到`AsyncStorage PENALTY_KEY`，在`calculateSpiritState()` 中作为`penaltyAdjust` 传入后叠加扣减。

### 3.5 过期任务只读（HC-04）

编辑弹窗中检测`task.deadline < now`，若过期则 deadline 输入框设为`editable={false}`，并显示提示，防止用户篡改截止时间。

---

## 4. 第三阶段：精神状态算法

### 4.1 五维数值体系（`lib/state.ts`）

所有数值都是**纯函数实时计算**，不存储中间状态，每次页面 focus 时重新计算。

**生命值 HP（0-100）**：

```
HP = 80
   − lateHours × 5          （睡眠 < 6h 的缺口小时数）
   − Σ(未完成DDL × 8 × 优先级权重)  （权重：低1.0 / 中1.5 / 高2.0）
   − slackHours × 2
   + studyHours × 3
   − wearPenalty              （磨损惩罚，最高 −40，见第六阶段）
   clamp [0, 100]
```

**理智值 SAN（0-100）**：

```
SAN = 80
    − sleeplessDays × 8       （连续熬夜天数，最近7天统计）
    − redTaskCount × 12       （critical/dying 等级的未完成 DDL 数）
    − slackHours × 1.5
    + studyHours × 2
    clamp [0, 100]
```

**功德值 Karma（可负）**：按时完成 +5，摸鱼 >8h 扣 −20，最后1小时完成 −3，超时补完 −10，学习 >4h +2。累加历史数据，删任务额外扣。

**睡眠债**：`max(0, 8 - sleepHours)`，直接展示小时数。

**发疯浓度（0-100）**：`(HP损失 + SAN损失) / 2`，综合反映崩溃程度。

### 4.2`effectiveStudyMinutes` /`effectiveSlackMinutes`（`types.ts`）

**问题**：计时器自动累加 vs 手动录入数据可能共存，展示和计算时需要明确取哪个。

**解决方案**：`TimeRecord` 区分`timer_*` 和`manual_*` 两套字段：

```typescript
effectiveStudyMinutes(r) = r.manual_study_minutes ?? r.timer_study_minutes
effectiveSlackMinutes(r) = r.manual_slack_minutes ?? r.timer_slack_minutes
```

`manual_*` 为`null` 时取计时器值，有值时取手动值。所有精神状态计算、图表、卡片都通过这两个函数取数，保证数据来源一致性。

---

## 5. 第四阶段：计时器系统

### 5.1 核心问题：App 被杀后计时如何恢复

**React Native 无法在 App 被 kill 后保持 JS 线程运行。** 传统定时器方案（`setInterval` 累加）在 App 进入后台被杀死后会丢失状态。

**解决方案：差值法（`lib/timerStore.ts`）**

启动计时时，将`startTs`（毫秒时间戳）存入 AsyncStorage，而不是计时器计数：

```
存储内容：
  ddl_timer_type      "study" | "slack"
  ddl_timer_start_ts  按下"开始/继续"的时刻（ms）
  ddl_timer_accum_secs 当前段开始前已累计的秒数（暂停时叠加）
  ddl_timer_paused    "1" = 暂停
```

恢复时计算：`elapsed = accumSecs + (now - startTs) / 1000`

无论 App 关闭多久，重新打开时都能通过当前时间戳差值算出准确时长。

### 5.2 暂停/继续的累计逻辑

暂停时把`(now - startTs)` 的秒数加进`accumSecs`，再次继续时`startTs` 重置为当前时间，`accumSecs` 保持不变。停止时最终时长 =`accumSecs + (now - startTs)`（若未暂停）或直接用`accumSecs`（若已暂停）。

### 5.3 跨天拆分（`splitSecsByDate()`）

**问题**：用户在 23:50 开始计时跨过午夜，这 20 分钟应分别归入两个日期。日切点还支持用户自定义（默认凌晨 4 点，大学生多通宵场景）。

**解决方案**：循环按"下一个日切点"切割时间段：

```typescript
while (remaining > 0) {
  计算当前时间点所属逻辑日期（cutoffHour 之前归前一天）
  计算到下一个 cutoffHour 还有多少秒
  本段秒数 = min(remaining, secsUntilNextCutoff)
  remaining -= 本段秒数
  cursor = 下一个 cutoffHour
}
```

结果为`[{date, secs}, ...]` 数组，每个 slice 单独调用`addMinutesToDateRecord()`。

### 5.4 24h 截断兜底（HC-07）

`addMinutesToDateRecord()` 写入时检查当日`timer_study + timer_slack` 之和，计算剩余 headroom：

```typescript
const headroom = max(0, 1440 - currentTotal)
const safeMinutes = min(minutesToAdd, headroom)
if (safeMinutes <= 0) return // 当日已满 24h，丢弃剩余
```

---

## 6. 第五阶段：每日结算与磨损系统

### 6.1 懒惰结算（Lazy Settlement）

**问题**：不能在后台定时任务里结算（React Native 无此权限），但需要每天结算状态。

**解决方案**：进入任意主页面时检查`lastSettleDate`（存于 AsyncStorage），若落后今天则补算中间所有缺失的日期。`performLazySettlement()` 函数接受外部传入的`calcFn` 避免循环依赖，最多补算 30 天。

补算流程：

1.`loadLastSettleDate()` 读上次结算到哪天
2.`buildDateRange(from, today)` 生成需补算的日期列表
3. 按日期顺序读取每天的`time_records` +`tasks` 快照
4. 调用`calcFn` 得出`{hp, san, newWear, karma}`
5. 写入`daily_stats` 表（`INSERT OR REPLACE`）
6. 更新`lastSettleDate` 到今天

### 6.2 磨损值（Wear）系统

**问题**：单日 HP 公式是无状态计算，无法体现"连续熬夜/低血量"的累积惩罚。

**解决方案**：引入持久化的`wearValue`（磨损值）：

```
每日结算时：
  if 今日 HP < 30：  wearValue += (30 - HP)   // 低血量加重磨损
  if 今日 HP >= 80： wearValue *= 0.9           // 高血量缓慢恢复
  else               wearValue 不变

HP最终值 = 今日原始HP − min(40, wearValue × 0.5)
```

磨损值越高，HP 上限越低，形成雪球效应——状态越差越难恢复，符合"熬夜会越来越累"的现实感受。

### 6.3 增量重算（`runIncrementalRecalc()`）

当用户修改历史记录时（如手动修改昨天的摸鱼时间），需要重算该日之后最多 7 天的数值，更新`daily_stats`。同样接受外部`calcFn` 参数，逻辑与惰性结算共用。

---

## 7. 第六阶段：UI 情绪演出系统

### 7.1 吉祥物状态机（`home.tsx`）

**技术**：react-native-reanimated（worklet 线程，不阻塞 JS）

吉祥物状态由`getGlitchLevel(spirit, isNight)` 输出 0-4 的等级：

|等级|触发条件|吉祥物|背景变化|
|---|---|---|---|
|0|HP > 60|😊 正常|奶油白|
|1|HP 40-60 或深夜|😑 有点累|轻微粉色|
|2|HP 20-40|😰 危险|粉色背景|
|3|HP 10-20|🔥 红温|强粉 + 闪烁|
|4|HP ≤ 10|💀 系统崩溃|极端红粉 + 持续闪烁|

**动画实现**：

```typescript
// 背景颜色插值（白→粉，bgPink ∈ [0,1]）
const bgStyle = useAnimatedStyle(() => {
  const g = Math.round(253 - 33 * bgPink.value)
  const b = Math.round(242 - 12 * bgPink.value)
  return { backgroundColor: `rgb(255,${g},${b})` }
})

// 吉祥物弹跳：glitchLevel ≥ 2 时加速抖动
mascotBounce.value = withRepeat(
  withSequence(withTiming(-6, {duration: 200}), withTiming(0, {duration: 200})),
  -1, true
)
```

### 7.2 气泡语录

点击吉祥物时：`expo-haptics` 触发中等震动 →`withSequence(withSpring(1.3), withSpring(1))` 弹性缩放 → 从 SQLite 随机抽取语录显示 2 秒气泡。

### 7.3 文案系统（`lib/taunts.ts`）

6 组文案库（深夜、摸鱼太久、DDL濒死、DDL红温、完成任务、普通），`getTauntMessage()` 根据当前状态优先级匹配文案，随机抽取其中一条。

---

## 8. 第七阶段：生存日报卡片

### 8.1 截图保存流程

**技术**：react-native-view-shot + expo-media-library

```
1. 权限检查：MediaLibrary.requestPermissionsAsync(false, ['photo'])
2. 等待 200ms 确保渲染完成（setTimeout）
3. captureRef(cardRef, {format: 'png', quality: 1, result: 'tmpfile'})
4. 返回 file:// URI → createAssetAsync(uri) 写入系统相册
5. 保存快照元数据到 AsyncStorage 历史列表
```

**权限适配**：`app.json` 中为`expo-media-library` 声明三层权限适配所有 Android 版本（≤12 用 WRITE_EXTERNAL_STORAGE，13+ 用 READ_MEDIA_VISUAL_USER_SELECTED）。

### 8.2 历史快照系统

**问题**：生成的卡片图片如果直接存文件会占用大量空间，且无法在 App 内预览列表。

**解决方案**：不存图片，只存元数据（`CardSnapshot` 接口）到 AsyncStorage：

```typescript
interface CardSnapshot {
  ts: number             // 时间戳（排序用）
  dateLabel: string      // 日期标签
  lifePoints: number     // 生命值
  sanityPoints: number   // 理智值
  madnessLevel: number   // 发疯浓度
  activeTasks: number    // 活跃任务数
  dangerCount: number    // 危险任务数
  personalityTitle: string
  sleepHours: number
  unlockedCount: number
}
```

历史列表展示时，用存储的数据重新渲染轻量行卡片，而不是加载大图。

---

## 9. 第八阶段：成就系统与人格称号

### 9.1 成就解锁（`lib/achievements.ts`）

9 个成就定义存于常量数组，解锁状态持久化在`AsyncStorage ddlife_achievements_v1`（对象字典`{id: {unlockedAt}}`）。

`checkAndUnlockAchievements()` 在每次 home 页 focus 时调用，检测条件：

|成就|检测逻辑|
|---|---|
|阴间作息 🌙|`recentRecords.slice(0,3).every(r => r.sleep_hours < 6)`|
|极限施法 ⚡|所有完成任务均在 critical/dying 状态下完成|
|工位流浪汉 📦|今日`slack_minutes >= 480`|
|战略性摆烂 🛋️|7 天内无任务完成但有活跃任务|
|深夜赶稿侠 🦇|凌晨 3-5 点仍有未完成 DDL|
|DDL收藏家 💀|`activeTasks.length >= 5`|
|续命咖啡桶 ☕|睡眠 = 0 且当日有记录|
|人形加速器 🏃|1 小时内完成所有 DDL|
|修不完的功德 📿|`meritPoints < -100`|

**HC-06 成就不可逆原则**：`unlock()` 函数先检查`if (saved[id]) return false`，已解锁的永不撤销，即使数值回升。

### 9.2 人格称号（`lib/personality.ts`）

根据近 7 天数据，按优先级从高到低匹配 8 种人格，返回`{title, description}`：

```
凌晨<4h 睡眠 ≥3 天 → 夜行生物
逾期率 > 60% → DDL驯兽师
总摸鱼 > 600min → 摸鱼仙人
平均睡眠 < 5h → 阴间生物
活跃 DDL ≥ 5 → 战略型拖延专家
活跃 DDL ≥ 3 → 多线程崩溃选手
无任何任务 → 岁月静好
默认 → 濒危大学生
```

---

## 10. 第九阶段：推送通知系统

### 10.1 本地定时推送（`lib/notifications.ts`）

**技术**：expo-notifications（无服务器，纯本地`scheduleNotificationAsync`）

每个任务调度两条通知：

```
截止前 6h → "⚡ 命运预告｜【任务名】还有6小时，已进入XXX状态"
截止前 1h → "💀 命运预告｜【任务名】只剩1小时！即将迎来审判时刻"
```

通知 identifier 格式：`ddl_{taskId}_{6h|1h}`，重新调度前先取消旧通知，避免重复。

### 10.2 Android 8+ Channel 问题（v36 修复）

**问题**：Android 8.0 (API 26) 强制要求推送通知必须绑定`NotificationChannel`，否则通知静默失败（调度成功但不弹出）。

**根因**：早期版本`scheduleNotificationAsync` 的 trigger 没有`channelId`，`app.json` 里的`defaultChannel: "default"` 仅生效于 iOS。

**修复方案**：

```typescript
// 模块加载时注册 channel（Platform 守卫，iOS 不执行）
if (Platform.OS === 'android') {
  Notifications.setNotificationChannelAsync('ddl_alerts', {
    name: 'DDL 预警',
    importance: AndroidImportance.HIGH,  // 允许横幅弹出
    sound: 'default',
    vibrationPattern: [0, 250, 250, 250],
    lightColor: '#FF003C',
  })
}

// scheduleNotificationAsync 的 trigger 加 channelId
trigger: {
  type: SchedulableTriggerInputTypes.DATE,
  date: new Date(triggerMs),
  channelId: 'ddl_alerts',   ← 新增
}
```

`setNotificationChannelAsync` 已存在时无副作用，可安全重复调用。

### 10.3 权限降级策略

`getNotifDenyCount()` 记录用户拒绝次数：第 1-2 次弹弱提示，第 3+ 次不再打扰。数据存 AsyncStorage，防止过度申请权限导致用户反感。

---

## 11. 第十阶段：自定义语录与语录数据库

### 11.1 独立 SQLite 数据库（`quotesDb.ts`）

语录使用独立的`quotes.db`，与主数据库`mochi_ddl.db` 分离，防止 schema 耦合。表结构：

```sql
quotes (
  id       INTEGER PRIMARY KEY AUTOINCREMENT,
  text     TEXT NOT NULL,
  is_active INTEGER DEFAULT 1,   -- 0=已关闭，不参与随机抽取
  is_builtin INTEGER DEFAULT 0   -- 1=内置语录（不可删除）
)
```

10 条内置语录在数据库首次初始化时写入，通过`WHERE is_builtin = 1` 计数防重复插入。

### 11.2 JSON 导入导出

**导出**：从 SQLite 读取所有`is_builtin = 0` 的语录 → JSON 数组字符串 →`FileSystem.writeAsStringAsync` 写入`documentDirectory` → 调用系统分享面板。

**导入**：`DocumentPicker.getDocumentAsync({type: 'application/json'})` →`FileSystem.readAsStringAsync` 读取 →`JSON.parse` 验证为数组 → 逐条查重（`SELECT id WHERE text = ?`）→ 跳过重复，写入新条目。

---

## 12. 第十一阶段：数据统计与可视化

### 12.1 纯 React Native 绘图（`stats.tsx`）

**问题**：常见图表库（Victory Native、react-native-charts-wrapper）体积大，且与 React Native 0.83 + Expo 55 兼容性不稳定。

**解决方案**：使用`react-native-svg` 手写两种图表：

**饼图（`PieChart`）**：

- 计算学习/摸鱼/睡眠各自占当日总时间的角度
- 用 SVG`<Path>` 的`arc` 命令绘制扇形（`A rx ry 0 largeArcFlag 1 x y`）
- 通过数学三角函数计算各扇形终点坐标

**分组柱状图（`GroupedBarChart`）**：

- 取最近 N 天数据，每天两个柱（学习蓝 + 摸鱼粉）
- 柱高 =`(分钟数 / maxMinutes) × chartHeight`
- X 轴标签截取`MM-DD` 格式，等间距排列

---

## 13. 第十二阶段：v2.2 反作弊系统（HC-01 ~ HC-08）

v2.2 集中修复了 8 个可被用户（有意/无意）触发的数值作弊漏洞。

### HC-01：单次会话 4h 硬上限

**问题**：计时器运行中忘关，或 App 长时间挂后台，可能积累出不合理的超长时长。

**方案**：`stopTimer()` 和`restoreTimer()` 中均检查`totalSecs > 4 * 3600`，超出则**作废本次会话**，不写入数据库。作废的秒数进入异常累计池（HC-02）。

### HC-02：当日 12h 累计异常锁定

**方案**：`recordAbnormalSecs(secs, todayStr)` 累积当日所有作废会话的秒数（AsyncStorage 持久化），超过`12 * 3600` 后写入`TIMER_LOCK_KEY = todayStr`，之后`isTimerLockedToday()` 返回 true，页面上禁用所有计时按钮，锁定至次日。

### HC-03：惩罚性删除

见第三阶段 3.4 节。删除任务 = 作弊逃课，扣 Karma −10 / HP −5。

### HC-04：过期任务只读

见第三阶段 3.5 节。过期后 deadline 字段锁定，防止修改截止时间让任务"重活"。

### HC-05：懒惰结算不可跳过

`performLazySettlement()` 在进入 home/slack/card 任意页面时触发，设计上无法绕过。若 App 被长时间不打开，补算最多 30 天历史。

### HC-06：成就解锁不可逆

见第九阶段 9.1 节。已解锁的成就永不因数值回升而撤销。

### HC-07：每日 1440 分钟上限钳制

见第四阶段 5.4 节。防止异常计时或手动输入超过 24 小时。

### HC-08：时光倒流防御（`db/api.ts` +`slack.tsx`）

**问题**：用户手动将系统时间倒拨，可以让已结算的 DDL"复活"或使计时器`startTs` 计算出虚假的超长时长。

**检测机制**：每次进入摸鱼页时，比较`Date.now()` 与 AsyncStorage 中存储的`lastKnownTimestamp`：

```typescript
const TIME_REVERSE_TOLERANCE_MS = 60_000  // 60s 容差，处理正常时钟漂移
if (now < lastKnown - TOLERANCE) → 检测到时光倒流
```

**触发效果链**：

1. 页面顶部出现粉色封印横幅（可点击查看详情）
2. 弹出警告 Modal（解释原因和修复方式）
3. 开始学习/开始摸鱼按钮`disabled={timeReversed}`
4.`stopTimer()` 在写入数据库前被拦截，清空会话

**自动恢复**：系统时间恢复正常后，重新进入摸鱼页，`detectTimeReversal()` 检测通过，`timeReversed` 置 false，封印自动解除。

---

## 14. 数据存储架构总览

```
本地存储 = SQLite（mochi_ddl.db）+ SQLite（quotes.db）+ AsyncStorage

mochi_ddl.db
├── tasks                — DDL 任务（增删改查）
├── time_records         — 每日学习/摸鱼/睡眠时间
├── daily_stats          — 每日精神状态快照（懒惰结算结果）
├── timer_sessions       — 计时会话记录（保留用于审计）
└── daily_aggregates     — 每日聚合数据（备用）

quotes.db
└── quotes               — 语录（内置10条 + 用户自定义，含激活状态）

AsyncStorage（键值，轻量）
├── ddl_timer_type/start_ts/accum_secs/paused  — 计时器会话（差值法）
├── ddlife_timer_lock_date                     — 计时器锁定日期（HC-02）
├── ddlife_timer_abnormal_secs                 — 当日异常累计秒数（HC-02）
├── ddlife_delete_penalty_v1                   — 删除惩罚累计（HC-03）
├── ddlife_wear_state_v1                       — 磨损值持久化
├── ddlife_last_settle_date                    — 上次结算日期
├── ddlife_last_cleanup_date                   — 上次数据清理日期
├── ddlife_achievements_v1                     — 成就解锁状态
├── ddlife_settings                            — 应用设置（声音/日切点）
├── ddlife_cutoff_hour                         — 日切点设置（0-6）
├── ddlife_notif_deny_count                    — 通知权限拒绝次数
├── ddlife_quotes_only_mine                    — 仅用自定义语录开关
└── ddlife_last_known_ts                       — HC-08 时光倒流检测基准时间戳
```

---

## 15. Bug 修复记录

|版本|Bug|根因|修复方案|
|---|---|---|---|
|v1.x|手动录入覆盖计时器数据|`study_minutes` 只有一个字段|新增`timer_*` /`manual_*` 分字段，`effectiveXxx()` 函数统一取值|
|v2.0|跨日计时未拆分|`stopTimer` 直接加到当日|`splitSecsByDate()` 按日切点拆分，按日期分别累加|
|v2.0|磨损值重置|每次进入首页重新计算|`wearState` 持久化到 AsyncStorage，结算时更新|
|v2.1|`is_overtime_complete` 字段缺失|旧版本建表时未包含|`ALTER TABLE ... ADD COLUMN ... CATCH` 兼容升级|
|v2.2|成就可以因数值回落被撤销|没有"已解锁"判断|`unlock()` 函数先检查已存在则直接`return false`|
|v2.2|手动输入 > 1440 分钟|前端无上限校验|前端极值提示 + 数据库层`min(x, 1440)` 双重钳制|
|v2.2|Android DDL 通知静默失败|缺少 NotificationChannel|模块初始化时`setNotificationChannelAsync`，trigger 加`channelId`|
|v2.2|时光倒流可刷计时数据|未检测时间戳一致性|`detectTimeReversal()` 对比`lastKnownTimestamp`，检测到则封印计时器|

---

_最后更新：v2.2（v36）· 2026-05-14_
