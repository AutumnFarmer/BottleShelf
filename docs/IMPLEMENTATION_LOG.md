# 瓶瓶罐罐实现日志

## 2026-05-19 M1 本地 MVP 起步

### 已实现

- 使用 XcodeGen 创建原生 iOS 工程：`BottleShelf.xcodeproj`
- SwiftUI App 入口：`BottleShelf/App/BottleShelfApp.swift`
- SwiftData 本地模型：`BeautyProduct`
- 产品枚举：
  - `ProductCategory`
  - `ProductLocation`
  - `ProductStatus`
- 到期计算服务：`ExpiryCalculator`
- 首次运行 demo 数据：`ProductSeed`
- 页面：
  - 今天
  - 库存
  - 产品详情
  - 添加/编辑产品
  - 梳妆台
  - 我的
  - Pro Paywall 静态页
- 操作：
  - 新增产品
  - 编辑产品
  - 删除产品
  - 标记开封
  - 标记空瓶
  - 延后 7 天提醒日期
  - 分类筛选
  - 状态筛选
  - 搜索产品/品牌/位置
- 单元测试：
  - 到期日取更早值
  - 30 天内临期
  - 超过到期日为过期
  - 手动空瓶状态优先

### 验证命令

生成工程：

```sh
xcodegen generate
```

构建：

```sh
xcodebuild -project BottleShelf.xcodeproj -scheme BottleShelf -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' CODE_SIGNING_ALLOWED=NO build
```

测试：

```sh
xcodebuild -project BottleShelf.xcodeproj -scheme BottleShelf -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' CODE_SIGNING_ALLOWED=NO test
```

安装并启动模拟器：

```sh
xcrun simctl boot 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED
xcrun simctl bootstatus 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED -b
xcrun simctl install 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED /Users/zmc/Library/Developer/Xcode/DerivedData/BottleShelf-asyysmlnqnhqljftfzhbmdedpxts/Build/Products/Debug-iphonesimulator/BottleShelf.app
xcrun simctl launch 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED com.zmc.bottleshelf
```

截图：

```sh
xcrun simctl io 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED screenshot /Users/zmc/Documents/Codex/2026-05-19/app/BottleShelf-simulator.png
```

### 验证结果

- `xcodebuild build`：通过
- `xcodebuild test`：通过，4 个测试全部成功
- 模拟器启动：通过
- App 安装：通过
- App 启动：通过
- 首屏截图：`/Users/zmc/Documents/Codex/2026-05-19/app/BottleShelf-simulator.png`

### 当前限制

- 产品照片选择与本地图片存储未接入。
- 本地通知未接入。
- StoreKit 2 真实购买未接入。
- 免费 10 件限制目前只在文档中定义，代码未拦截第 11 件。
- Paywall 是静态页面。
- App 图标和 App Store 截图未制作。

### 下一步

进入 M2：

1. 接入 UserNotifications。
2. 保存产品时调度 30 天、7 天、当天、过期后 7 天提醒。
3. 编辑/删除/空瓶时更新或取消提醒。
4. 接入 PhotosPicker 和本地图片存储。
5. 加上免费 10 件限制和 Paywall 触发。

## 2026-05-19 M2 提醒与图片

### 已实现

- 产品照片：
  - 添加/编辑产品时可通过 `PhotosPicker` 选择照片。
  - 选择的照片压缩为 JPEG，保存到 App Support 下的 `ProductImages` 目录。
  - 列表、详情、梳妆台和编辑页统一通过 `ProductThumbnail` 展示本地图片。
  - 删除产品时同步删除本地图片文件。
- 到期提醒：
  - 新增 `NotificationScheduler`，为每件产品维护 4 个本地通知标识：
    - 到期前 30 天
    - 到期前 7 天
    - 到期当天
    - 到期后 7 天
  - 今天页新增“开启到期提醒”卡片，用户主动点击后才请求系统通知权限。
  - 保存、编辑、标记开封、延后日期时，如果已授权，则自动同步提醒。
  - 删除或标记空瓶时取消该产品的待触发提醒。
- 免费限制：
  - 新增 `ProductLimit`，免费额度为 10 件。
  - 今天页和库存页的新增入口会在达到免费额度后打开 Paywall。
  - 我的页显示当前免费额度使用情况。
- 测试：
  - 增加免费额度规则测试。
  - 增加提醒 ID 与提醒文案测试。

### 验证命令

生成工程：

```sh
xcodegen generate
```

构建：

```sh
xcodebuild -project BottleShelf.xcodeproj -scheme BottleShelf -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' CODE_SIGNING_ALLOWED=NO build
```

测试：

```sh
xcodebuild -project BottleShelf.xcodeproj -scheme BottleShelf -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' CODE_SIGNING_ALLOWED=NO test
```

安装并启动模拟器：

```sh
xcrun simctl boot 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED
xcrun simctl bootstatus 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED -b
xcrun simctl install 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED /Users/zmc/Library/Developer/Xcode/DerivedData/BottleShelf-asyysmlnqnhqljftfzhbmdedpxts/Build/Products/Debug-iphonesimulator/BottleShelf.app
xcrun simctl launch 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED com.zmc.bottleshelf
```

截图：

```sh
xcrun simctl io 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED screenshot /Users/zmc/Documents/Codex/2026-05-19/app/BottleShelf-simulator-m2.png
```

### 验证结果

- `xcodebuild build`：通过
- `xcodebuild test`：通过，10 个测试全部成功
- 模拟器启动：通过
- App 安装：通过
- App 启动：通过
- 首屏截图：`/Users/zmc/Documents/Codex/2026-05-19/app/BottleShelf-simulator-m2.png`

### 当前限制

- 本地通知已经接入代码路径，但还需要在真机上做实际到点触发验证。
- StoreKit 2 真实购买未接入，Paywall 仍是静态页面。
- Pro 状态未接入，当前免费额度无法通过真实购买解锁。
- App 图标和 App Store 截图未制作。

### 下一步

进入 M3：

1. 创建 StoreKit 配置文件。
2. 接入 StoreKit 2 购买与恢复购买。
3. 将 Pro 状态接入 `ProductLimit`，购买后解除 10 件限制。
4. 做沙盒购买验证。
5. 优化 Paywall 文案与价格展示。
