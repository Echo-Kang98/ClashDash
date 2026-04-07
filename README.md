# 🚀 ClashDash

<div align="center">

![ClashDash](https://img.shields.io/badge/ClashDash-v1.0.0-00D9FF?style=for-the-badge&logo=flutte)
![Flutter](https://img.shields.io/badge/Flutter-3.5.0-blue?style=for-the-badge&logo=flutter)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

**Your personal Clash configuration manager**

*A modern, elegant Flutter app for managing Clash proxy subscriptions and nodes.*

[English](README.md) | [中文](README_CN.md)

</div>

---

## ✨ Features

| Feature | Description |
|---------|-------------|
| 🌐 **Subscription Management** | Add, sync and manage multiple Clash subscriptions |
| 📂 **Node List** | View all nodes with search, filter, and latency display |
| ⭐ **Favorites** | Star your favorite nodes for quick access |
| ⚡ **Speed Test** | Test node latency and find the fastest one |
| 🎯 **Rule Configuration** | Visual proxy rules editor with categories |
| 📤 **Config Export** | One-click export to Clash YAML format |
| 🌓 **Dark Theme** | Beautiful cyberpunk-style dark UI |
| 💾 **Local Storage** | Hive-based persistent storage |

---

## 📱 Screenshots

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

## 🛠️ Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter 3.5+ |
| **State Management** | Riverpod |
| **Local Storage** | Hive |
| **HTTP Client** | http |
| **YAML Parser** | yaml |
| **Architecture** | Clean Architecture |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.5 or higher
- Android Studio / Xcode
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/Echo-Kang98/ClashDash.git

# Navigate to project directory
cd ClashDash

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

---

## 📖 Usage

### 1. Add Subscription

1. Go to **Subscriptions** tab
2. Tap the **+** button
3. Enter subscription name and URL
4. Tap **Save**

### 2. Sync Nodes

1. In subscription list, tap **Sync** button
2. Wait for nodes to be imported
3. Go to **Nodes** tab to view all nodes

### 3. Select Node

1. Go to **Nodes** tab
2. Search or filter nodes
3. Tap a node to select it
4. Return to **Home** to see the selected node

### 4. Speed Test

1. In **Nodes** tab, tap **Speed Test**
2. Wait for all nodes to be tested
3. Nodes are sorted by latency

### 5. Configure Rules

1. Go to **Rules** tab
2. Choose mode: Rule / Global / Direct
3. Add or modify rules in each category
4. Tap **Export Config** to copy Clash YAML

### 6. Import to Clash

1. Copy the exported YAML config
2. Open your Clash client (ClashX, Clash for Windows, Shadowrocket)
3. Import the configuration
4. Select node and connect

---

## 📁 Project Structure

```
lib/
├── main.dart                     # App entry point
├── providers.dart                # Global state management
├── core/
│   ├── constants/                # App constants
│   ├── theme/                    # Dark theme
│   └── services/                 # Business services
│       ├── subscription_service.dart
│       ├── speed_test_service.dart
│       └── config_exporter_service.dart
└── features/
    ├── main/screens/             # Main navigation shell
    ├── home/presentation/        # Home screen
    ├── subscription/             # Subscription management
    ├── node/                     # Node list & management
    ├── rule/                     # Rules configuration
    └── settings/                 # App settings
```

---

## 🔧 Supported Protocols

- ✅ VMess
- ✅ Shadowsocks (SS)
- ✅ Trojan
- ⏳ VLESS (coming soon)

---

## 🎨 Theme Colors

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | `#00D9FF` | Accent, buttons, highlights |
| Background | `#0F0F1A` | App background |
| Card | `#1A1A2E` | Card backgrounds |
| Success | `#00FF88` | Online, low latency |
| Warning | `#FFB800` | Medium latency |
| Error | `#FF4757` | High latency, errors |

---

## ⚠️ Disclaimer

ClashDash is a **configuration management tool** only. It does not:

- 🚫 Provide VPN/proxy services
- 🚫 Handle actual network connections
- 🚫 Store your subscription credentials on any server

This app helps you manage your Clash configurations locally. You need your own Clash client and subscription services.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Contributions are welcome! Feel free to submit issues and pull requests.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📬 Contact

- **GitHub**: [Echo-Kang98](https://github.com/Echo-Kang98)
- **Project Link**: [https://github.com/Echo-Kang98/ClashDash](https://github.com/Echo-Kang98/ClashDash)

---

<div align="center">

**Made with ❤️ by Echo-Kang98**

</div>
