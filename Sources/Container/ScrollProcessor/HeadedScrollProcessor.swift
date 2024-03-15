//
//  HeadedScrollProcessor.swift
//
//
//  Created by 吴哲 on 2024/3/1.
//

import UIKit

// swiftlint:disable line_length identifier_name cyclomatic_complexity

/// 吸顶嵌套适配器的滚动处理器。
final class HeadedScrollProcessor: NestedSectionScrollProcessor {
    /// 表示是否自动显示嵌入滚动视图的滚动指示器
    var automaticallyDisplayEmbeddedScrollIndicator: Bool = true

    /// 表示刷新操作是否由嵌入的滚动视图处理
    var refreshHandledByEmbeddedScrollView: Bool = false

    /// 头部视图固定悬浮时的高度
    var headerViewPinHeight: CGFloat = 0

    /// 已加载的嵌入滚动视图。
    private var loadedEmbeddedScrollViews: [UIScrollView] {
        return management?.dataSource?.loadedEmbeddedScrollViews() ?? []
    }

    /// 上次嵌套滚动视图的内容偏移量
    private var lastScrollingEmbeddedScrollViewContentOffsetY: CGFloat = 0

    /// 当容器滚动视图发生滚动时调用的方法
    /// - Parameter containerScrollView: 滚动容器视图
    override func containerScrollViewDidScroll(_ containerScrollView: NestedContainerScrollView) {
        guard let embeddedScrollView = embeddedScrollView else { return }

        if headerViewPinHeight != 0, embeddedScrollView.contentOffset.y <= minContentOffsetYInEmbeddedScrollView(embeddedScrollView) {
            // 如果headerViewPinHeight不为零
            if refreshHandledByEmbeddedScrollView {
                // 当刷新是由embeddedScrollView处理时
                // 没有处于滚动某个embeddedScrollView的状态
                if containerScrollView.contentOffset.y <= 0 {
                    containerScrollView.bounces = false
                    containerScrollView.contentOffset = .zero
                    return
                } else {
                    containerScrollView.bounces = true
                }
            } else {
                // 当刷新是由containerScrollView处理时
                // 当前没有滚动任何内嵌滚动视图
                if containerScrollView.contentOffset.y >= headerViewPinHeight {
                    // 如果容器滚动视图的contentOffset.y超过了headerViewPinHeight，则将contentInset.top调整为headerViewPinHeight
                    adjustContainerScrollView(containerScrollView, toTargetContentInset: .init(top: headerViewPinHeight, left: 0, bottom: 0, right: 0))
                } else {
                    if isSetContainerScrollViewContentInsetToZeroEnabled(containerScrollView) {
                        // 否则，如果启用了将容器滚动视图的contentInset设置为零的选项，则将其调整为零
                        adjustContainerScrollView(containerScrollView, toTargetContentInset: .zero)
                    }
                }
            }
        }

        if embeddedScrollView.contentOffset.y > minContentOffsetYInEmbeddedScrollView(embeddedScrollView) {
            // 如果某个内嵌滚动视图开始滚动以至于containerScrollView的headerView滚动不可见，
            // 则固定containerScrollView的contentOffset，使其保持不动
            setContainerScrollViewToMaxContentOffsetY(containerScrollView)
        }

        if containerScrollView.contentOffset.y < containerScrollViewMaxContentOffsetY(containerScrollView) {
            // 如果containerScrollView已经显示了headerView，则需要重置所有内嵌滚动视图的contentOffset
            for scrollView in loadedEmbeddedScrollViews {
                if refreshHandledByEmbeddedScrollView {
                    // 当刷新是由embeddedScrollView处理时
                    // 正在下拉刷新时，不需要重置
                    if scrollView.contentOffset.y > minContentOffsetYInEmbeddedScrollView(scrollView) {
                        setEmbeddedScrollViewToMinContentOffsetY(scrollView)
                    }
                } else {
                    // 当刷新是由containerScrollView处理时
                    // 通知管理器将要重置内嵌滚动视图的contentOffset
                    management?.delegate?.willResetEmbeddedScrollViewContentOffset(scrollView)
                    // 将内嵌滚动视图的contentOffset重置为最小值
                    setEmbeddedScrollViewToMinContentOffsetY(scrollView)
                }
            }
        }

        if containerScrollView.contentOffset.y > containerScrollViewMaxContentOffsetY(containerScrollView) && embeddedScrollView.contentOffset.y == minContentOffsetYInEmbeddedScrollView(embeddedScrollView) {
            // 当向上滚动containerScrollView的headerView时，如果已滚动到底部，修复内嵌滚动视图轻微向上滚动的问题
            setContainerScrollViewToMaxContentOffsetY(containerScrollView)
        }
    }

    /// 容器滚动到指定位置
    /// - Parameters:
    ///   - containerScrollView: 滚动容器视图
    ///   - position: 指定位置
    override public func containerScrollViewDidScroll(_ containerScrollView: NestedContainerScrollView, to position: NestedContainerScrollPosition) {
        containerScrollViewDidScroll(containerScrollView)
    }

    /// 当容器滚动视图结束减速时调用的方法
    /// - Parameter containerScrollView: 滚动容器视图
    override func containerScrollViewDidEndDecelerating(_ containerScrollView: NestedContainerScrollView) {
        if isSetContainerScrollViewContentInsetToZeroEnabled(containerScrollView) {
            if containerScrollView.contentInset.top != 0 && headerViewPinHeight != 0 {
                // 如果容器滚动视图的contentInset.top不为零且headerViewPinHeight不为零,重置边距
                adjustContainerScrollView(containerScrollView, toTargetContentInset: .zero)
            }
        }
    }

    /// 当内嵌滚动视图发生滚动时调用的方法
    /// - Parameter embeddedScrollView: 滚动的内容视图
    override func embeddedScrollViewDidScroll(_ embeddedScrollView: UIScrollView) {
        guard let containerScrollView = containerScrollView else { return }

        if refreshHandledByEmbeddedScrollView {
            // 当刷新是由embeddedScrollView处理时
            var shouldProcess = true
            if embeddedScrollView.contentOffset.y > lastScrollingEmbeddedScrollViewContentOffsetY {
                // 向上滚动
            } else {
                // 向下滚动
                if containerScrollView.contentOffset.y == 0 {
                    shouldProcess = false
                } else {
                    if containerScrollView.contentOffset.y < containerScrollViewMaxContentOffsetY(containerScrollView) {
                        // containerScrollView的headerView还没消失，让embeddedScrollView一直为0
                        setEmbeddedScrollViewToMinContentOffsetY(embeddedScrollView)
                        embeddedScrollView.showsVerticalScrollIndicator = false
                    }
                }
            }
            if shouldProcess {
                if containerScrollView.contentOffset.y < containerScrollViewMaxContentOffsetY(containerScrollView) {
                    // 处于下拉刷新状态，embeddedScrollView.contentOffset.y 为负数，重置为0
                    if embeddedScrollView.contentOffset.y > minContentOffsetYInEmbeddedScrollView(embeddedScrollView) {
                        // containerScrollView的headerView还没有消失，让embeddedScrollView一直为0
                        setEmbeddedScrollViewToMinContentOffsetY(embeddedScrollView)
                        embeddedScrollView.showsVerticalScrollIndicator = false
                    }
                } else {
                    // containerScrollView的headerView刚好消失，固定containerScrollView位置，显示embeddedScrollView滚动条
                    setContainerScrollViewToMaxContentOffsetY(containerScrollView)
                    embeddedScrollView.showsVerticalScrollIndicator = true
                }
            }
            lastScrollingEmbeddedScrollViewContentOffsetY = embeddedScrollView.contentOffset.y
        } else {
            // 当刷新是由containerScrollView处理时
            if containerScrollView.contentOffset.y < containerScrollViewMaxContentOffsetY(containerScrollView) {
                // 如果containerScrollView的headerView还没有完全消失，则将内嵌滚动视图的contentOffset保持为最小值
                management?.delegate?.willResetEmbeddedScrollViewContentOffset(embeddedScrollView)
                setEmbeddedScrollViewToMinContentOffsetY(embeddedScrollView)

                if automaticallyDisplayEmbeddedScrollIndicator {
                    // 自动显示内嵌滚动视图的滚动条
                    embeddedScrollView.showsVerticalScrollIndicator = false
                }
            } else {
                // 如果containerScrollView的headerView刚好消失，则固定containerScrollView的位置，并显示内嵌滚动视图的滚动条
                setContainerScrollViewToMaxContentOffsetY(containerScrollView)

                if automaticallyDisplayEmbeddedScrollIndicator {
                    // 自动显示内嵌滚动视图的滚动条
                    embeddedScrollView.showsVerticalScrollIndicator = true
                }
            }
        }
    }

    /// 调整容器滚动视图的内容间距
    /// - Parameters:
    ///   - containerScrollView: 容器滚动视图
    ///   - contentInset: 目标内容间距
    private func adjustContainerScrollView(_ containerScrollView: UIScrollView, toTargetContentInset contentInset: UIEdgeInsets) {
        if containerScrollView.contentInset != contentInset {
            // 防止循环调用，先将代理设置为nil，然后再恢复原来的代理
            let oldDelegate = containerScrollView.delegate
            containerScrollView.delegate = nil
            containerScrollView.contentInset = contentInset
            containerScrollView.delegate = oldDelegate
        }
    }

    /// 该方法用于处理同时设置了 `headerViewPinHeight` 和添加了 `MJRefresh` 下拉刷新的特殊情况。
    /// 在这种情况下，`containerScrollView` 和 `MJRefresh` 会交替设置 `contentInset` 的值，导致抖动现象。
    /// 为了解决这个问题，我们在内部进行了特殊处理。
    /// 通过下面的判断条件，可以确定当前是否处于下拉刷新状态。
    /// 注意：请确保 `headerViewPinHeight` 和下拉刷新设置的 `contentInset.top` 值不相同，以避免出现抖动问题。
    /// 详细信息请参考：[GitHub Issue](https://github.com/pujiaxin33/JXPagingView/issues/203)
    private func isSetContainerScrollViewContentInsetToZeroEnabled(_ containerScrollView: UIScrollView) -> Bool {
        return !(containerScrollView.contentInset.top != 0 && containerScrollView.contentInset.top != CGFloat(headerViewPinHeight))
    }

    /// 计算容器滚动视图的最大内容偏移量的Y坐标
    /// - Returns: 最大内容偏移量的Y坐标
    override func containerScrollViewMaxContentOffsetY(_ containerScrollView: NestedContainerScrollView) -> CGFloat {
        let offsetY = super.containerScrollViewMaxContentOffsetY(containerScrollView)
        //  这里叠加悬浮高度
        return offsetY - headerViewPinHeight
    }
}

// swiftlint:enable line_length identifier_name cyclomatic_complexity
