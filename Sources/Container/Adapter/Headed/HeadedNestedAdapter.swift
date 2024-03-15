//
//  HeadedNestedAdapter.swift
//
//
//  Created by 吴哲 on 2024/3/1.
//

import UIKit

// swiftlint:disable line_length identifier_name

/// 吸顶嵌套适配器，用于实现带有吸顶效果的嵌套列表
public final class HeadedNestedAdapter: NestedAdapter {
    /// 数据源
    public weak var headedDataSource: HeadedNestedAdapterDataSource? {
        didSet {
            guard oldValue !== headedDataSource else { return }
            loadHeadedDataSource()
            super.dataSource = self
        }
    }

    /// 表示是否自动显示嵌入滚动视图的滚动指示器
    public var automaticallyDisplayEmbeddedScrollIndicator: Bool = true {
        didSet {
            currentContainerView.scrollIndicator.isHidden = automaticallyDisplayEmbeddedScrollIndicator
            scrollProcessor?.automaticallyDisplayEmbeddedScrollIndicator = automaticallyDisplayEmbeddedScrollIndicator
        }
    }

    /// 表示刷新操作是否由嵌入的滚动视图处理
    public var refreshHandledByEmbeddedScrollView: Bool = false {
        didSet {
            currentContainerView.scrollView.bounces = !refreshHandledByEmbeddedScrollView
            scrollProcessor?.refreshHandledByEmbeddedScrollView = refreshHandledByEmbeddedScrollView
        }
    }

    /// 重写父类的数据源属性
    override public var dataSource: NestedAdapterDataSource? {
        didSet {
            NestedLogger.shared.assertionFailure("HeadedNestedAdapter 使用 headedDataSource: HeadedNestedAdapterDataSource")
        }
    }

    /// 重写父类的滚动处理类型属性
    override public var scrollProcessorType: NestedSectionScrollProcessor.Type? {
        didSet {
            NestedLogger.shared.assertionFailure("HeadedNestedAdapter 滚动计算方式固定，不支持自定义")
        }
    }

    /// HeaderView控制器
    private let headedHeaderController = HeadedNestedHeaderViewController()

    /// 嵌套内容控制器
    public var nestedSectionController: NestedSectionController {
        return headedContentController
    }

    /// 嵌套内容控制器
    private let headedContentController = HeadedNestedSectionController()

    private var scrollProcessor: HeadedScrollProcessor?

    /// 初始化方法
    /// - Parameter viewController: 包含适配器的视图控制器
    override public init(viewController: UIViewController) {
        super.init(viewController: viewController)
        sectionMap.createScrollProcessor = { [weak self] in
            self?.createScrollProcessor($0) ?? NestedSectionScrollProcessor(trait: $0)
        }
    }

    /// 计算容器尺寸
    /// - Parameter sectionController: 分区控制器
    /// - Returns: 容器尺寸
    override public func containerSize(for sectionController: NestedSectionController) -> CGSize {
        var size = super.containerSize(for: sectionController)
        if headedHeaderController.headerView != nil {
            size.height -= headedHeaderController.pinToVisibleHeight()
        }
        return size
    }

    /// 配置绑定嵌套容器
    /// - Parameter containerView: 容器
    override func setUpNestedContainerView(_ containerView: NestedContainerView) {
        super.setUpNestedContainerView(containerView)
        containerView.contentInsetAdjustmentBehavior = .never
        containerView.scrollView.bounces = !refreshHandledByEmbeddedScrollView
        containerView.scrollIndicator.isHidden = automaticallyDisplayEmbeddedScrollIndicator
    }

    /// 适配器刷新
    /// - Parameter completion: 回调
    override public func reloadData(completion: ((Bool) -> Void)? = nil) {
        loadHeadedDataSource()
        super.reloadData(completion: completion)
    }

    /// 嵌入滚动视图或者内容大小变动时调用此方法来更新布局
    /// - Parameter completion: 布局更新完成后的回调闭包，可选参数，默认为nil
    public func embeddedScrollViewDidChange(completion: ((_ finished: Bool) -> Void)? = nil) {
        invalidateLayout(in: headedContentController, completion: completion)
    }

    /// 配置布局无效重置
    /// - Parameter completion: 回调
    public func reloadHeaderView(completion: ((Bool) -> Void)? = nil) {
        invalidateLayout(in: headedHeaderController, completion: completion)
    }

    /// 配置布局无效重置
    /// - Parameter completion: 回调
    public func reloadSectionLayout(completion: ((Bool) -> Void)? = nil) {
        invalidateLayout(in: headedContentController, completion: completion)
    }

    /// 嵌入式滚动视图滚动时的事件回调
    /// - Parameter event: 嵌入式滚动视图事件
    public func embeddedScrollViewEvent(_ event: NestedEmbeddedScrollViewEvent) {
        embeddedScrollViewEvent(event, for: headedContentController)
    }

    /// 更新数据源
    private func loadHeadedDataSource() {
        // 设置头部视图
        headedHeaderController.headerView = headedDataSource?.headerView(for: self)
        if headedHeaderController.headerView != nil {
            scrollProcessor?.headerViewPinHeight = headedHeaderController.pinToVisibleHeight()
        } else {
            scrollProcessor?.headerViewPinHeight = 0
        }

        // 设置固定头部视图
        headedContentController.pinHeaderView = headedDataSource?.pinHeaderView(for: self)

        // 设置内容视图管理器
        headedContentController.management = headedDataSource?.contentViewManagement(for: self)
        // scrollProcessor?.management = headedContentController.management
    }

    /// 创建滚动处理器
    /// - Parameter trait: 分区特征
    /// - Returns: 创建的滚动处理器
    private func createScrollProcessor(_ trait: SectionTrait) -> HeadedScrollProcessor {
        if let scrollProcessor = scrollProcessor {
            return scrollProcessor
        } else {
            let scrollProcessor = HeadedScrollProcessor(trait: trait)
            scrollProcessor.automaticallyDisplayEmbeddedScrollIndicator = automaticallyDisplayEmbeddedScrollIndicator
            scrollProcessor.refreshHandledByEmbeddedScrollView = refreshHandledByEmbeddedScrollView
            if headedHeaderController.headerView != nil {
                scrollProcessor.headerViewPinHeight = headedHeaderController.pinToVisibleHeight()
            } else {
                scrollProcessor.headerViewPinHeight = 0
            }
            // scrollProcessor.management = headedContentController.management
            self.scrollProcessor = scrollProcessor
            return scrollProcessor
        }
    }
}

// MARK: - NestedAdapterDataSource Interceptor

extension HeadedNestedAdapter: NestedAdapterDataSource {
    /// Section信息
    public enum HeadedSection: SectionDifferentiable, CaseIterable {
        case list
    }

    /// 返回头部视图控制器
    /// - Parameter adapter: 适配器
    /// - Returns: 头部视图控制器
    public func headerController(for _: NestedAdapter) -> NestedHeaderFooterViewController? {
        guard headedHeaderController.headerView != nil else { return nil }
        return headedHeaderController
    }

    /// 返回分区模型数组
    /// - Parameter adapter: 适配器
    /// - Returns: 分区模型数组
    public func sectionModels(for _: NestedAdapter) -> [NestedSectionModel] {
        guard let headedDataSource = headedDataSource else { return [] }
        return HeadedSection.allCases.map(NestedSectionModel.init(_:))
    }

    /// 返回分区控制器
    /// - Parameters:
    ///   - adapter: 适配器
    ///   - sectionModel: 分区模型
    /// - Returns: 分区控制器
    public func nestedAdapter(_: NestedAdapter, sectionControllerFor _: NestedSectionModel) -> NestedSectionController? {
        guard headedContentController.management != nil || headedContentController.pinHeaderView != nil else { return nil }
        return headedContentController
    }

    /// 返回底部视图控制器
    /// - Parameter adapter: 适配器
    /// - Returns: 底部视图控制器
    public func footerController(for _: NestedAdapter) -> NestedHeaderFooterViewController? {
        return nil
    }

    /// 返回空视图
    /// - Parameter adapter: 适配器
    /// - Returns: 空视图
    public func emptyView(for _: NestedAdapter) -> UIView? {
        return headedDataSource?.emptyView(for: self)
    }
}

// swiftlint:enable line_length identifier_name
