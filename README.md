# 有声听书

一个 Flutter 实现的移动端听书 App。项目面向已经无人维护、无法提供正式 API 的听书站点，通过请求原始网页并解析关键 DOM / 页面脚本数据，渲染首页、推荐列表、搜索、书籍详情和播放页。

当前站点源为：

- 移动站：https://m.ting13.cc
- 桌面站：https://www.ting13.cc

## 功能

- 首页推荐与轮播内容解析
- 书籍搜索
- 书籍详情、简介、章节列表、相关推荐
- 播放页音频地址解析
- 播放、暂停、进度拖动、快进快退
- 倍速播放
- 后台播放与媒体通知
- Cookie 持久化与站点 challenge 处理

## 技术栈

- Flutter / Dart
- Dio：网络请求
- html：网页 DOM 解析
- shared_preferences：Cookie 持久化
- just_audio：音频播放
- just_audio_background：后台播放通知
- audio_session：音频会话配置

## 站点解析说明

本项目没有依赖官方 API。核心数据来自站点 HTML 与页面脚本：

- 首页从 `.focusBox`、`.list-li`、`.module-slide-li` 等结构提取推荐内容。
- 详情页从 `.book`、`.book-rand-a`、`.book-des#play`、`.play-list` 等结构提取书籍信息和章节。
- 搜索优先请求 `/api/ajax/solist`，失败时回退到 `/novelsearch/search/result.html` 表单页解析。
- 播放页从 meta 参数 `_b`、`_p`、`_c`、`_d` 构造请求，调用 `/api/key/readplay`，仅当返回 `status == 200` 时使用 `audioUrl` 作为真实音频地址。

由于目标站点不是公开 API，页面结构变更可能导致解析失效。维护时应优先使用真实浏览器确认当前 DOM 和播放接口行为。

## 开发

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Android 打包

本地已配置 release 签名，签名文件默认放在：

```text
android/app/keystore/audiobook-release.jks
```

`android/key.properties` 示例：

```properties
storePassword=<your-store-password>
keyPassword=<your-key-password>
keyAlias=audiobook_release
storeFile=keystore/audiobook-release.jks
```

构建：

```bash
flutter build apk --release
flutter build appbundle --release
```

产物：

```text
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

## Release Keystore 信息

当前本地 release keystore 信息：

```text
文件位置：D:\workspace\audio_book\android\app\keystore\audiobook-release.jks
alias：audiobook_release
SHA256：13:C5:92:5F:2C:AC:AA:C4:FF:72:C9:CD:B9:F8:E8:EA:8B:81:86:EA:9F:C4:F3:0C:B9:62:99:AC:DD:38:E9:CE
```

安全说明：

- `android/key.properties` 和 `*.jks` 已被 `.gitignore` 忽略。
- release keystore 和密码用于证明应用更新身份，不建议提交到公开仓库。
- 如果需要完全公开可复现签名，请单独生成 public/demo keystore，不要使用真实发布签名。

## iOS 打包

iOS 已配置应用名称、图标、后台音频和网络访问配置。实际打包仍需要在 macOS + Xcode 中配置：

- Apple Developer Team
- Signing Certificate
- Provisioning Profile

## 图标

当前使用临时生成的耳机 + 书本 + 播放符号图标，源图位于：

```text
assets/branding/app_icon.png
```

后续正式发布建议替换为设计稿。

## 开源说明

项目代码可以开源学习和二次开发。由于本项目通过解析第三方网页实现功能，请自行确认目标站点内容版权、使用条款以及分发合规性。
