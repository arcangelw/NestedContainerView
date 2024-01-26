//
//  SectionFrame.swift
//
//
//  Created by 吴哲 on 2024/2/29.
//

import UIKit

/// `SectionLayoutAttributes` 结构体表示 section 的布局信息
public struct SectionLayoutAttributes: Hashable {
    /// section 位置信息
    var section: Int
    /// 是否是嵌套内容
    var isEmbedded: Bool

    /// 悬浮 header 的高度
    var headerHeight: CGFloat
    /// 内容的高度
    var contentHeight: CGFloat
    /// 嵌入内容的高度
    var embeddedScrollContentHeight: CGFloat
    /// 悬浮 footer 的高度
    var footerHeight: CGFloat

    /// 相对容器的最小 Y 轴位置
    var minY: CGFloat
    /// 相对容器的最大 Y 轴位置
    var maxY: CGFloat {
        return minY + headerHeight + contentHeight + footerHeight
    }

    /// 叠加内嵌容器的最小 Y 轴位置
    var embeddedMinY: CGFloat
    /// 叠加内嵌容器的最大 Y 轴位置
    var embeddedMaxY: CGFloat {
        return embeddedMinY + headerHeight + max(contentHeight, embeddedScrollContentHeight) + footerHeight
    }

    /// 是否可滑动
    var canSlidable: Bool {
        return embeddedScrollContentHeight > contentHeight
    }

    /// 初始化布局信息
    /// - Parameters:
    ///   - section: 当前 section 的位置
    ///   - isEmbedded: 是否是嵌套内容
    ///   - headerHeight: 悬浮 header 的高度
    ///   - contentHeight: 内容的高度
    ///   - embeddedScrollContentHeight: 嵌入内容的高度
    ///   - footerHeight: 悬浮 footer 的高度
    ///   - minY: 相对容器的最小 Y 轴位置
    ///   - embeddedMinY: 叠加内嵌容器的最小 Y 轴位置
    init(
        section: Int = -1,
        isEmbedded: Bool = false,
        headerHeight: CGFloat = 0,
        contentHeight: CGFloat = 0,
        embeddedScrollContentHeight: CGFloat = 0,
        footerHeight: CGFloat = 0,
        minY: CGFloat = 0,
        embeddedMinY: CGFloat = 0
    ) {
        self.section = section
        self.isEmbedded = isEmbedded
        self.headerHeight = headerHeight
        self.contentHeight = contentHeight
        self.embeddedScrollContentHeight = embeddedScrollContentHeight
        self.footerHeight = footerHeight
        self.minY = minY
        self.embeddedMinY = embeddedMinY
    }
}

// MARK: - Comparable

extension SectionLayoutAttributes: Comparable {
    public static func < (lhs: SectionLayoutAttributes, rhs: SectionLayoutAttributes) -> Bool {
        lhs.section < rhs.section
    }
}

extension SectionLayoutAttributes {
    /// 判断布局是否无效
    ///
    /// - Parameter other: 另一个SectionLayoutAttributes对象，用于比较布局属性。
    /// - Returns: 如果布局无效，则返回true；否则返回false。
    func invalidateLayout(_ other: SectionLayoutAttributes) -> Bool {
        return headerHeight != other.headerHeight ||
            contentHeight != other.contentHeight ||
            footerHeight != other.footerHeight
    }

    /// 指示器偏移量计算
    /// - Parameters:
    ///   - scrollView: 容器scroll
    ///   - embeddedScrollView: 嵌套scroll
    /// - Returns: 指示器偏移量
    func indicatorOffset(_ scrollView: UIScrollView, embeddedScrollView: UIScrollView?) -> CGFloat {
        let offset = embeddedMinY + scrollView.contentOffset.y - minY
        if canSlidable, let embeddedScrollView = embeddedScrollView {
            return offset + embeddedScrollView.contentOffset.y
        }
        return offset
    }
}
