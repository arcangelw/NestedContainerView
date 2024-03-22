//
//  NestedAdapter.swift
//
//
//  Created by 吴哲 on 2024/1/26.
//

import UIKit
#if canImport(NestedProxy)
import NestedProxy
#endif

// swiftlint:disable line_length file_length

/// 绑定 NestedContainerViewDelegate
extension NestedAdapterProxy: NestedContainerViewDelegate {}

/// 嵌套内容适配器
public class NestedAdapter: NSObject, NestedContainerContext {
    /// 适配器所在的 UIViewController
    public weak var viewController: UIViewController?

    /// 绑定的嵌套容器
    public weak var nestedContainerView: NestedContainerView? {
        didSet {
            guard let nestedContainerView = nestedContainerView, nestedContainerView != oldValue else {
                return
            }
            oldValue?.nestedAdapter = nil
            setUpNestedContainerView(nestedContainerView)
        }
    }

    /// 代理对象
    public weak var delegate: NestedAdapterDelegate?

    /// 数据源对象
    public weak var dataSource: NestedAdapterDataSource? {
        didSet {
            guard oldValue !== dataSource else { return }
            updateData()
        }
    }

    /// 滚动代理对象
    public weak var scrollViewDelegate: UIScrollViewDelegate? {
        didSet {
            createProxyAndUpdateContainerDelegate()
        }
    }

    /// 容器手势代理对象
    public weak var gestureDelegate: NestedContainerViewGestureDelegate? {
        didSet {
            nestedContainerView?.gestureDelegate = gestureDelegate
        }
    }

    /// 是否处于更新状态
    public internal(set) var isInSectionUpdateTransaction = false

    /// 自定义滚动计算处理类型
    public var scrollProcessorType: NestedSectionScrollProcessor.Type? {
        didSet {
            let newType = scrollProcessorType ?? DefaultScrollProcessor.self
            sectionMap.createScrollProcessor = { newType.init(trait: $0) }
        }
    }

    /// 用于判断是否允许检查节特性的条件闭包
    public var allowedToCheckSectionTraitCondition: () -> Bool = { true }

    /// 是否启用检查节特性
    public var isCheckSectionTraitEnable: Bool = false {
        didSet {
            if isCheckSectionTraitEnable {
                SectionTraitTransaction.addCheck(self)
            } else {
                SectionTraitTransaction.removeCheck(self)
            }
        }
    }

    // MARK: - internal

    /// 当前容器视图
    var currentContainerView: NestedContainerView {
        guard let nestedContainerView = nestedContainerView else {
            NestedLogger.shared.assertionFailure("nestedContainerView 不能为空")
            return .init()
        }
        return nestedContainerView
    }

    /// 滚动指示器
    var scrollIndicator: NestedScrollIndicator {
        return currentContainerView.scrollIndicator
    }

    /// 转发代理对象
    private var delegateProxy: NestedAdapterProxy?

    /// 存储 section 内容的映射
    let sectionMap = NestedSectionMap()
    /// 内容显示处理对象
    let displayHandler = NestedSectionDisplayHandler()
    /// 是否显示 headerView
    var isDisplayHeader = false
    /// 是否显示 footerView
    var isDisplayFooter = false
    /// 是否允许检查内容特性
    var isAllowedToCheckSectionTrait = false

    /// 显示视图与 section 控制器的映射表
    let viewToControllerMap = NSMapTable<UIView, NestedSectionController>.init(keyOptions: [.strongMemory, .objectPointerPersonality], valueOptions: .strongMemory)

    /// 队列调度对象
    let completionDispatcher = QueuedCompletionDispatcher()

    /// UI 主线程串行调度队列
    let uiDispatcher = UISerialDispatcher()

    /// 初始化方法
    /// - Parameter viewController: 当前的 UIViewController
    public init(viewController: UIViewController) {
        self.viewController = viewController
        super.init()
        OnceDispatcher.dispatch {
            Swizzling.hookUIKit()
        }
    }

    deinit {
        if isCheckSectionTraitEnable {
            SectionTraitTransaction.removeCheck(self)
        }
    }

    // MARK: - NestedContainerContext

    /// 容器的尺寸
    public var containerSize: CGSize {
        return currentContainerView.scrollView.bounds.size
    }

    /// 容器的特征信息
    public var traitCollection: UITraitCollection {
        return currentContainerView.scrollView.traitCollection
    }

    /// 容器的内容偏移
    public var containerContentOffset: CGPoint {
        return currentContainerView.scrollView.contentOffset
    }

    /// 容器的滚动特征信息
    public var scrollingTrait: NestedContainerScrollingTrait {
        return .init(containerScrollView: currentContainerView.scrollView)
    }

    /// 获取容器内占用的尺寸
    /// - Parameter sectionController: 需要计算的控制器
    /// - Returns: 在容器内的尺寸
    public func containerSize(for _: NestedSectionController) -> CGSize {
        return currentContainerView.scrollView.bounds.size
    }

    /// 嵌入式滚动视图滚动时的事件回调
    ///
    /// - Parameters:
    ///   - event: 嵌入式滚动视图事件
    ///   - sectionController: 当前控制器
    public func embeddedScrollViewEvent(_ event: NestedEmbeddedScrollViewEvent, for sectionController: NestedSectionController) {
        let containerScrollView = currentContainerView.scrollView
        guard event.scrollView !== containerScrollView, !containerScrollView.isScrollingToPosition else { return }
        if case .didScroll(let scrollView) = event {
            sectionMap.processor(for: sectionController)?.embeddedScrollViewDidScroll(scrollView)
        }
        reloadScrollIndicator(currentContainerView.scrollView)
    }

    /// 配置布局无效重置
    /// - Parameters:
    ///   - sectionController: 需要配置的控制器
    ///   - completion: 回调
    public func invalidateLayout(in sectionController: NestedSectionController, completion: ((_ finished: Bool) -> Void)? = nil) {
        completionDispatcher.deferBlockBetweenBatchUpdates { [weak self] in
            guard let self = self else { return }
            self.queuedInvalidateLayout(in: sectionController, completion: completion)
        }
    }

    /// 配置布局无效并重置
    ///
    /// - Parameters:
    ///   - headerFooterViewController: 需要配置的页眉/页脚视图控制器
    ///   - completion: 配置完成后的回调
    public func invalidateLayout(in headerFooterViewController: NestedHeaderFooterViewController, completion: ((_ finished: Bool) -> Void)? = nil) {
        completionDispatcher.deferBlockBetweenBatchUpdates { [weak self] in
            guard let self = self else { return }
            self.queuedInvalidateLayout(in: headerFooterViewController, completion: completion)
        }
    }

    /// 滚动容器到指定的控制器
    ///
    /// - Parameters:
    ///   - sectionController: 要滚动到的控制器
    ///   - animated: 是否需要动画效果
    ///   - completion: 滚动完成后的回调，参数为滚动是否完成的布尔值
    public func scrollContainer(to sectionController: NestedSectionController, animated: Bool = true, completion: ((_ finished: Bool) -> Void)? = nil) {
        guard let targetSection = section(for: sectionController) else {
            completion?(false)
            return
        }
        isAllowedToCheckSectionTrait = false
        currentContainerView.scrollView.scrollToPosition(.section(targetSection), animated: animated) { [weak self] finished in
            guard let self = self else { return }
            completion?(finished)
            self.isAllowedToCheckSectionTrait = true
        }
    }

    /// 滚动容器到指定的头部/尾部视图控制器
    ///
    /// - Parameters:
    ///   - headerFooterViewController: 要滚动到的头部/尾部视图控制器
    ///   - animated: 是否需要动画效果
    ///   - completion: 滚动完成后的回调，参数为滚动是否完成的布尔值
    public func scrollContainer(to headerFooterViewController: NestedHeaderFooterViewController, animated: Bool, completion: ((_ finished: Bool) -> Void)?) {
        guard !currentContainerView.scrollView.isScrollingToPosition else {
            NestedLogger.shared.warn("containerScrollView isScrollingToPosition")
            completion?(false)
            return
        }
        let position: NestedContainerScrollPosition
        switch headerFooterViewController.style {
        case .header:
            position = .header
        case .footer:
            position = .footer
        }
        isAllowedToCheckSectionTrait = false
        currentContainerView.scrollView.scrollToPosition(position, animated: animated) { [weak self] finished in
            guard let self = self else { return }
            completion?(finished)
            self.isAllowedToCheckSectionTrait = true
        }
    }

    /// 适配器刷新
    /// - Parameter completion: 回调
    public func reloadData(completion: ((_ finished: Bool) -> Void)? = nil) {
        guard let dataSource = dataSource, nestedContainerView != nil else {
            completion?(false)
            return
        }
        completionDispatcher.enterBatchUpdates()
        uiDispatcher.dispatch { [weak self] in
            guard let self = self else { return }
            self.reload(dataSource: dataSource, completion: completion)
        }
    }

    // MARK: - Container

    /// 配置绑定嵌套容器
    /// - Parameter containerView: 容器
    func setUpNestedContainerView(_ containerView: NestedContainerView) {
        containerView.nestedAdapter = self
        containerView.dataSource = self
        containerView.scrollView.reloadData()
        containerView.gestureDelegate = gestureDelegate
        updateContainerDelegate()
        updateData()
    }

    /// 创建配置容器转发代理
    private func createProxyAndUpdateContainerDelegate() {
        currentContainerView.delegate = nil
        delegateProxy = .init(scrollViewTarget: scrollViewDelegate, interceptor: self)
        updateContainerDelegate()
    }

    /// 更新容器代理
    private func updateContainerDelegate() {
        currentContainerView.delegate = delegateProxy ?? self
    }

    /// 配置布局失效重置
    /// - Parameters:
    ///   - sectionController: 需要配置的sectionController
    ///   - completion: 刷新回调
    private func queuedInvalidateLayout(in sectionController: NestedSectionController, completion: ((_ finished: Bool) -> Void)?) {
        guard let targetSection = section(for: sectionController) else {
            completion?(false)
            return
        }
        isAllowedToCheckSectionTrait = false
        let sections = findInvalidateSectionsAndUpdateContentTrait(targetSection)
        if sections.isEmpty {
            scrollViewDidScroll(currentContainerView.scrollView)
            completion?(true)
            isAllowedToCheckSectionTrait = true
        } else {
            UIView.performWithoutAnimation {
                self.currentContainerView.scrollView.invalidateLayout(in: sections) { [weak self] finished in
                    guard let self = self else { return }
                    self.scrollViewDidScroll(self.currentContainerView.scrollView)
                    completion?(finished)
                    self.isAllowedToCheckSectionTrait = true
                }
            }
        }
    }

    /// 配置布局失效重置
    /// - Parameters:
    ///   - headerFooterViewController: 需要配置的页眉/页脚视图控制器
    ///   - completion: 刷新回调
    private func queuedInvalidateLayout(in headerFooterViewController: NestedHeaderFooterViewController, completion: ((_ finished: Bool) -> Void)?) {
        isAllowedToCheckSectionTrait = false
        updateContentTrait()
        UIView.animate(withDuration: 0, delay: 0, options: [], animations: {
            switch headerFooterViewController.style {
            case .header:
                self.setHeaderView(headerFooterViewController)
            case .footer:
                self.setFooterView(headerFooterViewController)
            }
        }, completion: {
            self.scrollViewDidScroll(self.currentContainerView.scrollView)
            completion?($0)
            self.isAllowedToCheckSectionTrait = true
        })
    }

    /// 容器尺寸发生变化
    func containerSizeDidChange() {
        guard !isInSectionUpdateTransaction else { return }
        isAllowedToCheckSectionTrait = false
        completionDispatcher.enterBatchUpdates()
        updateContentTrait()
        UIView.performWithoutAnimation {
            self.setHeaderView(self.headerController)
            self.setFooterView(self.footerController)
            self.currentContainerView.scrollView.invalidateLayout { [weak self] _ in
                guard let self = self else { return }
                self.scrollViewDidScroll(self.currentContainerView.scrollView)
                self.isAllowedToCheckSectionTrait = true
            }
        }
    }
}

extension NestedAdapter {
    /// 数据源更新刷新
    ///
    /// - Parameters:
    ///   - dataSource: 新数据源
    ///   - completion: 完成回调
    private func reload(dataSource: NestedAdapterDataSource, completion: ((_ finished: Bool) -> Void)?) {
        isAllowedToCheckSectionTrait = false
        let map = sectionMap
        // 去重section标识Model数据
        let uniqueModels = SectionTrait.duplicateRemoved(dataSource.sectionModels(for: self))

        // 使用去重的Models数据和旧特征数据创建新的特征数据集合，并获取需要重新加载的特征数据集合
        let (traits, reloadTraits) = SectionTrait.traits(models: uniqueModels, previousTraits: map.traits)

        // 生成转换数据
        let transitionData = generateTransitionData(traits: traits, reloadTraits: reloadTraits, dataSource: dataSource)

        // 使用动画更新数据
        UIView.animate(withDuration: 0, animations: {
            self.updateData(transitionData)
            self.setHeaderView(transitionData.headerController)
            self.currentContainerView.scrollView.reloadData()
            self.setFooterView(transitionData.footerController)
        }, completion: { [weak self] finished in
            guard let self = self else { return }
            self.scrollViewDidScroll(self.currentContainerView.scrollView)
            completion?(finished)
            self.completionDispatcher.exitBatchUpdates()
            if !map.traits.isEmpty {
                self.isAllowedToCheckSectionTrait = true
            }
        })
    }

    /// 全量更新数据
    private func updateData() {
        guard let dataSource = dataSource, nestedContainerView != nil else {
            return
        }
        completionDispatcher.enterBatchUpdates()

        // 在下一个循环中更新数据
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.reload(dataSource: dataSource, completion: nil)
        }
    }

    /// 更新空页面背景
    private func updateBackgroundView() {
        let shouldDisplay = sectionMap.isEmpty

        if shouldDisplay {
            let backgroundView = dataSource?.emptyView(for: self)
            if backgroundView != currentContainerView.scrollView.backgroundView {
                currentContainerView.scrollView.backgroundView?.removeFromSuperview()
                currentContainerView.scrollView.backgroundView = backgroundView
            }
        }
        currentContainerView.scrollView.backgroundView?.isHidden = !shouldDisplay
    }

    /// 更新数据
    ///
    /// - Parameter transitionData: 转换数据
    private func updateData(_ transitionData: NestedTransitionData) {
        isInSectionUpdateTransaction = true
        sectionMap.headerController = transitionData.headerController
        sectionMap.footerController = transitionData.footerController
        sectionMap.update(traits: transitionData.toTraits, controllers: transitionData.sectionControllers, for: currentContainerView.scrollView)
        // 通知每个特征数据已更新
        for trait in transitionData.reloadTraits {
            sectionMap.controller(for: trait)?.didUpdate(to: trait.model)
        }

        updateContentTrait(transitionData)
        updateBackgroundView()
        isInSectionUpdateTransaction = false
    }

    /// 计算转换数据
    /// - Parameters:
    ///   - traits: 特征数据
    ///   - reloadTraits: 需要刷新的特征数据
    ///   - dataSource: 数据源代理
    /// - Returns: 转换数据集合
    private func generateTransitionData(traits: [SectionTrait], reloadTraits: [SectionTrait], dataSource: NestedAdapterDataSource) -> NestedTransitionData {
        let map = sectionMap
        // 配置headerController
        let headerController = dataSource.headerController(for: self)
        headerController?.style = .header
        headerController?.containerContext = self
        headerController?.viewController = viewController
        // 配置footerController
        let footerController = dataSource.footerController(for: self)
        footerController?.style = .footer
        footerController?.containerContext = self
        footerController?.viewController = viewController
        var sectionControllers: [NestedSectionController] = []
        var validTraits: [SectionTrait] = []
        for trait in traits {
            // 如果是已存特征，从缓存中取出sectionController；如果没有，从数据源获取
            guard let controller = map.controller(for: trait) ?? dataSource.nestedAdapter(self, sectionControllerFor: trait.model) else {
                continue
            }
            controller.containerContext = self
            controller.viewController = viewController
            sectionControllers.append(controller)
            validTraits.append(map.trait(for: controller) ?? trait)
        }
        NestedLogger.shared.assert(
            Set(sectionControllers.map(ObjectIdentifier.init(_:))).count == sectionControllers.count,
            "Section controllers array is not filled with unique objects; section controllers are being reused"
        )
        return .init(
            fromTraits: map.traits,
            toTraits: validTraits,
            reloadTraits: reloadTraits,
            sectionControllers: sectionControllers,
            headerController: headerController,
            footerController: footerController
        )
    }

    /// 配置HeaderView
    /// - Parameter headerController: 新的headerController
    private func setHeaderView(_ headerController: NestedHeaderFooterViewController?) {
        let scrollView = currentContainerView.scrollView
        let frame = CGRect(origin: .zero, size: .init(width: scrollView.bounds.width, height: headerController?.headerFooterViewHeight() ?? 0))
        let headerView = headerController?.headerFooterView()
        headerView?.frame = frame
        scrollView.headerView = headerView
    }

    /// 配置FooterView
    /// - Parameter footerController: 新的footerController
    private func setFooterView(_ footerController: NestedHeaderFooterViewController?) {
        let scrollView = currentContainerView.scrollView
        let frame = CGRect(origin: .zero, size: .init(width: scrollView.bounds.width, height: footerController?.headerFooterViewHeight() ?? 0))
        let footerView = footerController?.headerFooterView()
        footerView?.frame = frame
        scrollView.footerView = footerView ?? {
            let view = UIView(frame: frame)
            view.backgroundColor = .clear
            return view
        }()
    }

    /// 通过刷新转换数据更新特征数据
    /// - Parameter transitionData: 当前刷新转换数据
    func updateContentTrait(_ transitionData: NestedTransitionData) {
        let headerHeight = transitionData.headerController?.headerFooterViewHeight() ?? 0
        var lastMaxY = headerHeight
        var lastEmbeddedMaxY = headerHeight
        for (section, trait) in transitionData.toTraits.enumerated() {
            defer {
                lastMaxY = trait.layoutAttributes.maxY
                lastEmbeddedMaxY = trait.layoutAttributes.embeddedMaxY
            }
            let controller = transitionData.sectionControllers[section]
            trait.layoutAttributes.section = section
            trait.layoutAttributes.minY = lastMaxY
            trait.layoutAttributes.headerHeight = controller.sectionHeaderHeight()
            trait.layoutAttributes.contentHeight = controller.sectionContentHeight()
            trait.layoutAttributes.footerHeight = controller.sectionFooterHeight()
            trait.layoutAttributes.embeddedScrollContentHeight = controller.embeddedScrollContentHeight()
            trait.layoutAttributes.embeddedMinY = lastEmbeddedMaxY
        }
        updateScrollIndicator(lastEmbeddedMaxY)
    }

    /// 从指定的 section 开始更新特征数据并查找需要使布局失效的 section
    ///
    /// - Parameter targetSection: 需要更新特征数据的 section 的索引
    /// - Returns: 需要使布局失效的 section 的索引数组
    private func findInvalidateSectionsAndUpdateContentTrait(_ targetSection: Int) -> [Int] {
        let headerHeight = headerController?.headerFooterViewHeight() ?? 0
        var lastMaxY = headerHeight
        var lastEmbeddedMaxY = headerHeight
        var sections: [Int] = []
        sectionMap.enumerate { trait, controller, processor, section, _ in
            defer {
                lastMaxY = trait.layoutAttributes.maxY
                lastEmbeddedMaxY = trait.layoutAttributes.embeddedMaxY
            }
            guard let controller = controller, section >= targetSection else {
                return
            }
            processor?.embeddedScrollView = controller.sectionEmbeddedScrollView()
            let layoutAttributes = trait.layoutAttributes
            trait.layoutAttributes.section = section
            trait.layoutAttributes.minY = lastMaxY
            trait.layoutAttributes.headerHeight = controller.sectionHeaderHeight()
            trait.layoutAttributes.contentHeight = controller.sectionContentHeight()
            trait.layoutAttributes.footerHeight = controller.sectionFooterHeight()
            trait.layoutAttributes.embeddedScrollContentHeight = controller.embeddedScrollContentHeight()
            trait.layoutAttributes.embeddedMinY = lastEmbeddedMaxY
            if layoutAttributes.invalidateLayout(trait.layoutAttributes) {
                sections.append(section)
            }
        }
        updateScrollIndicator(lastEmbeddedMaxY)
        return sections
    }

    /// 更新全量特征数据
    func updateContentTrait() {
        let headerHeight = headerController?.headerFooterViewHeight() ?? 0
        var lastMaxY = headerHeight
        var lastEmbeddedMaxY = headerHeight
        sectionMap.enumerate { trait, controller, processor, section, _ in
            defer {
                lastMaxY = trait.layoutAttributes.maxY
                lastEmbeddedMaxY = trait.layoutAttributes.embeddedMaxY
            }
            guard let controller = controller else {
                return
            }
            processor?.embeddedScrollView = controller.sectionEmbeddedScrollView()
            trait.layoutAttributes.section = section
            trait.layoutAttributes.minY = lastMaxY
            trait.layoutAttributes.headerHeight = controller.sectionHeaderHeight()
            trait.layoutAttributes.contentHeight = controller.sectionContentHeight()
            trait.layoutAttributes.footerHeight = controller.sectionFooterHeight()
            trait.layoutAttributes.embeddedScrollContentHeight = controller.embeddedScrollContentHeight()
            trait.layoutAttributes.embeddedMinY = lastEmbeddedMaxY
        }
        updateScrollIndicator(lastEmbeddedMaxY)
    }

    /// 更新滚动指示器
    /// - Parameter lastEmbeddedMaxY: 嵌套内容合集最大底部偏移量
    private func updateScrollIndicator(_ lastEmbeddedMaxY: CGFloat) {
        let maxHeight = lastEmbeddedMaxY + (footerController?.headerFooterViewHeight() ?? 0)
        nestedContainerView?.contentHeightDidChange(maxHeight)
    }

    /// 检查特征数据
    func checkContentTrait() {
        guard allowedToCheckSectionTrait() else { return }
        isAllowedToCheckSectionTrait = false
        let sections = findInvalidateSectionsAndUpdateContentTrait(0)
        if sections.isEmpty {
            isAllowedToCheckSectionTrait = true
        } else {
            UIView.performWithoutAnimation {
                self.currentContainerView.scrollView.invalidateLayout(in: sections) { [weak self] _ in
                    guard let self = self else { return }
                    self.scrollViewDidScroll(self.currentContainerView.scrollView)
                    self.isAllowedToCheckSectionTrait = true
                }
            }
        }
    }

    /// 检查是否允许执行检查节特性操作
    /// - Returns: 返回布尔值，表示是否允许执行检查节特性操作
    private func allowedToCheckSectionTrait() -> Bool {
        guard let nestedContainerView = nestedContainerView else { return false }
        return nestedContainerView.superview != nil && nestedContainerView.window != nil && isAllowedToCheckSectionTrait && allowedToCheckSectionTraitCondition()
    }
}

// MARK: - Public Sections, SectionModels

extension NestedAdapter {
    /// 返回headerView的控制器
    public var headerController: NestedHeaderFooterViewController? {
        return sectionMap.headerController
    }

    /// 返回footerView的控制器
    public var footerController: NestedHeaderFooterViewController? {
        return sectionMap.footerController
    }

    /// 获取指定section的控制器
    /// - Parameter section: section索引
    /// - Returns: section控制器
    public func sectionController(for section: Int) -> NestedSectionController? {
        return sectionMap.controller(for: section)
    }

    /// 查找控制器对应的section索引
    /// - Parameter sectionController: 当前section控制器
    /// - Returns: section索引位置
    public func section(for sectionController: NestedSectionController) -> Int? {
        return sectionMap.section(for: sectionController)
    }

    /// 查找控制器对应的section控制器
    /// - Parameter sectionModel: 当前section的信息数据Model
    /// - Returns: section控制器
    public func sectionController(for sectionModel: NestedSectionModel) -> NestedSectionController? {
        return sectionMap.controller(for: .init(model: .init(sectionModel)))
    }

    /// 查找section控制器对应的section信息数据Model
    /// - Parameter sectionController: 当前section控制器
    /// - Returns: Model
    public func sectionModel(for sectionController: NestedSectionController) -> NestedSectionModel? {
        return sectionMap.trait(for: sectionController)?.model
    }

    /// 根据给定的section索引查找section信息数据Model
    /// - Parameter section: section索引
    /// - Returns: Model
    public func sectionModel(at section: Int) -> NestedSectionModel? {
        return sectionMap.trait(for: section)?.model
    }

    /// 查找给定section信息数据Model对应的section索引
    /// - Parameter sectionModel: 当前section信息数据Model
    /// - Returns: section索引
    public func section(for sectionModel: NestedSectionModel) -> Int? {
        return sectionMap.section(for: .init(model: .init(sectionModel)))
    }

    /// 返回所有section的信息数据Model
    public var sectionModels: [NestedSectionModel] {
        return sectionMap.traits.map(\.model)
    }

    /// 返回可见的header和footer的控制器数组
    public var visibleHeaderFooterControllers: [NestedHeaderFooterViewController] {
        return displayHandler.visibleHeaderFooterControllers
    }

    /// 返回可见的section控制器数组
    public var visibleSectionControllers: [NestedSectionController] {
        return displayHandler.visibleSectionControllers
    }

    /// 返回可见的section信息数据Model数组
    public var visibleSectionModels: [NestedSectionModel] {
        let visibleSectionControllers = visibleSectionControllers
        var visibleTraits: [SectionTrait?] = []
        for sectionController in visibleSectionControllers {
            visibleTraits.append(sectionMap.trait(for: sectionController))
        }
        return visibleTraits.compactMap { $0?.model }
    }

    /// 返回可见的内容section控制器数组
    public var visibleContentSectionControllers: [NestedSectionController] {
        let visibleContentViews = currentContainerView.scrollView.visibleContentViews
        var visibleSectionControllers: [NestedSectionController?] = []
        for contentView in visibleContentViews {
            visibleSectionControllers.append(controller(for: contentView))
        }
        return visibleSectionControllers.compactMap { $0 }
    }

    /// 返回可见的内容section信息数据Model数组
    public var visibleContentSectionModels: [NestedSectionModel] {
        let visibleSectionControllers = visibleContentSectionControllers
        var visibleTraits: [SectionTrait?] = []
        for sectionController in visibleSectionControllers {
            visibleTraits.append(sectionMap.trait(for: sectionController))
        }
        return visibleTraits.compactMap { $0?.model }
    }
}

// MARK: - viewToControllerMap func

extension NestedAdapter {
    /// 将视图映射到指定的section控制器
    /// - Parameters:
    ///   - view: 要映射的视图
    ///   - controller: 目标section控制器
    func map(_ view: UIView, to controller: NestedSectionController) {
        viewToControllerMap.setObject(controller, forKey: view)
    }

    /// 获取视图对应的section控制器
    /// - Parameter view: 目标视图
    /// - Returns: 对应的section控制器
    func controller(for view: UIView) -> NestedSectionController? {
        return viewToControllerMap.object(forKey: view)
    }

    /// 移除视图的映射关系
    /// - Parameter view: 目标视图
    func removeMap(_ view: UIView) {
        viewToControllerMap.removeObject(forKey: view)
    }
}

// swiftlint:enable line_length file_length
