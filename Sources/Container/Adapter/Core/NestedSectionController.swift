//
//  NestedSectionController.swift
//
//
//  Created by 吴哲 on 2024/1/26.
//

import UIKit

/// 嵌套分区控制器
open class NestedSectionController: NSObject, NestedController {
    /// 关联的视图控制器。
    public internal(set) weak var viewController: UIViewController?
    /// 关联的容器上下文。
    public internal(set) weak var containerContext: NestedContainerContext?

    /// 分区索引。
    public internal(set) var section: Int = -1 {
        didSet {
            guard oldValue != section else { return }
            sectionDidChange()
        }
    }

    /// 是否为第一个分区。
    public internal(set) var isFirstSection: Bool = false
    /// 是否为最后一个分区。
    public internal(set) var isLastSection: Bool = false

    /// 显示委托。
    public weak var displayDelegate: NestedDisplayDelegate?

    /// 滚动视图委托。
    public weak var scrollDelegate: UIScrollViewDelegate?

    /// 初始化方法。
    override public init() {
        super.init()
    }

    /// 分区索引发生变化时调用的方法。
    open func sectionDidChange() {}

    /// 更新到指定的分区模型时调用的方法。
    ///
    /// - Parameter sectionModel: 新的分区模型。
    open func didUpdate(to _: NestedSectionModel) {}

    /// 返回页眉的固定高度。
    ///
    /// - Returns: 页眉的固定高度。
    open func sectionHeaderHeight() -> CGFloat {
        return 0
    }

    /// 返回页眉视图。
    ///
    /// - Returns: 页眉视图。
    open func sectionHeaderView() -> UIView? {
        return nil
    }

    /// 返回内容高度模式。
    ///
    /// - Returns: 内容高度模式。
    open func sectionContentHeightMode() -> NestedSectionContentHeightMode {
        return .fixed(.filled)
    }

    /// 返回内容视图。
    ///
    /// - Returns: 内容视图。
    open func sectionContentView() -> UIView {
        fatalError("Subclass implementation")
    }

    /// 返回内部滚动视图。
    ///
    /// - Returns: 内部滚动视图。
    open func sectionEmbeddedScrollView() -> UIScrollView? {
        return nil
    }

    /// 返回页脚的固定高度。
    ///
    /// - Returns: 页脚的固定高度。
    open func sectionFooterHeight() -> CGFloat {
        return 0
    }

    /// 返回页脚视图。
    ///
    /// - Returns: 页脚视图。
    open func sectionFooterView() -> UIView? {
        return nil
    }

    /// 配置布局无效重置
    /// - Parameter completion: 回调
    public func invalidateLayout(completion: ((Bool) -> Void)? = nil) {
        containerContext?.invalidateLayout(in: self, completion: completion)
    }

    /// 内部滚动视图发生滚动时调用的方法
    ///
    /// - Parameter event: 嵌入式滚动视图事件
    public func embeddedScrollViewEvent(_ event: NestedEmbeddedScrollViewEvent) {
        containerContext?.embeddedScrollViewEvent(event, for: self)
    }

    /// 滚动容器到当前控制器
    ///
    /// - Parameters:
    ///   - animated: 是否需要动画效果
    ///   - completion: 滚动完成后的回调，参数为滚动是否完成的布尔值
    public func scrollContainerToCurrentController(
        animated: Bool = true,
        completion: ((_ finished: Bool) -> Void)? = nil
    ) {
        containerContext?.scrollContainer(to: self, animated: animated, completion: completion)
    }

    /// 容器尺寸
    public func containerSize() -> CGSize {
        guard let context = containerContext else {
            NestedLogger.shared.assertionFailure("can no find containerContext")
            return .zero
        }
        let containerSize = context.containerSize(for: self)
        return containerSize
    }

    /// 排除悬浮header/footer后全部填充高度
    /// - Returns: 内容高度
    public func filledHeight() -> CGFloat {
        return max(ceil(containerSize().height) - sectionHeaderHeight() - sectionFooterHeight(), 0)
    }

    /// 计算高度
    /// - Parameter mode: 高度模式
    /// - Returns: 高度
    public func height(for mode: NestedContentHeightMode) -> CGFloat {
        switch mode {
        case .absolute(let height): return max(0, height)
        case .filled: return filledHeight()
        case .fractionalHeight(let fractional): return ceil(containerSize().height * fractional)
        }
    }

    // MARK: - internal

    /// 返回分区内容的高度。
    ///
    /// - Returns: 分区内容的高度。
    func sectionContentHeight() -> CGFloat {
        switch sectionContentHeightMode() {
        case .fixed(let mode): return max(.onePixel, height(for: mode))
        case .embedded(let mode, embeddedContentHeight: let contentHeight):
            if let mode = mode {
                return max(.onePixel, height(for: mode))
            } else {
                return min(max(.onePixel, filledHeight()), max(.onePixel, ceil(contentHeight)))
            }
        }
    }

    /// 返回内部嵌套内容的高度。
    ///
    /// - Returns: 内部内容的高度。
    func embeddedScrollContentHeight() -> CGFloat {
        switch sectionContentHeightMode() {
        case .fixed(let mode): return height(for: mode)
        case .embedded(_, embeddedContentHeight: let contentHeight):
            return max(0, ceil(contentHeight))
        }
    }
}

// MARK: - NestedDisplayDelegate

extension NestedSectionController {
    /// 当嵌套适配器即将显示时调用
    func willDisplay(nestedAdapter: NestedAdapter) {
        displayDelegate?.nestedAdapter(nestedAdapter, willDisplay: self)
    }

    /// 当嵌套适配器结束显示时调用
    func endDisplaying(nestedAdapter: NestedAdapter) {
        displayDelegate?.nestedAdapter(nestedAdapter, didEndDisplaying: self)
    }

    /// 当内容视图即将显示时调用
    func willDisplay(contentView: UIView, for nestedAdapter: NestedAdapter) {
        displayDelegate?.nestedAdapter(nestedAdapter, willDisplay: contentView, for: self)
    }

    /// 当内容视图结束显示时调用
    func endDisplaying(contentView: UIView, for nestedAdapter: NestedAdapter) {
        displayDelegate?.nestedAdapter(nestedAdapter, didEndDisplaying: contentView, for: self)
    }

    /// 当标头视图即将显示时调用
    func willDisplay(headerView: UIView, for nestedAdapter: NestedAdapter) {
        displayDelegate?.nestedAdapter(nestedAdapter, willDisplayHeaderView: headerView, for: self)
    }

    /// 当标头视图结束显示时调用
    func endDisplaying(headerView: UIView, for nestedAdapter: NestedAdapter) {
        displayDelegate?.nestedAdapter(nestedAdapter, didEndDisplayingHeaderView: headerView, for: self)
    }

    /// 当页脚视图即将显示时调用
    func willDisplay(footerView: UIView, for nestedAdapter: NestedAdapter) {
        displayDelegate?.nestedAdapter(nestedAdapter, willDisplayFooterView: footerView, for: self)
    }

    /// 当页脚视图结束显示时调用
    func endDisplaying(footerView: UIView, for nestedAdapter: NestedAdapter) {
        displayDelegate?.nestedAdapter(nestedAdapter, didEndDisplayingFooterView: footerView, for: self)
    }
}
