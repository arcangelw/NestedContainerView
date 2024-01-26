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
    override public func containerScrollViewDidScroll(_ containerScrollView: UIScrollView) {
        guard
            trait.layoutAttributes.canSlidable,
            let embeddedScrollView = embeddedScrollView,
            let embeddedSuperview = embeddedScrollView.superview,
            embeddedScrollView.window != nil
        else {
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
