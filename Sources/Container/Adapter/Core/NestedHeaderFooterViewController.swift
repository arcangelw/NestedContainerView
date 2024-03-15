//
//  NestedHeaderFooterViewController.swift
//
//
//  Created by 吴哲 on 2024/1/26.
//

import UIKit

/// 嵌套的页眉/页脚视图控制器
open class NestedHeaderFooterViewController: NSObject, NestedController {
    /// 页眉/页脚的样式。
    enum Style {
        case header
        case footer
    }

    /// 关联的视图控制器。
    public internal(set) weak var viewController: UIViewController?
    /// 关联的容器上下文。
    public internal(set) weak var containerContext: NestedContainerContext?

    /// 滚动视图的委托。
    public weak var scrollDelegate: UIScrollViewDelegate?

    /// 页眉/页脚的样式。
    var style: Style = .header

    /// 初始化方法。
    override public init() {
        super.init()
    }

    /// 返回页眉/页脚视图高度模式。
    ///
    /// - Returns: 页眉/页脚视图高度模式。
    open func headerFooterViewHeightMode() -> NestedContainerHeaderFooterViewHeightMode {
        return .fixed(.filled)
    }

    /// 返回页眉/页脚视图。
    ///
    /// - Returns: 页眉/页脚视图。
    open func headerFooterView() -> UIView {
        fatalError()
    }

    /// 配置布局无效重置
    /// - Parameter completion: 回调
    public func invalidateLayout(completion: ((Bool) -> Void)? = nil) {
        containerContext?.invalidateLayout(in: self, completion: completion)
    }

    /// 滚动容器到当前控制器
    ///
    /// - Parameters:
    ///   - animated: 是否需要动画效果
    ///   - completion: 滚动完成后的回调，参数为滚动是否完成的布尔值
    public func scrollContainerToCurrentController(animated: Bool = false, completion: ((_ finished: Bool) -> Void)? = nil) {
        containerContext?.scrollContainer(to: self, animated: animated, completion: completion)
    }

    /// 容器尺寸
    public func containerSize() -> CGSize {
        guard let context = containerContext else {
            NestedLogger.shared.assertionFailure("can no find containerContext")
            return .zero
        }
        let containerSize = context.containerSize
        return containerSize
    }

    /// 排除悬浮header/footer后全部填充高度
    /// - Returns: 内容高度
    public func filledHeight() -> CGFloat {
        return max(ceil(containerSize().height), 0)
    }

    /// 计算高度
    /// - Parameter mode: 高度模式
    /// - Returns: 高度
    public func height(for mode: NestedContentHeightMode) -> CGFloat {
        switch mode {
        case .absolute(let height): return height
        case .filled: return filledHeight()
        case .fractionalHeight(let fractional): return ceil(containerSize().height * fractional)
        }
    }

    /// 返回页眉/页脚视图的高度。
    ///
    /// - Returns: 页眉/页脚视图的高度。
    final func headerFooterViewHeight() -> CGFloat {
        switch headerFooterViewHeightMode() {
        case .fixed(let mode): return height(for: mode)
        case .pin(let mode, pinToVisibleHeightMode: _):
            // swiftlint:disable:next line_length
            NestedLogger.shared.assert(self is HeadedNestedHeaderViewController, "must use HeadedNestedHeaderViewController")
            return height(for: mode)
        }
    }

    /// 返回页眉/页脚视图固定到可见高度的高度。
    ///
    /// - Returns: 页眉/页脚视图固定到可见高度的高度。
    final func pinToVisibleHeight() -> CGFloat {
        if case .pin(_, pinToVisibleHeightMode: let mode) = headerFooterViewHeightMode() {
            return height(for: mode)
        }
        return 0
    }
}
