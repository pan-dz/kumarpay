# Flutter MVVM 

在Flutter中实现MVVM(Model-View-ViewModel)架构。

## 🚀 开始使用

### 前置要求

- Flutter SDK (>=3.10.1)
- Dart SDK (>=3.0.0)

### 安装步骤

1. 安装依赖
```bash
flutter pub get
```

1. 运行应用
```bash
flutter run
```

### 测试

运行测试:
```bash
flutter test
```

### 🚀 执行打包脚本
0. Shorebird Android 打包（推荐）
```bash
# 首次使用赋权
chmod +x scripts/build_shorebird_android.sh
chmod +x scripts/patch_shorebird_android.sh
chmod +x scripts/release_and_patch_shorebird_android.sh

# 安装脚手架
curl --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/shorebirdtech/install/main/install.sh | bash

# 登陆账号(节点需要是 日本的)
shorebird login
shorebird logout

# sit APK（兼容：默认 arm + arm64）
./scripts/build_shorebird_android.sh --name KumarPay-Test-2603201340 --version 1.0.46 --build 84 --env sit --artifact apk --output-dir build/apk

# prod APK（快速：仅 arm64，可选）
./scripts/build_shorebird_android.sh --name KumarPay-Test-2603201340 --version 1.0.39 --build 74 --env prod --artifact apk --fast-arm64 --skip-icons --output-dir build/apk

# sit AAB（会创建/更新 Shorebird release）
./scripts/build_shorebird_android.sh --name KumarPay-Test-2603201340 --tag --build 74 --env sit --artifact aab --output-dir build/aab

# 仅校验不上传
./scripts/build_shorebird_android.sh --version 1.0.39 --build 74 --env prod --artifact apk --dry-run

# ===== Shorebird Patch（热更新补丁，不重新发完整包） =====
# 默认会先自动检查目标 release 是否存在（get-apks，失败时自动 fallback 到 patch --dry-run），再执行 patch
./scripts/patch_shorebird_android.sh --env sit --release-version 1.0.39-test+74

# 仅校验不上传
./scripts/patch_shorebird_android.sh --env sit --release-version 1.0.39-test+74 --dry-run

# 预检查失败时输出 Shorebird 原始错误
./scripts/patch_shorebird_android.sh --env sit --release-version 1.0.39-test+74 --verbose

# 可选：跳过预检查（不推荐）
./scripts/patch_shorebird_android.sh --env sit --release-version 1.0.39-test+74 --skip-release-check


```

1. 测试环境
```bash
# 普通打包（体积大、兼容性强，产出一个包）
./scripts/build_apk_simple.sh --name KumarPay-Test-2603201640 --version 1.0.45 --build 81 --env sit --output-dir build/apk

# abi分包打包（体积小、兼容性弱，产出多个包）
./scripts/build_apk.sh --name KumarPay-Test-2603201640 --version 1.0.45 --build 81 --env sit --output-dir build/apk

# aab打包
./scripts/build_aab_simple.sh --name KumarPay-Test-2603201640 --version 1.0.45 --build 81 --env sit --output-dir build/aab


# web打包（--name 时不保留 build/web）
./scripts/build_web.sh --name kumarpay-h5 --env sit --output-dir build/web-dist

```

2. 生产环境
```bash
# 普通打包（体积大、兼容性强，产出一个包）
./scripts/build_apk_simple.sh --name KumarPay-Test-2602090810 --version 1.0.2 --build 45 --env prod --output-dir build/apk

./scripts/build_apk_simple.sh --name KumarPay-Test-2602090810 --tag --build 45 --env prod --output-dir build/apk

# 单 ABI APK（体积更小，仅 arm64 设备）
./scripts/build_apk_simple.sh --name KumarPay-Test-2602090810 --version 1.0.2 --build 45 --env prod --target-platform android-arm64 --output-dir build/apk

# abi分包打包（体积小、兼容性弱，产出多个包）
./scripts/build_apk.sh --name KumarPay-Test-2602090810 --tag --build 45 --env prod --output-dir build/apk

# aab打包
./scripts/build_aab_simple.sh --name KumarPay-Test-2602090810 --tag --build 45 --env prod --output-dir build/aab

# web打包（--name 时不保留 build/web）
./scripts/build_web.sh --name kumarpay-h5-prod --env prod --output-dir build/web-dist

```

3. Web（PWA + 压缩）
```bash
# 默认：PWA offline-first + 压缩（gzip/brotli）
./scripts/build_web.sh --env prod --output-dir build/web

# 自定义输出目录名称（生成到 build/web-dist/<name>，并清理 build/web）
./scripts/build_web.sh --env prod --name KumarPay-2602011330

# 测试环境 + 关闭压缩
./scripts/build_web.sh --env sit --no-compress

# 关闭 PWA
./scripts/build_web.sh --env prod --pwa-strategy none

# 可选：WASM（实验特性）
./scripts/build_web.sh --env prod --wasm
```


### 🧪 项目工程打包
1. 普通打包
```
flutter build apk --release
```

2. CPU架构拆封打包
```
# 构建单个架构的发布版APK (例如 arm64)
flutter build apk --release --split-per-abi

# 分割ABI后的选择：运行 --split-per-abi 后，会生成三个APK（armeabi-v7a， arm64-v8a，x86_64）
1. 'armeabi-v7a' // 兼容旧设备
2. 'arm64-v8a' // 主流新设备


三种架构的区别
架构	          支持设备	                          性能特点
arm64-v8a	     2014年后的64位Android设备	          64位ARM架构，现代主流
armeabi-v7a	   较旧的32位ARM设备	                  32位ARM架构，兼容旧设备
x86_64	       Intel/AMD CPU的Android设备	x86      64位架构，主要用于模拟器或特殊设备



```

2.1 自定义APK名称和版本号（脚本）
```
# 首次使用需要赋权
chmod +x scripts/build_apk.sh

# 构建并自定义输出名称（分包构建）
./scripts/build_apk.sh --name KumarPay-2601301640 --version 1.0.0 --build 45 --env sit --output-dir build/apk

# 构建并自定义输出名称（普通构建）
./scripts/build_apk_simple.sh --name KumarPay-2601301640 --version 1.0.5 --build 45 --env sit --output-dir build/apk

# 或使用 Git tag 作为版本号
# 示例：tag 为 v1.0.0，则版本号为 1.0.0
./scripts/build_apk.sh --name KumarPay-prod-2601291645 --tag --build 45 --env prod --output-dir build/apk

# 输出示例：
# build/apk/KumarPay-test-2601281640-v8a.apk
# build/apk/KumarPay-test-2601281640-v7a.apk
# build/apk/KumarPay-test-2601281640-x86_64.apk
```

3. 项目体积分析
```
flutter build apk --target-platform android-arm64 --analyze-size
```

4. Google Play打包（使用App Bundle格式：Play商店会按用户设备动态分发最小文件）
```
# 或构建App Bundle（用于Play商店）
flutter build appbundle --release

# 使用脚本（带符号分离/混淆/图标裁剪）
./scripts/build_aab_simple.sh --name KumarPay-Test-2601311000 --version 1.0.5 --build 45 --env sit --output-dir build/aab
./scripts/build_aab_simple.sh --name KumarPay-2602011330 --tag --build 45 --env prod --output-dir build/aab
```

5. H5 打包（Web）
```
# 生产包（默认输出到 build/web）
flutter build web --release

# 推荐：剔除未使用图标字体 + 关闭 SourceMap
flutter build web --release --tree-shake-icons --no-source-maps

# 可选：使用 WebAssembly（实验特性）
flutter build web --release --tree-shake-icons --no-source-maps --wasm
```

6. Web 体积优化建议
```
# 1) 提升压缩优化等级
flutter build web --release -O4 --tree-shake-icons --no-source-maps

# 2) 需要 PWA 时使用 offline-first，否则可关闭
flutter build web --release --pwa-strategy=offline-first --tree-shake-icons --no-source-maps
```

优化清单（无需改代码即可落地）：
- 仅保留实际使用的字体与图标，删除未用字体文件。
- 压缩静态图片资源（png/jpg/svg）。
- 清理无用资源与依赖（pubspec.yaml 里未使用的 assets / packages）。
- 使用 `--tree-shake-icons` 去除未使用的 Material Icons。

进一步优化（需要调整代码/资源）：
- 识别大文件：优先检查 build/web/assets 下的体积最大资源（图片/字体/视频）。
- 图片改用 WebP/AVIF（如业务允许），并降低分辨率与质量。
- 图标改用 SVG 或 IconFont（并保持 tree-shake）。
- 代码分包：对非首屏页面使用 deferred imports，减少主包 JS 体积。
- 网络资源走 CDN（大图/视频），避免打入包体。
- 删除不必要的多语言、字体变体（如粗细过多）。

代码分包（deferred imports）示例：
```dart
// 1) 延迟导入（非首屏页面）
import 'package:flutter/material.dart';
import 'package:your_app/presentation/pages/profile_page.dart' deferred as profile;

// 2) 跳转前加载模块
Future<void> openProfile(BuildContext context) async {
  await profile.loadLibrary();
  if (!context.mounted) return;
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => profile.ProfilePage()),
  );
}
```

注意：Flutter 3.38+ 已移除 `--web-renderer` 选项，以上命令已兼容最新版本。


## 📋 目录

- [架构概述](#架构概述)
- [项目结构](#项目结构)
- [核心概念](#核心概念)
- [技术栈](#技术栈)
- [开始使用](#开始使用)
- [功能特性](#功能特性)

## 🏗️ 架构概述

本项目采用Clean Architecture和MVVM模式的结合，实现了清晰的分层架构和关注点分离。

### Clean Architecture原则

Clean Architecture是一种软件设计哲学，通过将软件组织成层次结构来实现关注点分离：

1. **独立性** - 各层相互独立，可以独立开发和测试
2. **依赖反转** - 内层不依赖外层，外层依赖内层
3. **可测试性** - 业务逻辑与UI框架分离，便于单元测试
4. **可维护性** - 修改一层不会影响其他层

### MVVM模式

MVVM(Model-View-ViewModel)是一种UI架构模式：

- **Model** - 数据和业务逻辑
- **View** - UI界面，负责展示数据
- **ViewModel** - 连接Model和View的桥梁，处理UI逻辑

## 📁 项目结构

```
lib/
├── app/                    # 应用程序配置和路由
│   ├── config/            # API配置
│   └── router/            # 路由配置

├── core/                  # 核心功能
│   ├── di/               # 依赖注入
│   ├── error/            # 错误处理
│   └── network/          # 网络配置

├── data/                  # 数据层
│   ├── datasources/      # 数据源
│   ├── models/           # 数据模型
│   └── repositories/     # 仓库实现

├── domain/                # 领域层
│   ├── entities/         # 实体
│   ├── repositories/     # 仓库接口
│   └── usecases/         # 用例

└── presentation/          # 表现层
    ├── pages/            # 页面
    ├── viewmodels/       # 视图模型
    └── widgets/          # 公共UI组件
```

## 🧩 核心概念

### 1. 领域层 (Domain Layer)

领域层是架构的核心，包含业务规则和实体：

- **实体(Entities)**: 代表业务对象，如User
- **仓库接口(Repository Interfaces)**: 定义数据访问契约
- **用例(Use Cases)**: 封装特定业务规则

```dart
// 实体示例
class User {
  final int id;
  final String name;
  final String email;
  // ...
}

// 仓库接口示例
abstract class UserRepository {
  Future<List<User>> getUserInfo();
}

// 用例示例
class GetUserInfo {
  final UserRepository userRepository;
  
  GetUserInfo(this.userRepository);
  
  Future<List<User>> call() async {
    return userRepository.getUserInfo();
  }
}
```

### 2. 数据层 (Data Layer)

数据层负责从各种数据源获取数据：

- **数据源(Data Sources)**: 实现具体的数据获取逻辑
- **数据模型(Data Models)**: 用于数据传输和序列化
- **仓库实现(Repository Implementations)**: 实现领域层定义的接口

```dart
// 数据源示例
class UserRemoteDataSource {
  final DioClient dioClient;
  
  UserRemoteDataSource(this.dioClient);
  
  Future<List<UserModel>> getUsers() async {
    final response = await dioClient.get(Api.user);
    return (response.data as List).map((e) => UserModel.fromJson(e)).toList();
  }
}

// 仓库实现示例
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  
  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  
  @override
  Future<List<User>> getUserInfo() async {
    try {
      return await remoteDataSource.getUsers();
    } catch (e) {
      return localDataSource.getUsers();
    }
  }
}
```

### 3. 表现层 (Presentation Layer)

表现层负责UI展示和用户交互：

- **页面(Pages)**: UI界面
- **视图模型(ViewModels)**: 处理UI状态和用户交互
- **公共UI组件(Common Widgets)**: 可复用的UI组件，确保整个应用的UI一致性

```dart
// 视图模型示例
class UserViewModel extends StateNotifier<UserState> {
  final GetUserInfo getUserInfo;
  
  UserViewModel(this.getUserInfo) : super(UserState.initial());
  
  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final users = await getUserInfo();
      state = state.copyWith(users: users, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
```

### 4. 公共UI组件 (Common UI Components)

为了保持整个应用的UI风格一致性，我们抽取了以下公共组件：

- **AppPageScaffold**: 统一的页面框架，包含AppBar和下拉刷新功能
- **PageStateWidget**: 处理加载、错误和空数据状态的统一显示
- **ListItemCard**: 统一的列表项卡片样式
- **AvatarWidget**: 统一的头像显示组件
- **InfoItemWidget**: 带图标的信息项显示组件
- **StatItemWidget**: 统计数据项显示组件
- **ActionItemWidget**: 可点击操作项组件

这些组件确保了整个应用程序的UI风格一致性，提高了代码的可维护性和复用性。

## 🛠 技术栈

- **Flutter** - 跨平台UI框架
- **Riverpod** - 状态管理和依赖注入
- **Dio** - HTTP客户端
- **JSON Serialization** - 数据序列化/反序列化

## ✨ 功能特性

- [x] 清晰的分层架构
- [x] MVVM模式实现
- [x] 依赖注入
- [x] 错误处理
- [x] 状态管理
- [x] 网络请求
- [x] 数据回退机制
- [x] 统一的UI组件库
- [x] 响应式UI设计

## 🍞 Toast 主题（Flushbar）

项目内提供统一的 `AppToast` 封装，基于 `another_flushbar`，支持可主题化的提示：

使用示例：

```dart
// 基础用法
AppToast.success(context, '保存成功');
AppToast.error(context, '保存失败', actionText: '重试', onAction: retry);

// 统一 show API + 自定义主题
AppToast.show(
  context,
  message: '同步完成',
  type: AppToastType.info,
  theme: const AppToastTheme(
    backgroundColor: Color(0xFF2B2D31),
    textColor: Colors.white,
    icon: Icons.cloud_done,
    iconColor: Colors.lightBlueAccent,
    position: FlushbarPosition.TOP,
    duration: Duration(seconds: 4),
  ),
);
```

为什么选 Flushbar：
- **高度可定制**: 颜色、圆角、位置、阴影、图标、按钮都可控。
- **非阻塞体验**: 顶部/底部浮层，不打断用户操作。
- **操作可达**: 支持带按钮操作（如“重试”、“详情”）。
- **动画与层级**: 更灵活的入场/出场与叠加控制。