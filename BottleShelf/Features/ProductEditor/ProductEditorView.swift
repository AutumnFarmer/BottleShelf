import SwiftData
import PhotosUI
import SwiftUI

struct ProductEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseManager: PurchaseManager
    @Query private var products: [BeautyProduct]

    private let product: BeautyProduct?

    @State private var name: String
    @State private var brand: String
    @State private var category: ProductCategory
    @State private var location: ProductLocation
    @State private var isOpened: Bool
    @State private var hasPurchaseDate: Bool
    @State private var purchaseDate: Date
    @State private var hasOpenedDate: Bool
    @State private var openedDate: Date
    @State private var isEstimatedOpenedDate: Bool
    @State private var unopenedShelfLifeMonths: Int
    @State private var openedShelfLifeMonths: Int
    @State private var priceText: String
    @State private var note: String
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var showingAdvancedInfo: Bool
    @State private var selectedOpenedEstimateMonths: Int?
    @State private var selectedPurchaseEstimate: PurchaseEstimate?
    @State private var feedbackMessage: String?
    @State private var showingPaywall = false

    init(product: BeautyProduct? = nil) {
        self.product = product
        _name = State(initialValue: product?.name ?? "")
        _brand = State(initialValue: product?.brand ?? "")
        _category = State(initialValue: product?.category ?? .serum)
        _location = State(initialValue: product?.location ?? .vanity)
        _isOpened = State(initialValue: product?.openedDate != nil)
        _hasPurchaseDate = State(initialValue: product?.purchaseDate != nil)
        _purchaseDate = State(initialValue: product?.purchaseDate ?? Date())
        _hasOpenedDate = State(initialValue: product?.openedDate != nil)
        _openedDate = State(initialValue: product?.openedDate ?? Date())
        _isEstimatedOpenedDate = State(initialValue: product?.isEstimatedOpenedDate ?? false)
        _unopenedShelfLifeMonths = State(initialValue: product?.unopenedShelfLifeMonths ?? 24)
        _openedShelfLifeMonths = State(initialValue: product?.openedShelfLifeMonths ?? ExpiryCalculator.defaultOpenedShelfLifeMonths(for: product?.category ?? .serum))
        _priceText = State(initialValue: product?.price.map { String(format: "%.0f", $0) } ?? "")
        _note = State(initialValue: product?.note ?? "")
        _selectedPhotoItem = State(initialValue: nil)
        _selectedImageData = State(initialValue: nil)
        _showingAdvancedInfo = State(initialValue: product != nil)
        _selectedOpenedEstimateMonths = State(initialValue: nil)
        _selectedPurchaseEstimate = State(initialValue: nil)
        _feedbackMessage = State(initialValue: nil)
        _showingPaywall = State(initialValue: false)
    }

    var body: some View {
        NavigationStack {
            Form {
                if let feedbackMessage {
                    Section {
                        Label(feedbackMessage, systemImage: "checkmark.circle.fill")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(AppTheme.sage)
                    }
                }

                Section("先填这些") {
                    HStack(spacing: 14) {
                        editorImagePreview

                        VStack(alignment: .leading, spacing: 6) {
                            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                                Label("选择照片", systemImage: "photo")
                            }
                            .buttonStyle(.bordered)

                            Text("照片只保存在本机，用于更快识别你的产品。")
                                .font(.footnote)
                                .foregroundStyle(AppTheme.muted)
                        }
                    }
                    .padding(.vertical, 4)

                    TextField("产品名", text: $name)
                    TextField("品牌（选填）", text: $brand)

                    Picker("分类", selection: $category) {
                        ForEach(ProductCategory.allCases) { category in
                            Text(category.displayName).tag(category)
                        }
                    }

                    Picker("位置", selection: $location) {
                        ForEach(ProductLocation.allCases) { location in
                            Text(location.displayName).tag(location)
                        }
                    }
                }

                Section("开封和建议期") {
                    Toggle("已经开封", isOn: $isOpened)

                    if isOpened {
                        Text("大概什么时候开的？")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(AppTheme.ink)

                        estimatedDateButtons

                        Toggle("手动调整开封日期", isOn: $hasOpenedDate)
                        if hasOpenedDate {
                            DatePicker("开封日期", selection: $openedDate, displayedComponents: .date)
                            Toggle("这是估算日期", isOn: $isEstimatedOpenedDate)
                        }
                    } else {
                        Text("大概什么时候买的？")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(AppTheme.ink)

                        purchaseEstimateButtons
                    }

                    Toggle(isOpened ? "填写购买日期" : "手动调整购买日期", isOn: $hasPurchaseDate)
                    if hasPurchaseDate {
                        DatePicker("购买日期", selection: $purchaseDate, displayedComponents: .date)
                    }
                }

                Section {
                    DisclosureGroup("高级信息", isExpanded: $showingAdvancedInfo) {
                        if isOpened {
                            Stepper("开封后使用期：\(openedShelfLifeMonths) 个月", value: $openedShelfLifeMonths, in: 1...48)
                        }
                        Stepper("未开封保质期：\(unopenedShelfLifeMonths) 个月", value: $unopenedShelfLifeMonths, in: 1...60)
                        TextField("价格（选填）", text: $priceText)
                            .keyboardType(.decimalPad)
                        TextField("备注（选填）", text: $note, axis: .vertical)
                            .lineLimit(3...6)
                    }
                }

                Section("保存前预览") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(previewTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.ink)
                        Text(previewMessage)
                            .font(.footnote)
                            .foregroundStyle(AppTheme.muted)
                    }
                    .padding(.vertical, 2)
                }

                if product == nil {
                    Section {
                        Button {
                            save(continueAdding: true)
                        } label: {
                            Label("保存并继续添加", systemImage: "plus.circle.fill")
                                .font(.subheadline.weight(.semibold))
                        }
                        .disabled(!canSave)

                        Button("保存并返回") {
                            save()
                        }
                        .disabled(!canSave)
                    }
                }

                Section {
                    Text("到期日期仅根据你填写的信息估算，用于库存管理和日期提醒，不构成安全或医疗判断。")
                        .font(.footnote)
                        .foregroundStyle(AppTheme.muted)
                }
            }
            .navigationTitle(product == nil ? "添加产品" : "编辑产品")
            .onChange(of: selectedPhotoItem) { _, newItem in
                Task {
                    selectedImageData = try? await newItem?.loadTransferable(type: Data.self)
                }
            }
            .onChange(of: category) { _, newValue in
                openedShelfLifeMonths = ExpiryCalculator.defaultOpenedShelfLifeMonths(for: newValue)
            }
            .onChange(of: isOpened) { _, opened in
                selectedOpenedEstimateMonths = nil
                selectedPurchaseEstimate = nil
                if opened {
                    hasPurchaseDate = false
                } else {
                    hasOpenedDate = false
                    isEstimatedOpenedDate = false
                }
            }
            .onChange(of: hasPurchaseDate) { _, hasDate in
                if !hasDate, selectedPurchaseEstimate != .unknown {
                    selectedPurchaseEstimate = nil
                }
            }
            .onChange(of: hasOpenedDate) { _, hasDate in
                if !hasDate {
                    selectedOpenedEstimateMonths = nil
                    isEstimatedOpenedDate = false
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }

    private var estimatedDateButtons: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("不记得准确日期时，先选一个大概时间，后面可以再改。")
                .font(.footnote)
                .foregroundStyle(AppTheme.muted)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 82), spacing: 8)], spacing: 8) {
                estimateButton("刚打开", months: 0)
                estimateButton("1个月前", months: -1)
                estimateButton("3个月前", months: -3)
                estimateButton("半年前", months: -6)
            }
        }
    }

    private var purchaseEstimateButtons: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 82), spacing: 8)], spacing: 8) {
            ForEach(PurchaseEstimate.allCases) { estimate in
                estimateButton(estimate.title, isSelected: selectedPurchaseEstimate == estimate) {
                    selectedPurchaseEstimate = estimate
                    if let date = estimate.date() {
                        purchaseDate = date
                        hasPurchaseDate = true
                    } else {
                        hasPurchaseDate = false
                    }
                }
            }
        }
    }

    private var editorImagePreview: some View {
        Group {
            if let selectedUIImage {
                Image(uiImage: selectedUIImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ProductThumbnail(category: category, imageFileName: product?.imageFileName, size: 72)
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var selectedUIImage: UIImage? {
        guard let selectedImageData else { return nil }
        return UIImage(data: selectedImageData)
    }

    private func estimateButton(_ title: String, months: Int) -> some View {
        estimateButton(title, isSelected: selectedOpenedEstimateMonths == months) {
            openedDate = Calendar.current.date(byAdding: .month, value: months, to: Date()) ?? Date()
            hasOpenedDate = true
            isEstimatedOpenedDate = months != 0
            selectedOpenedEstimateMonths = months
        }
    }

    private func estimateButton(_ title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(isSelected ? Color.white : AppTheme.muted)
                .frame(maxWidth: .infinity)
                .frame(height: 34)
                .background(isSelected ? AppTheme.primary : AppTheme.primarySoft.opacity(0.55))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var formPurchaseDate: Date? {
        hasPurchaseDate ? purchaseDate : nil
    }

    private var formOpenedDate: Date? {
        isOpened && hasOpenedDate ? openedDate : nil
    }

    private var previewExpiryDate: Date? {
        ExpiryCalculator.expiryDate(
            purchaseDate: formPurchaseDate,
            unopenedShelfLifeMonths: unopenedShelfLifeMonths,
            openedDate: formOpenedDate,
            openedShelfLifeMonths: isOpened ? openedShelfLifeMonths : nil
        )
    }

    private var previewTitle: String {
        guard let previewExpiryDate else {
            return "还无法计算建议期"
        }
        return "预计 \(previewExpiryDate.shortDateText) 前留意"
    }

    private var previewMessage: String {
        guard let previewExpiryDate else {
            return "补充购买日期或开封日期后，App 会自动生成建议期并安排提醒。"
        }

        let days = Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: previewExpiryDate)
        ).day ?? 0

        if days < 0 {
            return "根据当前信息，这件产品已经超过建议期 \(abs(days)) 天。"
        }
        if days == 0 {
            return "根据当前信息，这件产品今天到建议期。"
        }
        return "保存后会按建议期创建本地提醒，距离建议期还有 \(days) 天。"
    }

    private func save(continueAdding: Bool = false) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedBrand = brand.trimmingCharacters(in: .whitespacesAndNewlines)
        let purchase = formPurchaseDate
        let opened = formOpenedDate
        let price = Double(priceText.trimmingCharacters(in: .whitespacesAndNewlines))

        let savedProduct: BeautyProduct

        if let product {
            product.name = trimmedName
            product.brand = trimmedBrand
            product.category = category
            product.location = location
            product.purchaseDate = purchase
            product.openedDate = opened
            product.unopenedShelfLifeMonths = unopenedShelfLifeMonths
            product.openedShelfLifeMonths = isOpened ? openedShelfLifeMonths : nil
            product.price = price
            product.note = note
            product.isEstimatedOpenedDate = isOpened && isEstimatedOpenedDate
            product.statusOverride = nil
            product.refreshExpiryDate()
            savedProduct = product
        } else {
            let newProduct = BeautyProduct(
                name: trimmedName,
                brand: trimmedBrand,
                category: category,
                location: location,
                purchaseDate: purchase,
                openedDate: opened,
                unopenedShelfLifeMonths: unopenedShelfLifeMonths,
                openedShelfLifeMonths: isOpened ? openedShelfLifeMonths : nil,
                price: price,
                note: note,
                isEstimatedOpenedDate: isOpened && isEstimatedOpenedDate
            )
            modelContext.insert(newProduct)
            savedProduct = newProduct
        }

        if let selectedImageData,
           let imageFileName = ImageStore.saveImageData(selectedImageData, productID: savedProduct.id) {
            savedProduct.imageFileName = imageFileName
            savedProduct.updatedAt = Date()
        }

        try? modelContext.save()

        let snapshot = ProductReminderSnapshot(product: savedProduct)
        Task {
            await NotificationScheduler.syncRemindersIfAuthorized(for: snapshot)
        }

        if continueAdding, product == nil {
            let canContinueAdding = ProductLimit.canAddProduct(
                to: productsIncluding(savedProduct),
                isPro: purchaseManager.isPro
            )
            resetForNextProduct(afterSaving: savedProduct.name)
            if !canContinueAdding {
                feedbackMessage = "已记录 \(savedProduct.name)，免费额度已用完"
                showingPaywall = true
            }
        } else {
            dismiss()
        }
    }

    private func productsIncluding(_ savedProduct: BeautyProduct) -> [BeautyProduct] {
        products.filter { $0.id != savedProduct.id } + [savedProduct]
    }

    private func resetForNextProduct(afterSaving savedName: String) {
        feedbackMessage = "已记录 \(savedName)，继续添加下一件"
        name = ""
        brand = ""
        priceText = ""
        note = ""
        selectedPhotoItem = nil
        selectedImageData = nil
        hasPurchaseDate = false
        purchaseDate = Date()
        hasOpenedDate = false
        openedDate = Date()
        isEstimatedOpenedDate = false
        selectedOpenedEstimateMonths = nil
        selectedPurchaseEstimate = nil
        unopenedShelfLifeMonths = 24
        openedShelfLifeMonths = ExpiryCalculator.defaultOpenedShelfLifeMonths(for: category)
        showingAdvancedInfo = false
    }
}

private enum PurchaseEstimate: String, CaseIterable, Identifiable {
    case justBought
    case thisYear
    case lastYear
    case unknown

    var id: String { rawValue }

    var title: String {
        switch self {
        case .justBought: "刚买"
        case .thisYear: "今年买的"
        case .lastYear: "去年买的"
        case .unknown: "记不清"
        }
    }

    func date(now: Date = Date(), calendar: Calendar = .current) -> Date? {
        switch self {
        case .justBought:
            return now
        case .thisYear:
            let year = calendar.component(.year, from: now)
            return calendar.date(from: DateComponents(year: year, month: 1, day: 1))
        case .lastYear:
            let year = calendar.component(.year, from: now) - 1
            return calendar.date(from: DateComponents(year: year, month: 1, day: 1))
        case .unknown:
            return nil
        }
    }
}
