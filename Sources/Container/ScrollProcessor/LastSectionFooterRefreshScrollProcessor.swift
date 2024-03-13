//
//  LastSectionFooterRefreshScrollProcessor.swift
//
//
//  Created by 吴哲 on 2024/3/4.
//

import UIKit

// swiftlint:disable line_length identifier_name

/// 将上拉刷新交给最后一组嵌套滚动视图Footer
public class LastSectionFooterRefreshScrollProcessor: NestedSectionScrollProcessor {
    override public var section: Int {
        didSet {
            NestedLogger.shared.assert(section <= 1, "这里特殊定制，只支持2组嵌套sectionController")
        }
    }

    /// 嵌套滚动视图
    override public var embeddedScrollView: UIScrollView? {
        didSet {
            embeddedScrollView?.showsVerticalScrollIndicator = false
            embeddedScrollView?.bounces = isLastSection
        }
    }

    /// 已加载的嵌入滚动视图。
    private var loadedEmbeddedScrollViews: [UIScrollView] {
        return management?.dataSource?.loadedEmbeddedScrollViews() ?? [embeddedScrollView].compactMap { $0 }
    }

    /// 上次嵌套滚动视图的内容偏移量
    private var lastScrollingEmbeddedScrollViewContentOffsetY: CGFloat = 0

    /// 容器滚动
    /// - Parameter containerScrollView: 主容器
    override public func containerScrollViewDidScroll(_ containerScrollView: NestedContainerScrollView) {
        guard let embeddedScrollView = embeddedScrollView else { return }
        guard isLastSection else {
            return containerScrollViewDidScroll(containerScrollView, embeddedScrollView: embeddedScrollView)
        }

        if embeddedScrollView.contentOffset.y > minContentOffsetYInEmbeddedScrollView(embeddedScrollView) {
            // 如果某个内嵌滚动视图开始滚动以至于containerScrollView的headerView滚动不可见，
            // 则固定containerScrollView的contentOffset，使其保持不动
            setContainerScrollViewToMaxContentOffsetY(containerScrollView, embeddedScrollView: embeddedScrollView)
        }

        if containerScrollView.contentOffset.y < containerScrollViewMaxContentOffsetY(containerScrollView, embeddedScrollView: embeddedScrollView) {
            // 如果containerScrollView已经显示了headerView，则需要重置所有内嵌滚动视图的contentOffset
            for scrollView in loadedEmbeddedScrollViews {
                // 当刷新是由containerScrollView处理时
                // 通知管理器将要重置内嵌滚动视图的contentOffset
                management?.delegate?.willResetEmbeddedScrollViewContentOffset(scrollView)
                // 将内嵌滚动视图的contentOffset重置为最小值
                setEmbeddedScrollViewToMinContentOffsetY(scrollView)
            }
        }

        if containerScrollView.contentOffset.y > containerScrollViewMaxContentOffsetY(containerScrollView, embeddedScrollView: embeddedScrollView) && embeddedScrollView.contentOffset.y == minContentOffsetYInEmbeddedScrollView(embeddedScrollView) {
            // 当向上滚动containerScrollView的headerView时，如果已滚动到底部，修复内嵌滚动视图轻微向上滚动的问题
            setContainerScrollViewToMaxContentOffsetY(containerScrollView, embeddedScrollView: embeddedScrollView)
        }
    }

    /// 当内嵌滚动视图发生滚动时调用的方法
    /// - Parameter embeddedScrollView: 滚动的内容视图
    override public func embeddedScrollViewDidScroll(_ embeddedScrollView: UIScrollView) {
        guard let containerScrollView = containerScrollView, isLastSection else { return }

        if containerScrollView.contentOffset.y < containerScrollViewMaxContentOffsetY(containerScrollView, embeddedScrollView: embeddedScrollView) {
            // 如果containerScrollView的headerView还没有完全消失，则将内嵌滚动视图的contentOffset保持为最小值
            management?.delegate?.willResetEmbeddedScrollViewContentOffset(embeddedScrollView)
            setEmbeddedScrollViewToMinContentOffsetY(embeddedScrollView)

        } else {
            // 如果containerScrollView的headerView刚好消失，则固定containerScrollView的位置，并显示内嵌滚动视图的滚动条
            setContainerScrollViewToMaxContentOffsetY(containerScrollView, embeddedScrollView: embeddedScrollView)
        }
    }

    /// 计算容器滚动视图的最大内容偏移量的Y坐标
    /// - Returns: 最大内容偏移量的Y坐标
    private func containerScrollViewMaxContentOffsetY(_ containerScrollView: NestedContainerScrollView, embeddedScrollView: UIScrollView) -> CGFloat {
        // 转换嵌入scroll相对位置
        if let contentContainerView = containerScrollView.contentContainerView(at: section) {
            let embeddedFrameY = contentContainerView.frame.minY - trait.layoutAttributes.headerHeight
            return abs(embeddedFrameY - trait.layoutAttributes.minY) <= .onePixel ? trait.layoutAttributes.minY : embeddedFrameY
        } else {
            return trait.layoutAttributes.minY
        }
    }

    /// 设置容器滚动视图的最大内容偏移量
    /// - Parameter containerScrollView: 容器滚动视图
    private func setContainerScrollViewToMaxContentOffsetY(_ containerScrollView: NestedContainerScrollView, embeddedScrollView: UIScrollView) {
        if !containerScrollView.callScrollsToTop {
            let offset = CGPoint(x: 0, y: containerScrollViewMaxContentOffsetY(containerScrollView, embeddedScrollView: embeddedScrollView))
            if offset != containerScrollView.contentOffset {
                containerScrollView.contentOffset = offset
            }
        }
    }

    /// 获取嵌套滚动视图的最小内容偏移量的Y坐标
    /// - Parameter embeddedScrollView: 嵌套滚动视图
    /// - Returns: 最小内容偏移量的Y坐标
    private func minContentOffsetYInEmbeddedScrollView(_ embeddedScrollView: UIScrollView) -> CGFloat {
        return -embeddedScrollView.adjustedContentInset.top
    }

    /// 设置嵌套滚动视图的内容偏移量为最小偏移量
    /// - Parameter embeddedScrollView: 嵌套滚动视图
    private func setEmbeddedScrollViewToMinContentOffsetY(_ embeddedScrollView: UIScrollView) {
        let offset = CGPoint(x: embeddedScrollView.contentOffset.x, y: minContentOffsetYInEmbeddedScrollView(embeddedScrollView))
        if offset != embeddedScrollView.contentOffset {
            embeddedScrollView.contentOffset = offset
        }
    }

    /// 非最后一组容器滚动
    /// - Parameters:
    ///   - containerScrollView: 当前容器
    ///   - embeddedScrollView: 当前嵌套容器
    private func containerScrollViewDidScroll(_ containerScrollView: NestedContainerScrollView, embeddedScrollView: UIScrollView) {
        guard
            trait.layoutAttributes.canSlidable,
            let embeddedSuperview = embeddedScrollView.superview,
            embeddedScrollView.window != nil
        else {
            return
        }
        guard !containerScrollView.callScrollsToTop else {
            setEmbeddedScrollViewToMinContentOffsetY(embeddedScrollView)
            return
        }
        // 容器偏移
        let offsetY = containerScrollView.contentOffset.y
        // section悬浮header高度 计算悬浮相对偏移
        let pinHeight = trait.layoutAttributes.headerHeight
        let pinOffsetY = offsetY + pinHeight
        // 转换嵌入scroll相对位置
        let embeddedFrameY = embeddedSuperview.convert(embeddedScrollView.frame.origin, to: containerScrollView).y
        // 相对位置偏移量差异
        let diff = pinOffsetY - embeddedFrameY
        // 嵌入scroll 最大偏移量
        let maxInnerScrollViewOffsetY = embeddedScrollView.contentSize.height - embeddedScrollView.frame.height
        // 嵌入scroll 当前偏移量
        let currentInnerScrollViewOffsetY = embeddedScrollView.contentOffset.y
        if currentInnerScrollViewOffsetY.isZero {
            // 内嵌scroll header边界处理
            if pinOffsetY > embeddedFrameY {
                embeddedScrollView.contentOffset.y += diff
                containerScrollView.contentOffset.y = embeddedFrameY - pinHeight
            }
        } else if currentInnerScrollViewOffsetY.isEqual(to: maxInnerScrollViewOffsetY) {
            // 内嵌scroll footer边界处理
            if pinOffsetY < embeddedFrameY {
                embeddedScrollView.contentOffset.y += diff
                containerScrollView.contentOffset.y = embeddedFrameY - pinHeight
            }
        } else {
            // 内嵌scroll 滚动处理
            let newInnerOffsetY = embeddedScrollView.contentOffset.y + diff
            if newInnerOffsetY < 0 {
                // header 固定
                embeddedScrollView.contentOffset.y = 0
                containerScrollView.contentOffset.y = embeddedFrameY + diff - pinHeight
            } else if newInnerOffsetY > maxInnerScrollViewOffsetY {
                // footer 固定
                embeddedScrollView.contentOffset.y = maxInnerScrollViewOffsetY
                containerScrollView.contentOffset.y = embeddedFrameY + diff - pinHeight
            } else {
                // 相对偏移计算
                embeddedScrollView.contentOffset.y = newInnerOffsetY
                containerScrollView.contentOffset.y = embeddedFrameY - pinHeight
            }
        }
    }
}

// swiftlint:enable line_length identifier_name
