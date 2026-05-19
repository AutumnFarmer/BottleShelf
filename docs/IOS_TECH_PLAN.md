# 瓶瓶罐罐 iOS 技术方案 v0.1

日期：2026-05-19  
目标：支持 MVP 快速开发、TestFlight 内测和 App Store 上架

## 1. 技术选择

推荐：

- UI：SwiftUI
- 本地数据：SwiftData
- 图片存储：App Sandbox 本地文件
- 通知：UserNotifications
- 付费：StoreKit 2
- 同步：首版不做，后续用 CloudKit / iCloud
- 最低系统：iOS 17 起步

理由：

- SwiftUI + SwiftData 可以最快做出原生 iOS MVP。
- 首版不做服务器，降低成本、隐私风险和审核复杂度。
- StoreKit 2 适合一次性买断和后续订阅扩展。
- iOS 17 起步能覆盖近几年设备，同时减少兼容成本。

## 2. 模块拆分

建议目录结构：

```text
BottleShelf/
  App/
    BottleShelfApp.swift
    AppRouter.swift
  Models/
    BeautyProduct.swift
    ProductCategory.swift
    ProductLocation.swift
    ProductStatus.swift
    ReminderRule.swift
    EntitlementState.swift
  Services/
    ProductStore.swift
    ExpiryCalculator.swift
    NotificationScheduler.swift
    PurchaseService.swift
    ImageStore.swift
  Features/
    Today/
    Inventory/
    ProductDetail/
    ProductEditor/
    Vanity/
    Paywall/
    Settings/
  Shared/
    Components/
    Theme/
    Utils/
  Resources/
    Assets.xcassets
    StoreKit.storekit
```

## 3. 数据模型

### 3.1 BeautyProduct

```swift
@Model
final class BeautyProduct {
    var id: UUID
    var name: String
    var brand: String?
    var category: ProductCategory
    var location: ProductLocation
    var statusOverride: ProductStatus?
    var purchaseDate: Date?
    var openedDate: Date?
    var unopenedShelfLifeMonths: Int?
    var openedShelfLifeMonths: Int?
    var expiryDate: Date?
    var price: Decimal?
    var imageFileName: String?
    var note: String?
    var repurchaseIntent: RepurchaseIntent?
    var isEstimatedOpenedDate: Bool
    var createdAt: Date
    var updatedAt: Date
    var emptiedAt: Date?
    var discardedAt: Date?
}
```

说明：

- `expiryDate` 可以缓存，便于排序和提醒。
- 每次编辑日期字段后重新计算 `expiryDate`。
- `statusOverride` 只用于已空瓶、已丢弃等人工状态。

### 3.2 ProductCategory

```swift
enum ProductCategory: String, Codable, CaseIterable {
    case cleanser
    case toner
    case serum
    case cream
    case sunscreen
    case mask
    case baseMakeup
    case lip
    case eyeMakeup
    case perfume
    case sample
    case tool
    case other
}
```

### 3.3 ProductLocation

```swift
enum ProductLocation: String, Codable, CaseIterable {
    case vanity
    case bathroom
    case commuteBag
    case travelBag
    case office
    case unopenedStock
    case other
}
```

### 3.4 ProductStatus

```swift
enum ProductStatus: String, Codable {
    case unopened
    case inUse
    case expiringSoon
    case expired
    case emptied
    case discarded
}
```

状态展示由 `ExpiryCalculator` 统一计算，避免每个页面重复判断。

## 4. 核心服务

### 4.1 ExpiryCalculator

职责：

- 根据购买日期、开封日期、保质期计算到期日。
- 根据当前日期计算状态。
- 根据分类给出默认开封后使用期。
- 标记日期是否为估算。

关键方法：

```swift
func expiryDate(for product: BeautyProduct) -> Date?
func status(for product: BeautyProduct, now: Date) -> ProductStatus
func defaultOpenedShelfLifeMonths(for category: ProductCategory) -> Int
func priorityScore(for product: BeautyProduct, now: Date) -> Int
```

### 4.2 NotificationScheduler

职责：

- 为产品创建本地通知。
- 编辑产品后更新通知。
- 删除、空瓶、丢弃后取消通知。
- 请求通知权限。

通知 ID 规则：

```text
product.<uuid>.minus30
product.<uuid>.minus7
product.<uuid>.due
product.<uuid>.after7
```

### 4.3 PurchaseService

职责：

- 加载 StoreKit 商品。
- 执行一次性买断。
- 恢复购买。
- 监听交易更新。
- 暴露当前 Pro 状态。

首版商品：

```text
pro_lifetime
```

### 4.4 ImageStore

职责：

- 保存用户选择的产品照片。
- 生成缩略图。
- 删除产品时清理图片。

建议：

- 图片不要直接存 SwiftData。
- 存文件名，图片放 Application Support。
- 缩略图按需生成或保存单独小图。

## 5. 页面实现边界

### 5.1 TodayView

展示：

- 今日状态摘要
- 优先使用产品
- 临期/过期产品
- 最近开封

数据来源：

- SwiftData 查询全部未空瓶/未丢弃产品。
- 按 `priorityScore` 排序。

### 5.2 InventoryView

展示：

- 搜索框
- 分类筛选
- 状态筛选
- 产品列表

首版实现：

- 本地内存筛选即可。
- 数据量小，不需要复杂索引。

### 5.3 ProductEditorView

模式：

- 新增
- 编辑

保存规则：

- 只要求产品名、分类、开封状态。
- 如果用户选择已开封但不记得日期，给估算选项。
- 保存后重新计算到期日并调度通知。

### 5.4 ProductDetailView

操作：

- 标记开封
- 标记空瓶
- 延后提醒
- 编辑
- 删除

危险操作：

- 删除需要二次确认。

### 5.5 PaywallView

触发：

- 添加第 11 件产品。
- 用户从“我的”进入 Pro。

必须包含：

- 免费限制说明。
- Pro 权益。
- 一次性买断价格。
- 恢复购买。
- 隐私说明入口。

## 6. 付费逻辑

### 6.1 免费限制

```swift
if !entitlement.isPro && activeProductCount >= 10 {
    showPaywall()
}
```

`activeProductCount` 不包括：

- 已删除

是否包括已空瓶：

- 建议包括，因为空瓶记录也占用价值。
- 如果转化太硬，后续可改为不包括已空瓶。

### 6.2 Pro 状态

来源优先级：

1. StoreKit 当前权益
2. 交易监听更新
3. 本地缓存只作为 UI 临时状态，不作为最终判断

## 7. 通知权限策略

不要首次打开就请求权限。

触发时机：

1. 用户首次保存带到期日的产品。
2. 弹出 App 内解释。
3. 用户点“开启提醒”。
4. 调用系统通知权限弹窗。

如果用户拒绝：

- 页面提示可以去系统设置开启。
- 产品仍可保存。

## 8. 隐私与审核

首版隐私承诺：

- 不需要注册。
- 不上传产品数据。
- 产品照片仅保存在设备本地。
- 通知在本机调度。
- 购买由 App Store 处理。

需要准备：

- 隐私政策网页
- App Store 隐私标签
- 应用内“隐私与数据”页面

避免：

- 安全可用判断
- 皮肤问题建议
- 医疗/健康宣称
- 虚假折扣和倒计时

## 9. 测试计划

### 9.1 单元测试

优先覆盖：

- 到期日计算
- 状态计算
- 默认保质期
- 免费限制
- 通知 ID 生成

### 9.2 手动测试

必须覆盖：

- 新增未开封产品
- 新增已开封产品
- 选择估算日期
- 编辑开封日期
- 删除产品
- 标记空瓶
- 临期/过期排序
- 添加第 11 件触发 Paywall
- StoreKit 沙盒购买
- 恢复购买
- 通知权限拒绝后的保存流程

### 9.3 TestFlight 验证

建议 5-10 人内测，重点观察：

- 是否愿意录入超过 3 件。
- 哪些字段让用户卡住。
- 用户是否理解临期提醒。
- Paywall 是否太早或太晚。
- 女性用户是否觉得视觉“精致可信”。

## 10. 主要风险

1. 录入成本高
   - 对策：必填字段尽量少，日期允许估算。

2. 用户不相信默认保质期
   - 对策：文案说明“常见参考值”，允许自定义。

3. 付费点太硬
   - 对策：免费 10 件先验证，内测后可调到 15 件。

4. 通知权限被拒
   - 对策：先解释后请求，不影响保存。

5. 图片占用空间
   - 对策：压缩图片，保存缩略图。

6. 审核误判健康建议
   - 对策：全产品文案避免安全/医疗判断，只说日期提醒。
