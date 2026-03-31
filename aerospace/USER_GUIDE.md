# AeroSpace 窗口管理器使用说明书

> **版本**: 1.4.0
> **更新日期**: 2026-03-09
> **作者**: Hao Feng (F1)

---

## 目录

1. [快速入门](#1-快速入门)
2. [核心概念](#2-核心概念)
3. [模式系统](#3-模式系统)
4. [快捷键速查](#4-快捷键速查)
5. [常用工作流](#5-常用工作流)
6. [高级技巧](#6-高级技巧)
7. [故障排查](#7-故障排查)
8. [配置参考](#8-配置参考)

---

## 1. 快速入门

### 1.1 什么是 AeroSpace？

AeroSpace 是一款类似于 **i3wm** 的平铺式窗口管理器，专为 macOS 设计。

**核心特性**：
- 📐 **平铺布局**：窗口自动填充屏幕空间，无需手动调整
- ⌨️ **键盘驱动**：几乎所有操作都可以通过快捷键完成
- 🎯 **多显示器支持**：完善的多显示器管理
- 📝 **文本配置**：使用 TOML 格式配置文件，易于定制
- 🔧 **可扩展**：支持自定义模式和脚本

### 1.2 为什么使用 AeroSpace？

**优势**：
- ✅ **提高效率**：减少鼠标操作，专注于键盘工作流
- ✅ **空间利用**：窗口自动排列，最大化屏幕利用率
- ✅ **一致性**：所有应用遵循相同的窗口管理规则
- ✅ **可定制**：完全可配置的快捷键和行为

**适用人群**：
- 开发者、系统管理员等需要同时使用多个应用的用户
- 使用多显示器的用户
- 追求高效工作流的键盘控
- i3wm/yabai 等平铺窗口管理器的老用户

### 1.3 基础操作（5分钟上手）

#### 窗口焦点移动

```
Cmd+Shift+H  ←  左移焦点
Cmd+Shift+J  ↓  下移焦点
Cmd+Shift+K  ↑  上移焦点
Cmd+Shift+L  →  右移焦点
```

#### 窗口移动

```
Ctrl+Alt+H  ←  向左移动窗口
Ctrl+Alt+J  ↓  向下移动窗口
Ctrl+Alt+K  ↑  向上移动窗口
Ctrl+Alt+L  →  向右移动窗口
```

#### 工作区切换

```
Alt+1  →  切换到工作区 1
Alt+2  →  切换到工作区 2
...
Alt+8  →  切换到工作区 8
```

#### 关闭窗口

```
Alt+Q  →  关闭当前窗口（相当于 Cmd+W）
```

---

## 2. 核心概念

### 2.1 窗口布局类型

AeroSpace 支持多种布局方式，了解它们是高效使用的关键。

#### **Tiles（平铺布局）**

窗口并排显示，每个窗口占据独立的屏幕空间。

```
┌─────────────────────────────────────┐
│           窗口 A                        │
├─────────────────────────────────────┤
│           窗口 B                        │
└─────────────────────────────────────┘
```

**变体**：
- **h_tiles**（水平平铺）：窗口左右排列
- **v_tiles**（垂直平铺）：窗口上下排列

**使用场景**：
- 需要同时查看多个窗口
- 对比两个文档
- 代码编辑器 + 终端

#### **Accordion（窗口堆叠在一起）**

手风琴布局，只显示一个窗口，边缘有提示条。

```
┌─────────────────────────────────────┐
│ ◀ 窗口 A | 窗口 B | 窗口 C ▶             │
│                                          │
│        当前活动窗口内容                  │
│                                          │
└─────────────────────────────────────┘
```

**变体**：
- **h_accordion**（水平手风琴）：类似浏览器标签页
- **v_accordion**（垂直手风琴）：类似 IDE 侧边栏

**使用场景**：
- 需要快速切换多个窗口
- 屏幕空间有限
- 临时切换查看不同内容

#### **Floating（浮动布局）**

窗口可以自由移动和调整大小，不受平铺管理。

```
┌─────────────────┐
│                   │  ┌──────┐
│                   │  │窗口 B │
│      窗口 A       │  └──────┘
│                   │
│                   │
└─────────────────┘
```

**使用场景**：
- 需要特定位置的窗口（如聊天窗口）
- 临时窗口（如系统设置）
- 与 Rectangle 等窗口工具配合使用

### 2.2 工作区（Workspace）

工作区类似于 macOS 的**虚拟桌面**，但更强大。

**特点**：
- 每个工作区独立管理窗口布局
- 可以绑定到特定显示器
- 快速在工作区间切换
- 应用自动分配到指定工作区

**工作区规划示例**：

```
主显示器          次显示器
├─ 工作区 1       ├─ 工作区 3
│  Safari         │  Emacs
│  浏览器         │  Calibre
│                 │  微信读书
│
├─ 工作区 2       ├─ 工作区 4
│  Chrome         │  iTerm2
│  Arc            │  Fork
│  浏览器         │  Zotero
│                 │  NetNewsWire
│
├─ 工作区 5       ├─ 工作区 7
│  (临时)         │  (临时)
│                 │
├─ 工作区 6       ├─ 工作区 8
│  (临时)         │  (临时)
```

### 2.3 多显示器支持

AeroSpace 完美支持多显示器配置。

**核心概念**：
- **main**：主显示器（通常是内置显示器或主外接显示器）
- **secondary**：次显示器（非主显示器）

**操作方式**：
- `Alt+N`：切换焦点到下一个显示器
- `Alt+P`：切换焦点到上一个显示器
- `Alt+Shift+N`：移动窗口到下一个显示器

---

## 3. 模式系统

AeroSpace 采用**模式系统**设计，类似于 Vim 编辑器。

### 3.1 什么是模式？

模式是将相关操作分组的设计理念。不同模式下，快捷键有不同的含义。

**优势**：
- 🎯 **专注**：每个模式专注一类操作
- ⚡ **高效**：单键操作比组合键更快
- 🧠 **易记**：相关操作集中在一起
- 🔀 **流畅**：模式间快速切换

### 3.2 模式总览

| 模式          | 入口     | 用途         | 快捷键特点          |
| :-----------: | :------: | :----------: | :-----------------: |
| **Main**      | （默认） | 日常操作     | 组合键              |
| **Resize**    | `Alt+R`  | 调整窗口大小 | 单键 H/J/K/L        |
| **Move**      | `Alt+M`  | 移动窗口位置 | 单键 H/J/K/L + 数字 |
| **Layout**    | `Alt+T`  | 切换窗口布局 | 单键布局快捷键      |
| **Workspace** | `Alt+W`  | 管理工作区   | 单键数字 + H/L/N/P  |

### 3.3 Main 模式（主模式）

**默认模式**，包含所有常用快捷键。

**常用操作**：
- 焦点移动：`Cmd+Shift+H/J/K/L`
- 窗口移动：`Ctrl+Alt+H/J/K/L`
- 工作区切换：`Alt+1~8`
- 窗口大小调整：`Alt+Shift+H/J/K/L`

**特点**：
- 使用组合键，无需切换模式
- 适合偶尔进行的操作
- 保留所有常用功能

### 3.4 Resize 模式（窗口调整）

**入口**：`Alt+R`
**退出**：`Enter` 或 `Esc`

**用途**：精细调整窗口大小

**快捷键**：
```
H        减小宽度 50px
L        增加宽度 50px
J        增加高度 50px
K        减小高度 50px

Shift+H  减小宽度 10px（精细）
Shift+L  增加宽度 10px（精细）
Shift+J  增加高度 10px（精细）
Shift+K  减小高度 10px（精细）
```

**使用场景**：
- 需要精确控制窗口比例
- 需要多次调整达到理想大小
- 设置编辑器和终端的宽度比（如 70:30）

**示例工作流**：
```
1. Alt+R       进入 resize 模式
2. LLL         增加宽度 150px（按 3 次）
3. JJ          增加高度 100px
4. Enter       退出模式
```

### 3.5 Move 模式（窗口移动）

**入口**：`Alt+M`
**退出**：`Enter` 或 `Esc`

**用途**：快速移动窗口位置和分配工作区

**快捷键**：
```
H/J/K/L  向左/下/上/右移动窗口
1-8      移动窗口到工作区并跟随
N        移动到下一个显示器
P        移动到上一个显示器
```

**使用场景**：
- 重新排列窗口布局
- 将应用归类到不同工作区
- 在多显示器间调整窗口位置

**示例工作流**：
```
1. Alt+M       进入 move 模式
2. HHH         向左移动 3 次
3. 3           移动到工作区 3
4. Enter       退出模式
```

### 3.6 Layout 模式（布局切换）

**入口**：`Alt+T`
**退出**：`Esc`（Enter 用于全屏）

**用途**：快速切换不同窗口布局

**快捷键**：
```
H  水平平铺（左右分割）
V  垂直平铺（上下分割）
T  通用平铺

A  通用手风琴
B  水平手风琴（标签页）
S  垂直手风琴（堆叠）

F  浮动布局
G  平铺布局
E  切换平铺方向
=  平衡窗口大小
Space  全屏
```

**使用场景**：
- 快速对比两个窗口（使用手风琴布局）
- 需要更多空间时切换到全屏
- 调整窗口布局风格

**示例工作流**：
```
1. Alt+T       进入 layout 模式
2. B           切换到水平手风琴（标签页）
3. Tab/mouse   在两个窗口间切换
4. Esc         退出模式
```

### 3.7 Workspace 模式（工作区管理）

**入口**：`Alt+W`
**退出**：`Enter` 或 `Esc`

**用途**：快速切换工作区和管理多显示器

**快捷键**：
```
1-8      切换到指定工作区
H/L      上一个/下一个工作区
N/P      下一个/上一个显示器
Shift+1-8  移动窗口到工作区（不跟随）
```

**使用场景**：
- 快速在不同项目间切换
- 管理多个显示器上的工作区
- 将窗口分配到不同工作区但不切换焦点

**示例工作流**：
```
1. Alt+W       进入 workspace 模式
2. 1           切换到工作区 1（主显示器）
3. N           切换到下一个显示器
4. L           切换到下一个工作区
5. Enter       退出模式
```

---

## 4. 快捷键速查

### 4.1 全局快捷键（Main 模式）

#### 窗口焦点移动

| 快捷键        | 功能             |
| :------------ | :--------------: |
| `Cmd+Shift+H` | 焦点移到左边窗口 |
| `Cmd+Shift+J` | 焦点移到下边窗口 |
| `Cmd+Shift+K` | 焦点移到上边窗口 |
| `Cmd+Shift+L` | 焦点移到右边窗口 |

#### 窗口移动

| 快捷键       | 功能         |
| :----------- | :----------: |
| `Ctrl+Alt+H` | 向左移动窗口 |
| `Ctrl+Alt+J` | 向下移动窗口 |
| `Ctrl+Alt+K` | 向上移动窗口 |
| `Ctrl+Alt+L` | 向右移动窗口 |

#### 窗口大小调整

| 快捷键        | 功能          |
| :------------ | :-----------: |
| `Alt+Shift+H` | 减小宽度 50px |
| `Alt+Shift+L` | 增加宽度 50px |
| `Alt+Shift+J` | 增加高度 50px |
| `Alt+Shift+K` | 减小高度 50px |

#### 工作区管理

| 快捷键          | 功能                   |
| :-------------- | :--------------------: |
| `Alt+1~8`       | 切换到工作区 1~8       |
| `Alt+Shift+1~8` | 移动窗口到工作区并跟随 |
| `Alt+N`         | 焦点到下一个显示器     |
| `Alt+P`         | 焦点到上一个显示器     |
| `Alt+Shift+N`   | 移动窗口到下一个显示器 |
| `Alt+Shift+P`   | 移动窗口到工作区 5     |

#### 布局切换

| 快捷键            | 功能              |
| :---------------- | :---------------: |
| `Alt+Shift+Space` | 切换浮动/平铺模式 |
| `Alt+Comma`       | 三种布局循环切换  |
| `Alt+E`           | 切换平铺方向      |
| `Alt+=`           | 平衡窗口大小      |
| `Shift+Alt+Enter` | 全屏              |

#### 窗口管理

| 快捷键        | 功能         |
| :------------ | :----------: |
| `Alt+Q`       | 关闭窗口     |
| `Alt+Shift+C` | 重新加载配置 |

#### 模式入口

| 快捷键  | 模式           |
| :------ | :------------: |
| `Alt+R` | Resize 模式    |
| `Alt+M` | Move 模式      |
| `Alt+T` | Layout 模式    |
| `Alt+W` | Workspace 模式 |

### 4.2 模式快捷键

#### Resize 模式（`Alt+R` 进入）

| 快捷键          | 功能          |
| :-------------- | :-----------: |
| `H`             | 减小宽度 50px |
| `L`             | 增加宽度 50px |
| `J`             | 增加高度 50px |
| `K`             | 减小高度 50px |
| `Shift+H/L/J/K` | 精细调整 10px |
| `Enter/Esc`     | 退出模式      |

#### Move 模式（`Alt+M` 进入）

| 快捷键      | 功能                  |
| :---------- | :-------------------: |
| `H/J/K/L`   | 向左/下/上/右移动窗口 |
| `1-8`       | 移动到工作区并跟随    |
| `N`         | 移动到下一个显示器    |
| `P`         | 移动到上一个显示器    |
| `Enter/Esc` | 退出模式              |

#### Layout 模式（`Alt+T` 进入）

| 快捷键        | 功能                 |
| :------------ | :------------------: |
| `H`           | 水平平铺             |
| `V`           | 垂直平铺             |
| `T`           | 通用平铺             |
| `A`           | 通用手风琴           |
| `B`           | 水平手风琴（标签页） |
| `S`           | 垂直手风琴（堆叠）   |
| `F`           | 浮动布局             |
| `G`           | 平铺布局             |
| `E`           | 切换平铺方向         |
| `=`           | 平衡窗口大小         |
| `Space/Enter` | 全屏                 |
| `Esc`         | 退出模式             |

#### Workspace 模式（`Alt+W` 进入）

| 快捷键      | 功能               |
| :---------- | :----------------: |
| `1-8`       | 切换到工作区       |
| `H`         | 上一个工作区       |
| `L`         | 下一个工作区       |
| `N`         | 下一个显示器       |
| `P`         | 上一个显示器       |
| `Shift+1-8` | 移动窗口（不跟随） |
| `Enter/Esc` | 退出模式           |

### 4.3 Vim 风格键位说明

本配置大量使用 Vim 风格的键位：

| 键位   | 方向   | 来源     |
| :----: | :----: | :------: |
| **H**  | 左     | ← Left  |
| **J**  | 下     | ↓ Down  |
| **K**  | 上     | ↑ Up    |
| **L**  | 右     | → Right |

**记忆技巧**：
- `H` 和 `L` 在键盘上位于左右两侧
- `J` 和 `K` 在键盘上位于 `H` 和 `L` 之间
- `J` 看起来像向下的箭头
- `K` 看起来像向上的箭头（突起）

---

## 5. 常用工作流

### 5.1 日常开发工作流

**场景**：开发时需要编辑器、终端、浏览器三个窗口

```
步骤 1：打开应用
1. 打开 Emacs（编辑器）
2. 打开 iTerm2（终端）
3. 打开 Chrome（浏览器）

步骤 2：布局调整
1. Alt+T → 进入 layout 模式
2. H → 切换到水平平铺（左右分割）
3. Esc → 退出模式

步骤 3：窗口分配
1. 点击 Emacs 窗口
2. Ctrl+Alt+J → 将 Emacs 向下移动（占据左半屏）
3. 点击 iTerm2 窗口
4. Alt+R → 进入 resize 模式
5. H → 减小 iTerm2 宽度
6. Enter → 退出模式

步骤 4：最终布局
┌──────────────────┬──────────┐
│                    │           │
│     Emacs          │ iTerm2    │
│                    │           │
├──────────────────┴──────────┤
│       Chrome                   │
└─────────────────────────────┘

```

### 5.2 多显示器工作流

**场景**：主显示器用于编码，次显示器用于文档和终端

```
步骤 1：工作区规划
工作区 1（主显示器）：Emacs 编辑器
工作区 2（主显示器）：Chrome 浏览器
工作区 3（次显示器）：iTerm2 终端
工作区 4（次显示器）：PDF 文档

步骤 2：应用分配
1. 打开 Emacs → Alt+M → 3 → Enter
2. 打开 iTerm2 → Alt+M → 4 → Enter
3. Chrome 留在工作区 1

步骤 3：快速切换
1. Alt+1 → 主显示器，编辑代码
2. Alt+N → 切换到次显示器
3. Alt+W → 3 → 切换到终端
4. Alt+W → 4 → 查看文档
```

### 5.3 临时对比窗口

**场景**：需要快速对比两个文档

```
步骤 1：打开两个文档
1. 打开文档 A（Pages）
2. 打开文档 B（Pages）

步骤 2：切换到手风琴布局
1. Alt+T → 进入 layout 模式
2. B → 切换到水平手风琴（标签页）
3. Esc → 退出模式

步骤 3：快速对比
界面显示：
┌──────────────────────────────────────┐
│ ◀ 文档 A | 文档 B ▶                      │
│                                          │
│         当前文档内容                      │
│                                          │
└──────────────────────────────────────┘

4. 点击顶部标签或使用 Cmd+Tab 切换窗口
```

### 5.4 精细调整窗口比例

**场景**：编辑器和终端需要 70:30 的比例

```
步骤 1：初步布局
1. 打开 Emacs 和 iTerm2
2. Alt+T → H → Esc（水平平铺）

步骤 2：精细调整
1. 点击 iTerm2 窗口
2. Alt+R → 进入 resize 模式
3. 观察当前宽度
4. 连续按 H 直到达到理想比例
5. Enter → 退出模式

提示：如果超过预期，可以按 Shift+L 精细回调
```

### 5.5 项目切换工作流

**场景**：同时进行多个项目，快速切换

```
项目规划：
工作区 1-2：项目 A（浏览器 + 编辑器）
工作区 3-4：项目 B（编辑器 + 终端）
工作区 5-6：项目 C（临时）

步骤 1：分配项目
1. 项目 A 的应用 → Alt+Shift+1/2
2. 项目 B 的应用 → Alt+Shift+3/4
3. 项目 C 的应用 → Alt+Shift+5/6

步骤 2：快速切换
1. Alt+1 → 切换到项目 A
2. 工作...
3. Alt+3 → 切换到项目 B
4. 工作...
5. Alt+5 → 切换到项目 C
```

### 5.6 临时浮动窗口

**场景**：需要临时浮动一个窗口（如微信通知）

```
步骤 1：浮动当前窗口
1. 点击微信窗口
2. Alt+Shift+Space → 切换到浮动模式

步骤 2：调整位置
1. 使用鼠标拖动到合适位置
2. 使用 Rectangle 等工具调整大小（如果安装）

步骤 3：恢复平铺
1. 点击微信窗口
2. Alt+Shift+Space → 切换回平铺模式
```

---

## 6. 高级技巧

### 6.1 应用自动分配

配置文件中定义了应用自动分配到工作区的规则：

```toml
# 工作区 1：Safari 浏览器
[[on-window-detected]]
if.app-id = 'com.apple.Safari'
run = ['move-node-to-workspace 1']

# 工作区 3：编辑和阅读应用
[[on-window-detected]]
if.app-id = 'org.gnu.Emacs'
run = ['move-node-to-workspace 3']
```

**添加新规则**：

1. 获取应用 ID：
```bash
# 方法 1：使用 AeroSpace 命令
aerospace list-apps

# 方法 2：使用 osascript
osascript -e 'id of app "应用名称"'
```

2. 添加到配置文件：
```toml
[[on-window-detected]]
if.app-id = 'com.example.YourApp'
run = ['move-node-to-workspace X']  # X 是目标工作区编号
```

3. 重新加载配置：
```
Alt+Shift+C
```

### 6.2 浮动应用列表

某些应用不适合平铺布局，已配置为强制浮动：

- 鼠须管输入法
- 微信
- 腾讯会议
- Finder
- 邮件
- 系统设置
- Karabiner-Elements 设置
- Homerow

**添加浮动应用**：

```toml
[[on-window-detected]]
if.app-id = 'com.example.YourApp'
run = ['layout floating']
```

### 6.3 工作区与显示器绑定

配置文件中定义了工作区与显示器的绑定关系：

```toml
[workspace-to-monitor-force-assignment]
1 = 'main'       # 工作区 1 绑定到主显示器
2 = 'main'       # 工作区 2 绑定到主显示器
3 = 'secondary'  # 工作区 3 绑定到次显示器
4 = 'secondary'  # 工作区 4 绑定到次显示器
```

**说明**：
- `main`：主显示器
- `secondary`：次显示器
- 也可以使用显示器名称或正则表达式

**自定义绑定**：

```toml
# 按显示器名称（区分大小写）
5 = 'DELL U2720Q'

# 按正则表达式（不区分大小写）
6 = '^built-in retina display$'
7 = 'dell.*'
```

### 6.4 SketchyBar 集成

AeroSpace 与 SketchyBar 深度集成：

**配置位置**：
```toml
# 启动时加载 SketchyBar
after-startup-command = [
    'exec-and-forget sketchybar'
]

# 工作区切换时更新 SketchyBar
exec-on-workspace-change = ['/bin/bash', '-lc',
  'sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE'
]
```

**自定义 SketchyBar 显示**：

编辑 SketchyBar 配置文件（通常在 `~/.config/sketchybar/`）：

```bash
# 显示工作区图标
aerospace_workspace()
```

### 6.5 性能优化

**禁用手风琴提示边缘**：

```toml
accordion-padding = 0
```

**说明**：
- 设置为 0 禁用"提示边缘"视觉效果
- 避免窗口调整大小时产生视觉干扰
- 提高动画流畅度

### 6.6 键盘布局兼容性

**使用非 QWERTY 布局**：

AeroSpace 使用 **物理键位**而非字符键位，因此：
- 在 Dvorak、Colemak 等布局上，`H/J/K/L` 仍然是物理位置上的左/下/上/右键
- 无需重新配置快捷键

**查找应用 ID 的脚本**：

```bash
#!/bin/bash
# 获取当前窗口的应用 ID
aerospace list-windows --focused | awk '{print $2}'
```

---

## 7. 故障排查

### 7.1 常见问题

#### 问题 1：快捷键不生效

**症状**：按下快捷键没有任何反应

**排查步骤**：

1. **检查 AeroSpace 是否运行**：
```bash
ps aux | grep aerospace
```

2. **检查配置文件语法**：
```bash
aerospace reload-config
```
如果有语法错误，会显示错误信息。

3. **检查快捷键冲突**：
- 打开 "系统设置 → 键盘 → 快捷键"
- 查看是否有应用占用了相同快捷键
- 特别是 `Alt` 键相关的快捷键

4. **重新启动 AeroSpace**：
```bash
killall Aerospace
open -a Aerospace
```

#### 问题 2：窗口无法移动

**症状**：使用快捷键无法移动窗口

**可能原因**：

1. **窗口是浮动模式**：
   - 浮动窗口无法使用平铺窗口的移动快捷键
   - 解决：使用 `Alt+Shift+Space` 切换到平铺模式

2. **窗口被其他应用锁定**：
   - 某些全屏应用（如 Netflix）会锁定窗口
   - 解决：退出全屏模式

#### 问题 3：工作区切换不跟随

**症状**：切换工作区后焦点不跟随

**可能原因**：

1. **工作区没有窗口**：
   - 空工作区切换后会创建新工作区
   - 但焦点不会自动切换

2. **显示器绑定问题**：
   - 工作区绑定到特定显示器
   - 切换时焦点会到对应显示器

**解决方法**：
```bash
# 查看当前工作区
aerospace list-workspaces --monitor next

# 查看当前窗口
aerospace list-windows --workspace focused
```

#### 问题 4：应用自动分配不生效

**症状**：配置的自动分配规则不工作

**排查步骤**：

1. **检查应用 ID 是否正确**：
```bash
# 查看所有应用
aerospace list-apps

# 查看当前窗口的应用 ID
aerospace list-windows --focused
```

2. **检查配置文件语法**：
```bash
aerospace reload-config
```

3. **检查规则顺序**：
   - 规则从上到下匹配
   - 第一个匹配的规则生效
   - 更具体的规则应该放在前面

#### 问题 5：多显示器问题

**症状**：窗口不会出现在预期的显示器上

**排查步骤**：

1. **检查显示器绑定**：
```bash
# 查看显示器列表
aerospace list-monitors

# 查看工作区绑定
aerospace list-workspaces --all
```

2. **重新配置绑定**：
```toml
[workspace-to-monitor-force-assignment]
1 = 'main'       # 确保绑定正确
3 = 'secondary'
```

3. **手动移动窗口**：
```bash
# 使用快捷键
Alt+Shift+N  # 移动到下一个显示器

# 使用命令
aerospace move-node-to-monitor next
```

### 7.2 调试命令

#### 查看当前状态

```bash
# 查看所有工作区
aerospace list-workspaces --all

# 查看所有窗口
aerospace list-windows --all

# 查看所有应用
aerospace list-apps

# 查看所有模式
aerospace list-modes

# 查看当前模式
aerospace list-modes --current
```

#### 手动执行命令

```bash
# 切换工作区
aerospace workspace 1

# 移动窗口
aerospace move left

# 调整窗口大小
aerospace resize width +50

# 切换布局
aerospace layout h_tiles

# 全屏
aerospace fullscreen
```

#### 日志调试

```bash
# 查看 AeroSpace 日志
log stream --predicate 'process == "Aerospace"' --level debug
```

### 7.3 配置验证

#### 语法检查

```bash
# 重新加载配置（会自动检查语法）
aerospace reload-config
```

#### 测试配置

1. **测试模式切换**：
```bash
# 进入 resize 模式
aerospace mode resize

# 返回 main 模式
aerospace mode main
```

2. **测试工作区切换**：
```bash
# 切换到工作区 1
aerospace workspace 1

# 查看当前工作区
aerospace list-workspaces --focused
```

3. **测试布局切换**：
```bash
# 切换到水平平铺
aerospace layout h_tiles

# 切换到垂直平铺
aerospace layout v_tiles
```

---

## 8. 配置参考

### 8.1 配置文件位置

```
~/.config/aerospace/aerospace.toml
```

### 8.2 配置文件结构

```toml
# ============================================================
# AeroSpace 平铺窗口管理器配置
# ============================================================

# 1. 基础设置
start-at-login = true
accordion-padding = 0
default-root-container-layout = 'tiles'

# 2. SketchyBar 联动
after-startup-command = [...]
exec-on-workspace-change = [...]

# 3. 窗口间距
[gaps]
inner.horizontal = 2
inner.vertical = 2
outer.left = 1
outer.bottom = 1
outer.top = 30
outer.right = 1

# 4. 窗口规则
[[on-window-detected]]
if.app-id = 'com.example.App'
run = ['layout floating']

# 5. 工作区绑定
[workspace-to-monitor-force-assignment]
1 = 'main'
2 = 'secondary'

# 6. 快捷键绑定
[mode.main.binding]
alt-key = 'command'

[mode.resize.binding]
key = 'command'

[mode.move.binding]
key = 'command'

[mode.layout.binding]
key = 'command'

[mode.workspace.binding]
key = 'command'
```

### 8.3 常用配置选项

#### 基础设置

| 选项                            | 类型   | 说明                              |
| :-----------------------------: | :----: | :-------------------------------: |
| `start-at-login`                | bool   | 登录时自动启动                    |
| `accordion-padding`             | int    | 手风琴布局内边距（0 = 禁用）      |
| `default-root-container-layout` | str    | 默认根容器布局（tiles/accordion） |

#### 容器标准化

| 选项                                                              | 类型   | 说明                 |
| :---------------------------------------------------------------: | :----: | :------------------: |
| `enable-normalization-flatten-containers`                         | bool   | 扁平化嵌套容器       |
| `enable-normalization-opposite-orientation-for-nested-containers` | bool   | 嵌套容器使用相反方向 |

#### 窗口间距

| 选项                    | 类型   | 说明       |
| :---------------------: | :----: | :--------: |
| `gaps.inner.horizontal` | int    | 水平内边距 |
| `gaps.inner.vertical`   | int    | 垂直内边距 |
| `gaps.outer.left`       | int    | 左外边距   |
| `gaps.outer.right`      | int    | 右外边距   |
| `gaps.outer.top`        | int    | 上外边距   |
| `gaps.outer.bottom`     | int    | 下外边距   |

### 8.4 窗口规则语法

#### 基本语法

```toml
[[on-window-detected]]
if.app-id = 'com.example.App'
run = ['command1', 'command2', ...]
```

#### 可用命令

| 命令                        | 说明               | 示例                                  |
| :-------------------------: | :----------------: | :-----------------------------------: |
| `layout floating`           | 浮动布局           | `run = ['layout floating']`           |
| `layout tiling`             | 平铺布局           | `run = ['layout tiling']`             |
| `move-node-to-workspace X`  | 移动到工作区 X     | `run = ['move-node-to-workspace 1']`  |
| `move-node-to-monitor next` | 移动到下一个显示器 | `run = ['move-node-to-monitor next']` |

#### 多命令组合

```toml
# 组合多个命令
[[on-window-detected]]
if.app-id = 'com.example.App'
run = ['layout floating', 'move-node-to-workspace 4']

# 仅在启动时生效
[[on-window-detected]]
if.app-id = 'com.example.App'
if.during-aerospace-startup = true
run = ['move-node-to-workspace 1']
```

### 8.5 工作区绑定语法

#### 基本语法

```toml
[workspace-to-monitor-force-assignment]
1 = 'main'
2 = 'secondary'
3 = 'monitor-name'
```

#### 绑定方式

| 方式        | 说明                         | 示例                        |
| :---------: | :--------------------------: | :-------------------------: |
| 数字        | 按显示器顺序（1-based）      | `1 = 1`                     |
| `main`      | 主显示器                     | `1 = 'main'`                |
| `secondary` | 次显示器                     | `2 = 'secondary'`           |
| 字符串      | 按显示器名称（不区分大小写） | `3 = 'DELL U2720Q'`         |
| 正则表达式  | 正则匹配（不区分大小写）     | `4 = '^built-in.*'`         |
| 数组        | 多个模式（第一个匹配）       | `5 = ['secondary', 'dell']` |

### 8.6 快捷键绑定语法

#### 基本语法

```toml
[mode.main.binding]
alt-key = 'command'

# 组合命令
alt-key = ['command1', 'command2']
```

#### 修饰键

| 修饰键   | 说明         |
| :------: | :----------: |
| `alt`    | Alt 键       |
| `shift`  | Shift 键     |
| `ctrl`   | Ctrl 键      |
| `cmd`    | Cmd 键（⌘） |

#### 组合示例

```toml
# 单个命令
alt-q = 'close'

# 组合命令
alt-shift-1 = ['move-node-to-workspace 1', 'workspace 1']

# 模式切换
alt-r = 'mode resize'
```

### 8.7 模式定义语法

```toml
# 定义模式入口
[mode.main.binding]
alt-r = 'mode resize'

# 定义模式内容
[mode.resize.binding]
h = 'resize width -50'
l = 'resize width +50'
enter = 'mode main'
esc = 'mode main'
```

---

## 附录 A：命令行工具

### aerospace 呸令

#### 工作区相关

```bash
# 切换工作区
aerospace workspace <workspace>

# 列出工作区
aerospace list-workspaces [--all|--monitor <monitor>]
```

#### 窗口相关

```bash
# 移动窗口
aerospace move <direction>

# 调整窗口大小
aerospace resize <dimension> <amount>

# 切换布局
aerospace layout <layout-type>

# 关闭窗口
aerospace close
```

#### 模式相关

```bash
# 切换模式
aerospace mode <mode-id>

# 列出模式
aerospace list-modes [--current|--all]
```

#### 应用相关

```bash
# 列出所有应用
aerospace list-apps

# 列出窗口
aerospace list-windows [--workspace <workspace>|--all|--focused]
```

#### 配置相关

```bash
# 重新加载配置
aerospace reload-config

# 查看配置文件路径
aerospace config-path
```

---

## 附录 B：应用 ID 列表

### 常用应用 ID

| 应用            | App ID                        |
| :-------------: | :---------------------------: |
| Safari          | `com.apple.Safari`            |
| Chrome          | `com.google.Chrome`           |
| Arc             | `company.thebrowser.Browser`  |
| Firefox         | `org.mozilla.firefox`         |
| Emacs           | `org.gnu.Emacs`               |
| iTerm2          | `com.googlecode.iterm2`       |
| Terminal        | `com.apple.Terminal`          |
| Finder          | `com.apple.finder`            |
| Mail            | `com.apple.mail`              |
| Notes           | `com.apple.Notes`             |
| Calendar        | `com.apple.iCal`              |
| System Settings | `com.apple.systempreferences` |
| WeChat          | `com.tencent.xinWeChat`       |
| Tencent Meeting | `com.tencent.meeting`         |
| DingTalk        | `com.alibaba.DingTalkMac`     |
| Feishu          | `com.electron.lark`           |
| VS Code         | `com.microsoft.VSCode`        |
| JetBrains IDEs  | `com.jetbrains.*`             |

### 查找应用 ID

```bash
# 方法 1：使用 osascript
osascript -e 'id of app "应用名称"'

# 方法 2：使用 AeroSpace
aerospace list-apps

# 方法 3：查找运行中的窗口
aerospace list-windows --all | grep "应用名称"
```

---

## 附录 C：资源链接

### 官方资源

- **GitHub 仓库**：https://github.com/nikitabobko/aerospace
- **官方文档**：https://nikitabobko.github.io/AeroSpace/guide
- **发布页面**：https://github.com/nikitabobko/aerospace/releases

### 社区资源

- **Reddit 社区**：https://reddit.com/r/AeroSpaceWM
- **Discord 服务器**：https://discord.gg/aerospace
- **配置分享**：https://github.com/topics/aerospace-config

### 相关工具

- **SketchyBar**：https://github.com/FelixKratz/SketchyBar
- **Rectangle**：https://rectangleapp.com
- **Karabiner-Elements**：https://karabiner-elements.pqrs.org

---

## 附录 D：版本历史

### v1.4.0 (2026-03-09)
- ✨ 添加 Move 模式，支持单键移动窗口
- ✨ 添加 Layout 模式，支持快速切换布局
- ✨ 添加 Workspace 模式，支持工作区管理
- 📝 完善配置文件注释
- 📖 创建使用说明书

### v1.3.0 (2026-03-09)
- ✨ 添加 Resize 模式，支持单键调整窗口大小
- 🎨 优化模式系统设计

### v1.2.1 (2026-03-08)
- 🐛 修复 Alt+4 快捷键行为不一致
- 🔧 统一窗口规则格式为数组

### v1.2.0 (2026-03-04)
- 📝 优化注释，添加版本历史
- ✨ 添加作者信息

### v1.1.0 (2025-03-04)
- 🐛 修复鼠须管焦点丢失问题
- ✨ 增加移动窗口焦点跟随

### v1.0.0 (2025-03-04)
- 🎉 初始配置
- ✨ 基础平铺和快捷键设置

---

## 联系方式

- **作者**：Hao Feng (F1)
- **配置位置**：`~/.config/aerospace/aerospace.toml`
- **使用说明书**：`~/.config/aerospace/USER_GUIDE.md`

---

**祝你使用愉快！高效工作，快乐生活！** 🚀
