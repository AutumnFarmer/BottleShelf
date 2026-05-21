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
xcrun simctl launch 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED com.autumnfarmer.bottleshelf
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
xcrun simctl launch 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED com.autumnfarmer.bottleshelf
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

## 2026-05-20 M3 付费闭环基础版

### 已实现

- 正式 App 启动路径不再自动插入 demo 产品，避免新用户首次打开看到假数据。
- 新增 `PurchaseManager`：
  - 使用 StoreKit 2 加载非消耗型 IAP 商品。
  - 商品 ID 固定为 `com.autumnfarmer.bottleshelf.pro.lifetime`。
  - 购买成功后读取当前权益。
  - 启动时读取 `Transaction.currentEntitlements`。
  - 监听 `Transaction.updates`，处理后续交易变化。
  - 实现恢复购买。
- `BottleShelfApp` 注入全局 `PurchaseManager`，Today、库存、我的、Paywall 共用同一份 Pro 状态。
- Paywall 从 StoreKit 商品读取展示价格。
- Paywall 主卖点收窄为当前版本已实现权益：
  - 无限产品
  - 本地到期提醒
  - 本地优先保存
- 今天页和库存页的免费 10 件限制已接入真实 Pro 状态，Pro 解锁后不再限制新增。
- 我的页恢复购买按钮已接入真实 StoreKit 恢复流程。
- `ProductLimit` 统计免费额度时排除已空瓶和已丢弃产品。
- 新增测试：
  - 已空瓶产品不占用免费额度。
  - Pro 商品 ID 保持稳定。

### 验证命令

生成工程：

```sh
xcodegen generate
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
xcrun simctl launch 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED com.autumnfarmer.bottleshelf
```

截图：

```sh
xcrun simctl io 6B6A8952-9B2E-4A75-BCF4-6DFF92823BED screenshot /Users/zmc/Documents/Codex/2026-05-19/app/BottleShelf-simulator-m3.png
```

### 验证结果

- `xcodebuild test`：通过，12 个测试全部成功
- StoreKit 2 编译链路：通过
- Pro 状态接入免费限制：通过单元测试覆盖
- 商品加载、购买、恢复购买：代码已接入，仍需 App Store Connect 或 StoreKit 本地配置后做沙盒验证

### 当前限制

- 还没有在 App Store Connect 创建真实 IAP 商品，商品 ID 需与 `com.autumnfarmer.bottleshelf.pro.lifetime` 一致。
- 还没有完成 StoreKit 沙盒购买、取消、恢复、重装恢复验证。
- 本地通知仍需真机到点触发验证。
- App 图标、隐私政策、App Store 截图和审核备注未制作。

### 下一步

1. 在 App Store Connect 创建非消耗型 IAP：`com.autumnfarmer.bottleshelf.pro.lifetime`。
2. 使用沙盒账号验证购买、取消、恢复购买和重装恢复。
3. 进入 M4，优先优化添加流程、Today 首屏和小屏适配。

## 2026-05-20 M4 UI 第一轮

### 已实现

- Today 首屏：
  - Hero 文案从“风险警报”改成“今天先用/处理哪件”的行动建议。
  - 统计卡从 4 列改为 2x2，提升手机阅读稳定性。
  - “过期”统一弱化为“超过建议期”，避免被理解成安全判断。
  - 提醒授权卡下移，不再打断首屏核心任务。
- 产品列表卡片：
  - 增加第二行信息：`还剩 x 天 · 存放位置`。
  - 品牌、分类、位置和建议期状态更清楚。
  - 状态标签改为“剩 x 天 / 超 x 天 / 今天”等更短文本。
- 分类占位图：
  - 不再所有分类都显示同一个瓶子形状。
  - 按洁面、水/喷雾、精华、面霜、防晒、彩妆、香水、小样、工具等分类显示系统图标。
- 添加/编辑表单：
  - 第一屏改为“先填这些”，集中照片、产品名、品牌、分类、位置。
  - “开封和建议期”增加快捷选择：刚打开、1 个月前、3 个月前、半年前。
  - 价格、备注、保质期 Stepper 收进“高级信息”，降低第一次录入压力。

### 验证结果

- `xcodebuild test`：通过，12 个测试全部成功
- 模拟器启动：通过
- UI 截图：`/Users/zmc/Documents/Codex/2026-05-19/app/BottleShelf-simulator-ui-m4.png`

### 下一步

1. 做小屏适配截图检查，重点看添加表单和 Paywall。
2. 优化详情页危险操作区，把删除降权。
3. 做真机通知验证和提醒设置页。

## 2026-05-20 M4.1 连续录入闭环

### 已实现

- 添加页新增“保存并继续添加”。
- 连续添加时保留上一件产品的：
  - 分类
  - 位置
  - 是否开封
- 保存并继续添加后清空产品名、品牌、照片、价格、备注和日期，方便录下一件。
- 保存后显示轻反馈：`已记录 xxx，继续添加下一件`。
- 快捷开封时间增加选中态，用户能看到“刚打开 / 1个月前 / 3个月前 / 半年前”是否生效。
- 未开封产品增加低压力购买时间选项：
  - 刚买
  - 今年买的
  - 去年买的
  - 记不清
- 添加页新增保存前建议期预览：
  - 可计算时展示预计日期和剩余天数。
  - 不可计算时提示补充购买日期或开封日期。
- 连续添加接入免费额度边界：
  - 第 10 件保存后如果继续添加，会打开 Paywall。
  - Pro 用户不受该限制。

### 验证结果

- `xcodebuild build`：通过
- `xcodebuild test`：通过，12 个测试全部成功
- 模拟器安装启动：通过
- 当前截图：`/Users/zmc/Documents/Codex/2026-05-19/app/BottleShelf-simulator-m4-1.png`

### 下一步

1. 用 UI 测试或手动真机验证连续录入 3 件的实际耗时。
2. 做 Today 推荐产品卡，压缩 0 值统计。
3. 做详情页危险操作降权和“7 天后再提醒我”。

## 2026-05-21 上线冲刺：Paywall 风险关闭

### 已实现

- Paywall 改为 `ScrollView + 底部固定购买区`，小屏和大字号下购买区更稳定。
- 商品价格只来自 StoreKit，不再使用固定 `¥28` 兜底展示。
- StoreKit 商品未加载到时：
  - 价格显示为“暂不可用”。
  - 主按钮显示“商品暂不可用”并禁用。
  - 提供“重新加载商品”入口。
- 保留恢复购买入口，仍可同步已有 App Store 权益。
- 新增测试：StoreKit 商品未加载前 `displayPrice` 为 `nil`。

### 验证结果

- `xcodebuild test`：通过，13 个测试全部成功

### 下一步

1. 创建本地 StoreKit 配置或 App Store Connect IAP 商品。
2. 做 StoreKit 沙盒购买、取消、恢复购买、重装恢复验证。
3. 继续关闭详情页“延后 7 天提醒”修改真实建议期的问题。

## 2026-05-21 App Store Connect 配置

### 已完成

- Apple Developer Team：`Farmers Autumn` / Team ID `X3ZQB66K6X`。
- App Store Connect App 已创建：
  - App 名称：`BottleShelf`
  - Apple ID：`6771651166`
  - SKU：`bottleshelf-ios`
  - Bundle ID：`com.autumnfarmer.bottleshelf`
- App ID 已注册：`BottleShelf - com.autumnfarmer.bottleshelf`。
- 非消耗型 IAP 已创建：
  - 参考名称：`BottleShelf Pro Lifetime`
  - 产品 ID：`com.autumnfarmer.bottleshelf.pro.lifetime`
  - Apple ID：`6771651845`
  - 定价：以中国大陆为基准，`¥28.00`
  - 销售范围：所有国家或地区
  - 简体中文本地化：`BottleShelf Pro`
- 本地工程已同步：
  - App Bundle ID 改为 `com.autumnfarmer.bottleshelf`。
  - Test Bundle ID 改为 `com.autumnfarmer.bottleshelf.tests`。
  - StoreKit 商品 ID 改为 `com.autumnfarmer.bottleshelf.pro.lifetime`。
  - `MARKETING_VERSION` 改为 `1.0`，与 App Store Connect 首版一致。
- IAP 审核截图已生成：
  - 使用 DEBUG-only 启动参数 `-showPaywallOnLaunch -reviewPaywallScreenshot` 直接打开 Pro 购买页。
  - 截图内容已包含 Pro 权益、`¥28.00` 价格和 Apple 购买处理说明。
- IAP 审核截图已上传到 App Store Connect。
  - IAP 状态已从“元数据丢失”变为“准备提交”。
- IAP 图像（可选）已上传：
  - 素材：`/Users/zmc/Downloads/BottleShelf-AppStore-Assets/BottleShelf-iap-promo-1024.png`
  - 尺寸：`1024x1024`
  - 上传后页面出现“App Store 推广”配置区。
- App 产品页截屏已上传：
  - 上传位置：`iPhone 6.5 英寸显示屏`
  - 上传数量：`5/10 张截屏`
  - 尺寸：`1284x2778`
  - 素材目录：`/Users/zmc/Downloads/BottleShelf-AppStore-Assets`

### 仍待完成

1. 上传第一个 TestFlight 构建。
2. 将首个 IAP 关联到 `1.0` 版本后随 App 一起提交审核。
3. 完成 App 隐私、年龄分级、描述、关键词、支持 URL、审核备注等上架元数据。
