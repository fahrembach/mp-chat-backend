# M-P Chat - 构建说明

## 快速开始

### 1. 启动后端服务器
在项目根目录运行：
```bash
npm run dev
```

### 2. 构建前端应用
进入 `flutter_app` 目录并运行构建脚本：
```bash
cd flutter_app
build.bat
```

## 构建选项

### 📱 Android
- **APK**: 适用于测试和直接安装
- **AAB**: 适用于发布到Google Play Store

### 💻 Windows
- 桌面应用程序，需要Windows平台支持

### 🌐 Web
- Web应用程序，可以在浏览器中运行

## 平台配置

如果遇到平台不支持的问题，请运行以下命令：

### 启用所有平台支持
```bash
flutter config --enable-web
flutter config --enable-windows-desktop
flutter config --enable-android

flutter create . --platforms web,windows
```

### 验证平台配置
```bash
check_platforms.bat
```

## 常见问题解决

### Android构建失败
1. 确保AndroidManifest.xml包含flutterEmbedding v2
2. 运行 `flutter doctor --android-licenses`
3. 检查Android SDK路径设置

### Windows构建失败
1. 运行 `flutter config --enable-windows-desktop`
2. 运行 `flutter create . --platforms windows`
3. 确保安装了Visual Studio Build Tools

### Web构建失败
1. 运行 `flutter config --enable-web`
2. 运行 `flutter create . --platforms web`

## 项目结构

```
flutter_app/
├── build.bat              # 主构建脚本
├── check_platforms.bat    # 平台检查脚本
├── android/               # Android平台代码
├── web/                   # Web平台代码（如果启用）
├── windows/               # Windows平台代码（如果启用）
└── lib/                   # Dart源代码
```

## 输出文件位置

- **APK**: `build/app/outputs/flutter-apk/app-release.apk`
- **AAB**: `build/app/outputs/bundle/release/app-release.aab`
- **Windows**: `build/windows/x64/runner/Release/`
- **Web**: `build/web/`