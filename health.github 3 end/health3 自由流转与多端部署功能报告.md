 运动健康服务 App — 自由流转与多端部署功能报告

## 一、项目概述

本项目基于 HarmonyOS 运动健康服务 SDK 开发，在原有健康数据管理功能基础上，新增了 **自由流转（跨端迁移）** 和 **多端部署（响应式布局）** 两大核心能力，实现了应用在不同设备间的无缝流转与界面自适应。


## 二、自由流转功能

### 2.1 功能描述

自由流转是指用户在使用应用过程中，可以将当前任务（包括数据状态、页面状态）从一个设备无缝迁移到另一个设备，实现**业务不中断、体验不打断**的跨端协作体验。

### 2.2 实现方案

#### 2.2.1 技术架构

| 组件 | 作用 |
|------|------|
| `DistributedDataHelper` | 分布式数据对象工具类，负责创建和同步跨设备数据 |
| `EntryAbility.onContinue()` | 源端保存数据回调，在迁移时触发 |
| `AppStorage` | 全局数据存储，用于跨页面数据共享 |
| `distributedDataObject` | 鸿蒙分布式数据对象 API，实现设备间数据同步 |

#### 2.2.2 数据流转流程

```
┌─────────────────┐                    ┌─────────────────┐
│    设备 A        │                    │    设备 B        │
│  (源端/发起端)   │                    │  (对端/接收端)   │
├─────────────────┤                    ├─────────────────┤
│  1. 用户点击分享  │                    │                 │
│  2. 保存数据到    │                    │                 │
│     AppStorage   │                    │                 │
│  3. 创建分布式    │    ── 组网ID ──>  │  4. 接收组网ID  │
│     数据对象      │                    │  5. 创建分布式  │
│  4. 生成组网ID   │                    │     数据对象    │
│  5. 激活数据对象  │                    │  6. 监听恢复状态│
│                  │                    │  7. 数据恢复完成│
│                  │                    │  8. 页面刷新    │
└─────────────────┘                    └─────────────────┘
```

#### 2.2.3 数据迁移内容

| 数据项 | 类型 | 说明 |
|--------|------|------|
| `stepCount` | number | 当前步数 |
| `calorieCount` | number | 消耗卡路里 |
| `heartRate` | number | 心率 |
| `sleepHours` | number | 睡眠时长 |
| `stepGoal` | number | 步数目标 |
| `timestamp` | number | 数据时间戳 |

#### 2.2.4 核心代码实现

**1. 配置文件启用流转（module.json5）**

在 `entry` 模块的 `abilities` 中配置 `continuable` 属性：

```json5
"abilities": [
  {
    "name": "EntryAbility",
    "srcEntry": "./ets/entryability/EntryAbility.ets",
    "exported": true,
    "continuable": true,   // ← 启用跨端迁移
    "skills": [
      {
        "entities": ["entity.system.home"],
        "actions": ["action.system.home"]
      }
    ]
  }
]
```

**2. 权限配置（module.json5）**

```json5
"requestPermissions": [
  {
    "name": "ohos.permission.INTERNET"
  },
  {
    "name": "ohos.permission.DISTRIBUTED_DATASYNC",
    "reason": "$string:distributed_data_sync_reason",
    "usedScene": {
      "abilities": ["EntryAbility"],
      "when": "inuse"
    }
  }
]
```

**3. 源端保存数据（EntryAbility.ets）**

```typescript
async onContinue(wantParam: Record<string, Object>): Promise<AbilityConstant.OnContinueResult> {
  const healthData = {
    stepCount: AppStorage.get<number>('stepCount') || 0,
    calorieCount: AppStorage.get<number>('calorieCount') || 0,
    heartRate: AppStorage.get<number>('heartRate') || 0,
    sleepHours: AppStorage.get<number>('sleepHours') || 0,
    stepGoal: AppStorage.get<number>('stepGoal') || 8000,
    timestamp: Date.now()
  };
  const sessionId = await DistributedDataHelper.createSourceDataObject(this.context, healthData);
  wantParam['dataSessionId'] = sessionId;
  return AbilityConstant.OnContinueResult.AGREE;
}
```

**4. 对端恢复数据（EntryAbility.ets）**

```typescript
private handleContinueData(want: Want): void {
  const sessionId = want.parameters?.dataSessionId as string;
  if (sessionId) {
    DistributedDataHelper.createTargetDataObject(this.context, sessionId, (data) => {
      AppStorage.setOrCreate('stepCount', data.stepCount);
      AppStorage.setOrCreate('calorieCount', data.calorieCount);
      AppStorage.setOrCreate('heartRate', data.heartRate);
      AppStorage.setOrCreate('sleepHours', data.sleepHours);
      AppStorage.setOrCreate('stepGoal', data.stepGoal);
      AppStorage.setOrCreate('isDataRestored', true);
    });
  }
}
```

### 2.3 使用流程

| 步骤 | 操作 | 说明 |
|------|------|------|
| 1 | 设备 A 登录华为账号 | 两端需登录同一账号 |
| 2 | 设备 A 打开应用 | 进入主页 |
| 3 | 设备 A 点击"分享"按钮 | 触发数据准备 |
| 4 | 设备 B 打开应用 | 自动接收数据 |
| 5 | 数据同步完成 | 设备 B 显示与设备 A 相同的健康数据 |

### 2.4 约束条件

| 条件 | 要求 |
|------|------|
| 系统版本 | HarmonyOS NEXT Release 及以上 |
| 账号要求 | 两端登录同一华为账号 |
| 网络要求 | 开启 Wi-Fi 和蓝牙 |
| 应用要求 | 两端安装同一应用 |
| 数据大小 | onContinue 传输数据需控制在 100KB 以下 |


## 三、多端部署功能

### 3.1 功能描述

多端部署是指应用能够根据运行设备的屏幕尺寸、分辨率等特征，**自动调整界面布局**，在不同设备上呈现最佳的视觉和交互体验，实现"一次开发，多端部署"。

### 3.2 设备类型配置

在 `module.json5` 中配置支持的设备类型：

```json5
"deviceTypes": [
  "phone",
  "tablet"
]
```

### 3.3 适配策略

#### 3.3.1 断点适配

根据屏幕宽度将设备划分为不同断点：

| 断点 | 屏幕宽度 | 设备类型 |
|------|---------|----------|
| `sm` | < 600vp | 手机 |
| `lg` | ≥ 600vp | 平板 / PC |

#### 3.3.2 布局差异

| 布局模块 | 手机端 | 平板端 |
|----------|--------|--------|
| 步数+轮播图 | 上下堆叠 | 左右并排（40% / 60%） |
| 数据卡片 | 三列 | 三列等宽 |
| 热门功能 | 三列网格 | 四列网格 |
| 顶部区域 | 占比较高 | 压缩至 20% |

#### 3.3.3 尺寸响应

使用 `fs(sm, lg)` 方法根据断点返回不同数值：

```typescript
private fs(sm: number, lg: number): number {
  return this.currentBreakpoint === 'sm' ? sm : lg;
}

// 使用示例
.fontSize(this.fs(20, 24))  // 手机20，平板24
```

### 3.4 布局结构

```
┌─────────────────────────────────────────────────────────┐
│  🟦 顶部区域（手机30% / 平板20%）                       │
│  问候语 + 右上角操作按钮                                │
├─────────────────────────────────────────────────────────┤
│  手机：上下堆叠          平板：左右并排                 │
│  ┌──────────────┐       ┌─────────┐ ┌───────────────┐ │
│  │  步数卡片      │       │ 步数40% │ │ 轮播图60%    │ │
│  └──────────────┘       └─────────┘ └───────────────┘ │
│  ┌──────────────┐                                     │
│  │  轮播图       │                                     │
│  └──────────────┘                                     │
├─────────────────────────────────────────────────────────┤
│  📊 今日数据概览（三列等宽）                           │
│  342千卡  │  72 bpm  │  7.5小时                       │
├─────────────────────────────────────────────────────────┤
│  🔥 热门功能（手机3列 / 平板4列）                     │
│  ┌──┐ ┌──┐ ┌──┐   ┌──┐ ┌──┐ ┌──┐ ┌──┐              │
│  │数据│ │采样│ │锻炼│   │数据│ │采样│ │锻炼│ │健康│   │
│  └──┘ └──┘ └──┘   └──┘ └──┘ └──┘ └──┘              │
├─────────────────────────────────────────────────────────┤
│  💡 健康小贴士（精简一行）                             │
└─────────────────────────────────────────────────────────┘
```

### 3.5 响应式布局前后对比

| 对比项 | 适配前 | 适配后 |
|--------|--------|--------|
| 顶部占比 | 约 40% | 平板 20%，手机 30% |
| 步数+轮播图 | 上下堆叠，各占 100% | 平板 40%/60% 并排 |
| 热门功能列数 | 手机单行滑动 | 手机3列 / 平板4列 |
| 一屏展示 | 需要滚动 | 平板一屏完整展示 |
| 交互体验 | 信息密度低 | 信息密度适中 |

### 3.6 核心代码实现

**1. 断点监听**

```typescript
const win = await window.getLastWindow(getContext(this));
win.on('windowSizeChange', (size: window.Size) => {
  this.currentBreakpoint = this.getBreakpoint(px2vp(size.width));
});
```

**2. 条件渲染**

```typescript
if (this.currentBreakpoint === 'sm') {
  // 手机：上下堆叠
  Column() { this.buildStepCard(); this.buildBannerSwiper(); }
} else {
  // 平板：左右并排
  Row() { this.buildStepCard(); this.buildBannerSwiper(); }
}
```

**3. 动态网格列数**

```typescript
private getGridColumns(): string {
  return this.currentBreakpoint === 'sm' ? '1fr 1fr 1fr' : '1fr 1fr 1fr 1fr';
}
```


## 四、完整配置清单

### 4.1 module.json5 关键配置

| 配置项 | 配置值 | 说明 |
|--------|--------|------|
| `deviceTypes` | `["phone", "tablet"]` | 支持手机和平板 |
| `continuable` | `true` | 启用跨端迁移 |
| `ohos.permission.INTERNET` | — | 网络权限 |
| `ohos.permission.DISTRIBUTED_DATASYNC` | — | 分布式数据同步权限 |


## 五、功能清单

| 功能类别 | 功能项 | 状态 |
|----------|--------|------|
| **自由流转** | 数据跨端迁移 | ✅ 已实现 |
| | 分布式数据同步 | ✅ 已实现 |
| | 状态自动恢复 | ✅ 已实现 |
| | 权限管理 | ✅ 已配置 |
| **多端部署** | 手机/平板断点适配 | ✅ 已实现 |
| | 响应式布局切换 | ✅ 已实现 |
| | 尺寸自适应 | ✅ 已实现 |
| | 一屏完整展示 | ✅ 已优化 |


## 六、新增/修改文件清单

### 6.1 新增文件

| 文件路径 | 功能说明 |
|---------|----------|
| `common/utils/DistributedDataHelper.ets` | 分布式数据对象工具类 |

### 6.2 修改文件

| 文件路径 | 修改内容 |
|---------|----------|
| `entry/src/main/module.json5` | 添加 `continuable: true`、设备类型和权限配置 |
| `entry/src/main/ets/entryability/EntryAbility.ets` | 添加 `onContinue` 和数据恢复逻辑 |
| `entry/src/main/ets/pages/MainIndex.ets` | 响应式布局改造，添加分享功能 |
| `entry/src/main/resources/base/element/string.json` | 添加权限说明文字 |


## 七、总结

本次新增的自由流转功能使应用具备了跨设备数据迁移能力，用户在不同设备间切换时无需重新输入或设置，体验更加流畅。多端部署功能使应用能够智能适配手机和平板等不同屏幕尺寸，界面布局合理，信息密度适中，提升了应用在多设备场景下的可用性和用户体验。

两项功能共同构成了 HarmonyOS 应用"一次开发，多端部署"的核心能力，为后续更多设备的适配和更多场景的流转奠定了基础。
