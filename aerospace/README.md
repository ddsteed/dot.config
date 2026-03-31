# AeroSpace 配置

> **版本**: 1.5.0
> **作者**: Hao Feng (F1)

## 快速开始

### 模式入口

| 快捷键                 | 模式                  | 用途                  |
| :-----------------: | :-----------------: | :-----------------: |
| `Alt+R`             | Resize              | 调整窗口大小              |
| `Alt+M`             | Move                | 移动窗口位置              |
| `Alt+T`             | Layout              | 切换窗口布局              |
| `Alt+W`             | Workspace           | 管理工作区               |

### 常用快捷键

| 快捷键                     | 功能                            |
| :---------------------: | :---------------------------: |
| `Cmd+Shift+H/J/K/L`     | 移动焦点（左/下/上/右）                 |
| `Ctrl+Alt+H/J/K/L`      | 移动窗口                          |
| `Alt+Shift+H/J/K/L`     | 调整窗口大小                        |
| `Alt+1~8`               | 切换工作区                         |
| `Alt+Q`                 | 关闭窗口                          |
| `Alt+Shift+C`           | 重新加载配置                        |

## 文档

- **详细使用说明书**: [USER_GUIDE.md](USER_GUIDE.md)
- **配置文件**: [aerospace 配置](aerospace toml)

## 工作区规划

```
主显示器          次显示器
├─ 工作区 1        ├─ 工作区 3
│  Safari          │  Emacs
│                  │  Calibre
├─ 工作区 2        ├─ 工作区 4
│  Chrome/Arc      │  iTerm2
│                  │  开发工具
├─ 工作区 5-8      ├─ 工作区 5-8
│  临时工作区           │  临时工作区
```

## 模式说明

### Resize 模式 (`Alt+R`)

```
H/L      减小/增加宽度
J/K      增加/减小高度
Shift+H/L/J/K  精细调整（10px）
Enter/Esc  退出
```

### Move 模式 (`Alt+M`)

```
H/J/K/L  向左/下/上/右移动窗口
1-8      移动到工作区并跟随
N/P      移动到下一个/上一个显示器
Enter/Esc  退出
```

### Layout 模式 (`Alt+T`)

```
H/V      水平/垂直平铺
A        通用手风琴
B        水平手风琴（标签页）
S        垂直手风琴（堆叠）
F/G      浮动/平铺布局
Space    全屏
Esc      退出
```

### Workspace 模式 (`Alt+W`)

```
1-8      切换到工作区
H/L      上一个/下一个工作区
N/P      下一个/上一个显示器
Shift+1-8  移动窗口（不跟随）
Enter/Esc  退出
```

## 配置重载

修改配置后按 `Alt+Shift+C` 重新加载，或运行：

```bash
aerospace reload-config
```

## 获取应用 ID

```bash
# 查看所有应用
aerospace list-apps

# 查看当前窗口
aerospace list-windows --focused
```

## 相关资源

- [AeroSpace GitHub](https://github.com/nikitabobko/aerospace)
- [AeroSpace 官方文档](https://nikitabobko.github.io/AeroSpace/guide)
- [SketchyBar](https://github.com/FelixKratz/SketchyBar)
