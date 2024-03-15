//
//  NestedSectionScrollProcessor.swift
//
//
//  Created by 吴哲 on 2024/2/23.
//

import UIKit

// swiftlint:disable line_length

/// 嵌套滚动计算器
open class NestedSectionScrollProcessor {
    /// 特征数据
    var trait: SectionTrait
    /// section位置
    public internal(set) var section: Int = 0
    /// 是否是第一组section
    public internal(set) var isFirstSection: Bool = false
    /// 是否是最后一组section
    public internal(set) var isLastSection: Bool = false

    /// 布局数据
    public var layoutAttributes: SectionLayoutAttributes {
        return trait.layoutAttributes
    }

    /// 容器滚动视图
    public internal(set) weak var containerScrollView: NestedContainerScrollView?

    /// 横向内容管理
    public weak var management: HorizontalNestedContentViewManagement?

    /// 嵌套滚动视图
    open internal(set) weak var embeddedScrollView: UIScrollView?

    /// 初始化计算器
    /// - Parameter trait: setion特征数据
    public required init(trait: SectionTrait) {
        self.trait = trait
    }

    /// 容器滚动
    /// - Parameter containerScrollView: 滚动容器视图
    open func containerScrollViewDidScroll(_: NestedContainerScrollView) {}

    /// 容器结束减速
    /// - Parameter containerScrollView: 滚动容器视图
    open func containerScrollViewDidEndDecelerating(_: NestedContainerScrollView) {}

    /// 容器滚动到指定位置
    /// - Parameters:
    ///   - containerScrollView: 滚动容器视图
    ///   - position: 指定位置
    open func containerScrollViewDidScroll(_ containerScrollView: NestedContainerScrollView, to position: NestedContainerScrollPosition) {}

    /// 内容滚动
    /// - Parameter embeddedScrollView: 滚动的内容视图
    open func embeddedScrollViewDidScroll(_: UIScrollView) {}

    /// 计算容器滚动视图的最大内容偏移量的Y坐标
    /// - Returns: 最大内容偏移量的Y坐标
    public func containerScrollViewMaxContentOffsetY(_ containerScrollView: NestedContainerScrollView) -> CGFloat {
        // 转换嵌入scroll相对位置
        let embeddedFrameY: CGFloat
        if let contentContainerView = containerScrollView.contentContainerView(at: section) {
            let minY = contentContainerView.frame.minY - trait.layoutAttributes.headerHeight
            embeddedFrameY = abs(minY - trait.layoutAttributes.minY) <= .onePixel ? trait.layoutAttributes.minY : minY
        } else {
            embeddedFrameY = trait.layoutAttributes.minY
        }
        return embeddedFrameY
    }

    /// 设置容器滚动视图的最大内容偏移量
    /// - Parameter containerScrollView: 容器滚动视图
    public func setContainerScrollViewToMaxContentOffsetY(_ containerScrollView: NestedContainerScrollView) {
        if !containerScrollView.callScrollsToTop {
            let offset = CGPoint(x: 0, y: containerScrollViewMaxContentOffsetY(containerScrollView))
            if offset != containerScrollView.contentOffset {
                containerScrollView.contentOffset = offset
            }
        }
    }

    /// 获取嵌套滚动视图的最小内容偏移量的Y坐标
    /// - Parameter embeddedScrollView: 嵌套滚动视图
    /// - Returns: 最小内容偏移量的Y坐标
    public func minContentOffsetYInEmbeddedScrollView(_ embeddedScrollView: UIScrollView) -> CGFloat {
        return -embeddedScrollView.adjustedContentInset.top
    }

    /// 设置嵌套滚动视图的内容偏移量为最小偏移量
    /// - Parameters:
    ///   - embeddedScrollView: 嵌套滚动视图
    ///   - animated: 是否动画
    public func setEmbeddedScrollViewToMinContentOffsetY(_ embeddedScrollView: UIScrollView, animated: Bool = false) {
        let offset = CGPoint(x: embeddedScrollView.contentOffset.x, y: minContentOffsetYInEmbeddedScrollView(embeddedScrollView))
        if offset != embeddedScrollView.contentOffset {
            embeddedScrollView.setContentOffset(offset, animated: animated)
        }
    }

    /// 获取嵌套滚动视图的最大内容偏移量的Y坐标
    /// - Parameter embeddedScrollView: 嵌套滚动视图
    /// - Returns: 最大内容偏移量的Y坐标
    public func maxContentOffsetYInEmbeddedScrollView(_ embeddedScrollView: UIScrollView) -> CGFloat {
        return embeddedScrollView.contentSize.height - embeddedScrollView.bounds.height + embeddedScrollView.adjustedContentInset.bottom
    }

    /// 设置嵌套滚动视图的内容偏移量为最大偏移量
    /// - Parameters:
    ///   - embeddedScrollView: 嵌套滚动视图
    ///   - animated: 是否动画
    public func setEmbeddedScrollViewToMaxContentOffsetY(_ embeddedScrollView: UIScrollView, animated: Bool = false) {
        let offset = CGPoint(x: embeddedScrollView.contentOffset.x, y: maxContentOffsetYInEmbeddedScrollView(embeddedScrollView))
        if offset != embeddedScrollView.contentOffset {
            embeddedScrollView.setContentOffset(offset, animated: animated)
        }
    }
}

// swiftlint:enable line_length
