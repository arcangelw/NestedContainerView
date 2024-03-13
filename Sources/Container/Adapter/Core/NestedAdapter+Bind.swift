//
//  NestedAdapter+Bind.swift
//
//
//  Created by 吴哲 on 2024/1/29.
//

import UIKit

// swiftlint:disable line_length file_length

// MARK: - NestedContainerViewDataSource

extension NestedAdapter: NestedContainerViewDataSource {
    /// 容器节点数据量
    /// - Parameter nestedContainerView: 当前容器
    /// - Returns: 节点数据
    func numberOfSections(in _: NestedContainerView) -> Int {
        return sectionMap.traits.count
    }

    /// section节点悬浮headerView
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - section: 所在section
    /// - Returns: headerView
    func nestedContainerView(_: NestedContainerView, viewForHeaderInSection section: Int) -> (trait: AnyObject, view: UIView)? {
        guard
            let trait = sectionMap.trait(for: section),
            let sectionController = sectionMap.controller(for: trait),
            let pinHeaderView = sectionController.sectionHeaderView()
        else {
            return nil
        }
        // 绑定已经展示的sectionController 和 pinHeaderView
        map(pinHeaderView, to: sectionController)
        return (trait, pinHeaderView)
    }

    /// section节点内容View
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - section: 所在section
    /// - Returns: contentView
    func nestedContainerView(_: NestedContainerView, viewForContentInSection section: Int) -> (trait: AnyObject, view: UIView) {
        guard
            let trait = sectionMap.trait(for: section),
            let sectionController = sectionMap.controller(for: trait)
        else {
            NestedLogger.shared.assertionFailure("can not find secton \(section)")
            return (NSObject(), UIView())
        }
        let contentView = sectionController.sectionContentView()
        // 绑定已经展示的sectionController 和 contentView
        map(contentView, to: sectionController)
        return (trait, contentView)
    }

    /// section节点悬浮footerView
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - section: 所在section
    /// - Returns: footerView
    func nestedContainerView(_: NestedContainerView, viewForFooterInSection section: Int) -> (trait: AnyObject, view: UIView)? {
        guard
            let trait = sectionMap.trait(for: section),
            let sectionController = sectionMap.controller(for: trait)
        else {
            return nil
        }
        let footerView: UIView?
        if sectionController.isLastSection {
            // 如果没有自定义pinFooterview 这里在最后一组配置footerView 优化滑动性能
            footerView = sectionController.sectionFooterView() ?? {
                let view = UIView(frame: .zero)
                view.backgroundColor = .clear
                return view
            }()
        } else {
            footerView = sectionController.sectionFooterView()
        }
        guard let footerView = footerView else { return nil }
        // 绑定已经展示的sectionController 和 pinFooterView
        map(footerView, to: sectionController)
        return (trait, footerView)
    }
}

// MARK: - NestedContainerViewDelegate

extension NestedAdapter: NestedContainerViewDelegate {
    /// section节点悬浮headerView高度
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - section: 所在section
    /// - Returns: headerView高度
    func nestedContainerView(_: NestedContainerView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionMap.trait(for: section)?.layoutAttributes.headerHeight ?? 0
    }

    /// section节点内容View高度
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - section: 所在section
    /// - Returns: contentView高度
    func nestedContainerView(_: NestedContainerView, heightForContentInSection section: Int) -> CGFloat {
        return sectionMap.trait(for: section)?.layoutAttributes.contentHeight ?? 0
    }

    /// section节点悬浮footerView高度
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - section: 所在section
    /// - Returns: footerView高度
    func nestedContainerView(_: NestedContainerView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionMap.trait(for: section)?.layoutAttributes.footerHeight ?? 0
    }

    // MARK: - Display

    /// section节点悬浮headerView即将显示
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - view: headerView
    ///   - section: 所在section
    func nestedContainerView(_: NestedContainerView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard
            let trait = sectionMap.trait(for: section)
        else {
            return
        }
        let sectionController: NestedSectionController?
        if let controller = controller(for: view) {
            sectionController = controller
        } else if let controller = sectionMap.controller(for: trait) {
            sectionController = controller
            // 绑定已经展示的sectionController 和 pinHeaderView
            map(view, to: controller)
        } else {
            sectionController = nil
        }
        guard let sectionController = sectionController else { return }
        displayHandler.nestedAdapter(self, willDisplaySectionHeaderView: view, for: sectionController, trait: trait, at: section)
    }

    /// section节点内容视图contentView即将显示
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - view: contentView
    ///   - section: 所在section
    func nestedContainerView(_: NestedContainerView, willDisplayContentView view: UIView, forSection section: Int) {
        guard
            let trait = sectionMap.trait(for: section)
        else {
            return
        }
        let sectionController: NestedSectionController?
        if let controller = controller(for: view) {
            sectionController = controller
        } else if let controller = sectionMap.controller(for: trait) {
            sectionController = controller
            // 绑定已经展示的sectionController 和 contentView
            map(view, to: controller)
        } else {
            sectionController = nil
        }
        guard let sectionController = sectionController else { return }
        displayHandler.nestedAdapter(self, willDisplayContentView: view, for: sectionController, trait: trait, at: section)
    }

    /// section节点悬浮footerView即将显示
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - view: footerView
    ///   - section: 所在section
    func nestedContainerView(_: NestedContainerView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard
            let trait = sectionMap.trait(for: section)
        else {
            return
        }
        let sectionController: NestedSectionController?
        if let controller = controller(for: view) {
            sectionController = controller
        } else if let controller = sectionMap.controller(for: trait) {
            sectionController = controller
            // 绑定已经展示的sectionController 和 pinFooterView
            map(view, to: controller)
        } else {
            sectionController = nil
        }
        guard let sectionController = sectionController else { return }
        displayHandler.nestedAdapter(self, willDisplaySectionFooterView: view, for: sectionController, trait: trait, at: section)
    }

    // MARK: - didEndDisplaying

    /// section节点悬浮headerView即将消失
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - view: headerView
    ///   - section: 所在section
    func nestedContainerView(_: NestedContainerView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        guard
            let trait = sectionMap.trait(for: section),
            let sectionController = controller(for: view)
        else {
            return
        }
        displayHandler.nestedAdapter(self, didEndDisplayingSectionHeaderView: view, for: sectionController, trait: trait, at: section)
        // 移除显示内容和sectionController的绑定
        removeMap(view)
    }

    /// section节点内容视图contentView即将消失
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - view: contentView
    ///   - section: 所在section
    func nestedContainerView(_: NestedContainerView, didEndDisplayingContentView view: UIView, forSection section: Int) {
        guard
            let trait = sectionMap.trait(for: section),
            let sectionController = controller(for: view)
        else {
            return
        }
        displayHandler.nestedAdapter(self, didEndDisplayingContentView: view, for: sectionController, trait: trait, at: section)
        // 移除显示内容和sectionController的绑定
        removeMap(view)
    }

    /// section节点悬浮footerView即将消失
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - view: footerView
    ///   - section: 所在section
    func nestedContainerView(_: NestedContainerView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        guard
            let trait = sectionMap.trait(for: section),
            let sectionController = controller(for: view)
        else {
            return
        }
        displayHandler.nestedAdapter(self, didEndDisplayingSectionFooterView: view, for: sectionController, trait: trait, at: section)
        // 移除显示内容和sectionController的绑定
        removeMap(view)
    }
}

// MARK: - UIScrollViewDelegate

extension NestedAdapter {
    /// 容器滚动
    /// - Parameter scrollView: 容器
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // adapter滚动代理回调
        scrollViewDelegate?.scrollViewDidScroll?(scrollView)

        // 计算headerView display状态
        if let headerController = sectionMap.headerController, let headerView = currentContainerView.scrollView.headerView {
            let isDisplayHeader = scrollView.contentOffset.y < headerView.frame.height
            if self.isDisplayHeader != isDisplayHeader {
                self.isDisplayHeader = isDisplayHeader
                if isDisplayHeader {
                    displayHandler.nestedAdapter(self, willDisplayHeaderFooterView: headerView, for: headerController)
                } else {
                    displayHandler.nestedAdapter(self, didEndDisplayingHeaderFooterView: headerView, for: headerController)
                }
            }
        }

        // 计算footerView display状态
        if let footerController = sectionMap.footerController, let footerView = currentContainerView.scrollView.footerView {
            let isDisplayFooter = scrollView.contentOffset.y + scrollView.bounds.height > (scrollView.contentSize.height - footerView.frame.height)
            if self.isDisplayFooter != isDisplayFooter {
                self.isDisplayFooter = isDisplayFooter
                if isDisplayFooter {
                    displayHandler.nestedAdapter(self, willDisplayHeaderFooterView: footerView, for: footerController)
                } else {
                    displayHandler.nestedAdapter(self, didEndDisplayingHeaderFooterView: footerView, for: footerController)
                }
            }
        }
        // 回调当前展示的 headerFooterController代理
        let visibleHeaderFooterControllers = visibleHeaderFooterControllers
        for visibleHeaderFooterController in visibleHeaderFooterControllers {
            visibleHeaderFooterController.scrollDelegate?.scrollViewDidScroll?(scrollView)
        }
        // 回调当前展示的 sectionController代理 计算嵌套内容滚动偏移
        let visibleSectionControllers = visibleSectionControllers
        for visibleSectionController in visibleSectionControllers {
            visibleSectionController.scrollDelegate?.scrollViewDidScroll?(scrollView)
            sectionMap.processor(for: visibleSectionController)?.containerScrollViewDidScroll(currentContainerView.scrollView)
        }
        // 刷新指示器
        reloadScrollIndicator(scrollView)
    }

    /// 容器开始拖拽
    /// - Parameter scrollView: 容器
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // adapter滚动代理回调
        scrollViewDelegate?.scrollViewWillBeginDragging?(scrollView)
        // 回调当前展示的 headerFooterController代理
        let visibleHeaderFooterControllers = visibleHeaderFooterControllers
        for visibleHeaderFooterController in visibleHeaderFooterControllers {
            visibleHeaderFooterController.scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
        }
        // 回调当前展示的 sectionController代理
        let visibleSectionControllers = visibleSectionControllers
        for visibleSectionController in visibleSectionControllers {
            visibleSectionController.scrollDelegate?.scrollViewWillBeginDragging?(scrollView)
        }
        // 刷新指示器
        reloadScrollIndicator(scrollView)
    }

    /// 容器停止拖拽
    /// - Parameters:
    ///   - scrollView: 容器
    ///   - decelerate: 是否进入减速
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // adapter滚动代理回调
        scrollViewDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        // 回调当前展示的 headerFooterController代理
        let visibleHeaderFooterControllers = visibleHeaderFooterControllers
        for visibleHeaderFooterController in visibleHeaderFooterControllers {
            visibleHeaderFooterController.scrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
        // 回调当前展示的 sectionController代理
        let visibleSectionControllers = visibleSectionControllers
        for visibleSectionController in visibleSectionControllers {
            visibleSectionController.scrollDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
        }
        // 刷新指示器
        reloadScrollIndicator(scrollView)
    }

    /// 容器停止减速
    /// - Parameter scrollView: 容器
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // adapter滚动代理回调
        scrollViewDelegate?.scrollViewDidEndDecelerating?(scrollView)
        // 回调当前展示的 headerFooterController代理
        let visibleHeaderFooterControllers = visibleHeaderFooterControllers
        for visibleHeaderFooterController in visibleHeaderFooterControllers {
            visibleHeaderFooterController.scrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
        }
        // 回调当前展示的 sectionController代理
        let visibleSectionControllers = visibleSectionControllers
        for visibleSectionController in visibleSectionControllers {
            visibleSectionController.scrollDelegate?.scrollViewDidEndDecelerating?(scrollView)
            sectionMap.processor(for: visibleSectionController)?.containerScrollViewDidEndDecelerating(currentContainerView.scrollView)
        }
        // 刷新指示器
        reloadScrollIndicator(scrollView)
    }

    /// 判断滚动视图是否应该滚动到顶部。
    /// - Parameter scrollView: 滚动视图。
    /// - Returns: 如果滚动视图应该滚动到顶部，则为true；否则为false。
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        let scrollsToTop = scrollViewDelegate?.scrollViewShouldScrollToTop?(scrollView) ?? true
        currentContainerView.scrollView.callScrollsToTop = scrollsToTop
        return scrollsToTop
    }

    /// 当滚动视图滚动到顶部时调用的方法。
    /// - Parameter scrollView: 滚动视图。
    public func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        currentContainerView.scrollView.callScrollsToTop = false
        scrollViewDelegate?.scrollViewDidScrollToTop?(scrollView)
        // 回调当前展示的 headerFooterController代理
        let visibleHeaderFooterControllers = visibleHeaderFooterControllers
        for visibleHeaderFooterController in visibleHeaderFooterControllers {
            visibleHeaderFooterController.scrollDelegate?.scrollViewDidScrollToTop?(scrollView)
        }
        // 回调当前展示的 sectionController代理 计算嵌套内容滚动偏移
        let visibleSectionControllers = visibleSectionControllers
        for visibleSectionController in visibleSectionControllers {
            visibleSectionController.scrollDelegate?.scrollViewDidScrollToTop?(scrollView)
        }
    }

    /// 容器结束滚动动画
    /// - Parameter scrollView: 容器
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        // adapter滚动代理回调
        scrollViewDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
        // 回调当前展示的 headerFooterController代理
        let visibleHeaderFooterControllers = visibleHeaderFooterControllers
        for visibleHeaderFooterController in visibleHeaderFooterControllers {
            visibleHeaderFooterController.scrollDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
        }
        // 回调当前展示的 sectionController代理
        let visibleSectionControllers = visibleSectionControllers
        for visibleSectionController in visibleSectionControllers {
            visibleSectionController.scrollDelegate?.scrollViewDidEndScrollingAnimation?(scrollView)
        }
        // 刷新指示器
        reloadScrollIndicator(scrollView)
    }

    /// 更新指示器偏移
    /// - Parameter scrollView: 容器
    func reloadScrollIndicator(_ scrollView: UIScrollView) {
        // 当前容器是否处于活跃状态
        var isActive = scrollView.isTracking || scrollView.isDragging || scrollView.isDecelerating
        // 容器有section展示 计算section 嵌套内容整体偏移
        // 容器没有section展示 场景对应footerView高度超过可视 取出最后一组section计算整体嵌套
        let lastSection = currentContainerView.scrollView.numberOfSections - 1
        let section = currentContainerView.scrollView.sectionsForVisibleContentViews.sorted().first ?? lastSection
        if section >= 0, let trait = sectionMap.trait(for: section) {
            let embeddedScrollView = sectionController(for: section)?.sectionEmbeddedScrollView()
            let offset = trait.layoutAttributes.indicatorOffset(scrollView, embeddedScrollView: embeddedScrollView)
            isActive = isActive || embeddedScrollView.map { $0.isTracking || $0.isDragging || $0.isDecelerating } ?? false
            scrollIndicator.didScroll(offset, isActive: isActive)
        } else {
            scrollIndicator.didScroll(scrollView.contentOffset.y, isActive: isActive)
        }
    }
}

// swiftlint:enable line_length file_length
