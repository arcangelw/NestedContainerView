//
//  DefaultScrollProcessor.swift
//
//
//  Created by 吴哲 on 2024/1/30.
//

import UIKit

/// 默认嵌套计算
public final class DefaultScrollProcessor: NestedSectionScrollProcessor {
    /// 嵌套滚动视图
    override public var embeddedScrollView: UIScrollView? {
        didSet {
            embeddedScrollView?.isScrollEnabled = false
        }
    }

    /// 容器滚动
    /// - Parameter containerScrollView: 主容器
    override public func containerScrollViewDidScroll(_ containerScrollView: NestedContainerScrollView) {
        guard
            trait.layoutAttributes.canSlidable,
            let embeddedScrollView = embeddedScrollView,
            let embeddedSuperview = embeddedScrollView.superview,
            embeddedScrollView.window != nil
        else {
            return
        }
        // 容器偏移
        // section悬浮header高度 计算悬浮相对偏移
        // 转换嵌入scroll相对位置
        // swiftlint:disable:next line_length
        let embeddedFrameY = embeddedSuperview.convert(embeddedScrollView.frame.origin, to: containerScrollView).y - trait.layoutAttributes.headerHeight
        // 相对位置偏移量差异
        let diff = containerScrollView.contentOffset.y - embeddedFrameY
        // 嵌入scroll 最大偏移量
        let maxEmbeddedScrollViewOffsetY = embeddedScrollView.contentSize.height - embeddedScrollView.frame.height
        // 嵌入scroll 当前偏移量
        let currentEmbeddedScrollViewOffsetY = embeddedScrollView.contentOffset.y
        if currentEmbeddedScrollViewOffsetY.isZero {
            // 内嵌scroll header边界处理
            if containerScrollView.contentOffset.y > embeddedFrameY {
                embeddedScrollView.contentOffset.y += diff
                containerScrollView.contentOffset.y = embeddedFrameY
            }
        } else if currentEmbeddedScrollViewOffsetY.isEqual(to: maxEmbeddedScrollViewOffsetY) {
            // 内嵌scroll footer边界处理
            if containerScrollView.contentOffset.y < embeddedFrameY {
                embeddedScrollView.contentOffset.y += diff
                containerScrollView.contentOffset.y = embeddedFrameY
            }
        } else {
            // 内嵌scroll 滚动处理
            let newEmbeddedOffsetY = embeddedScrollView.contentOffset.y + diff
            if newEmbeddedOffsetY < 0 {
                // header 固定
                embeddedScrollView.contentOffset.y = 0
                containerScrollView.contentOffset.y = embeddedFrameY + diff
            } else if newEmbeddedOffsetY > maxEmbeddedScrollViewOffsetY {
                // footer 固定
                embeddedScrollView.contentOffset.y = maxEmbeddedScrollViewOffsetY
                containerScrollView.contentOffset.y = embeddedFrameY + diff
            } else {
                // 相对偏移计算
                embeddedScrollView.contentOffset.y = newEmbeddedOffsetY
                containerScrollView.contentOffset.y = embeddedFrameY
            }
        }
    }

    /// 容器滚动到指定位置
    /// - Parameters:
    ///   - containerScrollView: 滚动容器视图
    ///   - position: 指定位置
    override public func containerScrollViewDidScroll(
        _ containerScrollView: NestedContainerScrollView, to position: NestedContainerScrollPosition
    ) {
        guard let embeddedScrollView = embeddedScrollView else { return }
        switch position {
        case .section(let section):
            if self.section < section {
                setEmbeddedScrollViewToMaxContentOffsetY(embeddedScrollView)
            } else {
                setEmbeddedScrollViewToMinContentOffsetY(embeddedScrollView)
            }
        case .header:
            setEmbeddedScrollViewToMinContentOffsetY(embeddedScrollView)
        case .footer:
            setEmbeddedScrollViewToMaxContentOffsetY(embeddedScrollView)
        }
    }
}
