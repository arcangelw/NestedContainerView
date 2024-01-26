//
//  HorizontalNestedContentSectionController.swift
//
//
//  Created by 吴哲 on 2024/3/4.
//

import UIKit

/// 横向嵌套内容管理控制器
open class HorizontalNestedContentSectionController: NestedSectionController {
    /// 内容管理
    open var management: HorizontalNestedContentViewManagement?

    override public var scrollDelegate: UIScrollViewDelegate? {
        didSet {
            guard scrollDelegate != nil else { return }
            NestedLogger.shared.assert(scrollDelegate === self, "management.delegate.setHorizontalNestedScrollView需要处理")
        }
    }

    /// 初始化
    override public init() {
        super.init()
        self.scrollDelegate = self
    }

    /// 返回部分的内容视图
    override open func sectionContentView() -> UIView {
        guard let management = management else {
            return UIView()
        }
        guard let dataSource = management.dataSource else {
            NestedLogger.shared.assertionFailure("management.dataSource 不能为 nil")
            return UIView()
        }
        return dataSource.horizontalNestedContentView()
    }

    /// 返回内部滚动视图。
    override open func sectionEmbeddedScrollView() -> UIScrollView? {
        guard let management = management else {
            return nil
        }
        guard let dataSource = management.dataSource else {
            NestedLogger.shared.assertionFailure("management.dataSource 不能为 nil")
            return nil
        }
        return dataSource.currentEmbeddedScrollView()
    }

    /// 返回部分的内容视图高度模式
    override open func sectionContentHeightMode() -> NestedSectionContentHeightMode {
        guard let management = management else {
            return .fixed(.filled)
        }
        guard let dataSource = management.dataSource else {
            NestedLogger.shared.assertionFailure("management.dataSource 不能为 nil")
            return .fixed(.filled)
        }
        return .embedded(
            .filled,
            embeddedContentHeight: dataSource.currentEmbeddedScrollView()?.contentSize.height ?? 0
        )
    }
}

// MARK: - UIScrollViewDelegate

extension HorizontalNestedContentSectionController: UIScrollViewDelegate {
    /// 当用户开始拖拽滚动视图时调用
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView.isNestedContainerScrollView else { return }
        // 当用户开始上下滚动时，禁止左右滚动
        management?.delegate?.setHorizontalNestedScrollView(false)
    }

    /// 当用户停止拖拽滚动视图时调用
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView.isNestedContainerScrollView else { return }
        if !decelerate {
            // 如果用户停止拖动且不再减速，立即允许水平滚动
            management?.delegate?.setHorizontalNestedScrollView(true)
        }
    }

    /// 当滚动视图停止减速时调用
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView.isNestedContainerScrollView else { return }
        // 滚动停止后允许水平滚动
        management?.delegate?.setHorizontalNestedScrollView(true)
    }

    /// 当滚动动画停止时调用
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard scrollView.isNestedContainerScrollView else { return }
        // 滚动动画停止后允许水平滚动
        management?.delegate?.setHorizontalNestedScrollView(true)
    }
}
