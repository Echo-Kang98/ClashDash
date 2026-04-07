# 🚀 ClashDash

<div align="center">

![ClashDash](https://img.shields.io/badge/ClashDash-v1.0.0-00D9FF?style=for-the-badge&logo=flutte)
![Flutter](https://img.shields.io/badge/Flutter-3.5.0-blue?style=for-the-badge&logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**你的私人 Clash 配置管理器**

*一款现代化、优雅的 Flutter 应用，用于管理 Clash 代理订阅和节点。*

</div>

---

## ✨ 功能特性

| 功能 | 描述 |
|------|------|
| 🌐 **订阅管理** | 添加、同步和管理多个 Clash 订阅源 |
| 📂 **节点列表** | 查看所有节点，支持搜索、筛选和延迟显示 |
| ⭐ **收藏夹** | 收藏常用节点，快速访问 |
| ⚡ **节点测速** | 测试节点延迟，找到最快的节点 |
| 🎯 **规则配置** | 可视化代理规则编辑器，支持分类 |
| 📤 **配置导出** | 一键导出 Clash YAML 格式配置 |
| 🌓 **深色主题** | 精美的赛博朋克风格深色 UI |
| 💾 **本地存储** | 基于 Hive 的持久化存储 |

---

## 📱 界面预览

```
┌─────────────────────────────────────┐
│  🚀 ClashDash                   ⚙️  │
├─────────────────────────────────────┤
│                                     │
│           ╭─────────────╮           │
│           │             │           │
│           │    ◯◯◯     │           │
│           │             │           │
│           ╰─────────────╯           │
│            点击连接                  │
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 📡 当前节点                  │   │
│  │ 🇺🇸 US-West-01              │   │
│  │ Vmess · 23ms          [断开]│   │
│  └─────────────────────────────┘   │
│                                     │
│   [首页]  [订阅]  [节点]  [规则]    │
└─────────────────────────────────────┘
```

---

## 🛠️ 技术栈

| 层级 | 技术 |
|------|------|
| **框架** | Flutter 3.5+ |
| **状态管理** | Riverpod |
| **本地存储** | Hive |
| **网络请求** | http |
| **YAML 解析** | yaml |
| **架构** | Clean Architecture |

---

## 🚀 快速开始

### 环境要求

- Flutter SDK 3.5 或更高版本
- Android Studio / Xcode
- Git

### 安装步骤

```bash
# 克隆仓库
git clone https://github.com/Echo-Kang98/ClashDash.git

# 进入项目目录
cd ClashDash

# 安装依赖
flutter pub get

# 运行应用
flutter run
```

### 构建发布版本

使用 `scripts/` 目录下的构建脚本：

| 平台 | 脚本 | 输出 |
|------|------|------|
| **Android** | `./scripts/build_android.sh` | APK + AAB |
| **iOS** | `./scripts/build_ios.sh` | IPA（仅 macOS） |
| **macOS** | `./scripts/build_all.sh` | App bundle（仅 macOS） |
| **Linux** | `./scripts/build_linux.sh` | 可执行文件 |
| **Windows** | `./scripts/build_windows.bat` | EXE |
| **全部平台** | `./scripts/build_all.sh` | 所有平台 |

或直接使用 Flutter 命令：

```bash
# Android APK
flutter build apk --release

# Android App Bundle (用于 Google Play)
flutter build appbundle --release

# iOS（仅 macOS）
flutter build ios --release

# macOS（仅 macOS）
flutter build macos --release

# Linux
flutter build linux --release

# Windows
flutter build windows --release
```

### 📦 构建产物位置

| 平台 | 文件位置 |
|------|----------|
| Android APK | `build/app/outputs/flutter-apk/app-release.apk` |
| Android AAB | `build/app/outputs/bundle/release/app-release.aab` |
| iOS | `build/ios/iphoneos/Runner.ipa` |
| macOS | `build/macos/Build/Products/Release/ClashDash.app` |
| Linux | `build/linux/release/bundle/clashdash` |
| Windows | `build/windows/runner/Release/ClashDash.exe` |

---

## 📖 使用教程

### 1. 添加订阅

1. 进入 **订阅** 标签页
2. 点击 **+** 按钮
3. 输入订阅名称和地址
4. 点击 **保存**

### 2. 同步节点

1. 在订阅列表中，点击 **同步** 按钮
2. 等待节点导入完成
3. 进入 **节点** 标签页查看所有节点

### 3. 选择节点

1. 进入 **节点** 标签页
2. 使用搜索或筛选功能
3. 点击节点即可选中
4. 返回 **首页** 查看已选节点

### 4. 节点测速

1. 在 **节点** 标签页，点击 **测速全部**
2. 等待所有节点测试完成
3. 节点按延迟自动排序

### 5. 配置规则

1. 进入 **规则** 标签页
2. 选择模式：规则模式 / 全局 / 直连
3. 在各分类中添加或修改规则
4. 点击 **导出配置** 复制 Clash YAML

### 6. 导入 Clash

1. 复制导出的 YAML 配置
2. 打开你的 Clash 客户端（ClashX、Clash for Windows、Shadowrocket）
3. 导入配置
4. 选择节点并连接

---

## 📁 项目结构

```
lib/
├── main.dart                     # 应用入口
├── providers.dart                # 全局状态管理
├── core/
│   ├── constants/                # 常量定义
│   ├── theme/                    # 深色主题
│   └── services/                 # 业务服务
│       ├── subscription_service.dart
│       ├── speed_test_service.dart
│       └── config_exporter_service.dart
└── features/
    ├── main/screens/             # 主导航壳
    ├── home/presentation/        # 首页
    ├── subscription/             # 订阅管理
    ├── node/                     # 节点列表
    ├── rule/                     # 规则配置
    └── settings/                 # 应用设置
```

---

## 🔧 支持的协议

- ✅ VMess
- ✅ Shadowsocks (SS)
- ✅ Trojan
- ⏳ VLESS (即将支持)

---

## 🎨 主题颜色

| 颜色 | 十六进制 | 用途 |
|------|----------|------|
| 主色 | `#00D9FF` | 强调色、按钮、高亮 |
| 背景 | `#0F0F1A` | 应用背景 |
| 卡片 | `#1A1A2E` | 卡片背景 |
| 成功 | `#00FF88` | 在线、低延迟 |
| 警告 | `#FFB800` | 中等延迟 |
| 错误 | `#FF4757` | 高延迟、错误 |

---

## ⚠️ 免责声明

ClashDash 只是一个**配置管理工具**，它不：

- 🚫 提供 VPN/代理服务
- 🚫 处理实际的网络连接
- 🚫 在任何服务器上存储您的订阅凭据

本应用帮助您在本地管理 Clash 配置。您需要自己准备 Clash 客户端和订阅服务。

---

## 📄 开源协议

本项目基于 MIT 协议开源 - 详见 [LICENSE](LICENSE) 文件。

---

## 🤝 贡献代码

欢迎提交 Issue 和 Pull Request！

1. Fork 本项目
2. 创建您的功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交您的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

---

## 📬 联系方式

- **GitHub**: [Echo-Kang98](https://github.com/Echo-Kang98)
- **项目地址**: [https://github.com/Echo-Kang98/ClashDash](https://github.com/Echo-Kang98/ClashDash)

---

<div align="center">

**由 ❤️ Echo-Kang98 制作**

</div>
