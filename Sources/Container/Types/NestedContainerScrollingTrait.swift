//
//  NestedContainerScrollingTrait.swift
//
//
//  Created by 吴哲 on 2024/2/1.
//

import UIKit

/// 滚动特征参数
public struct NestedContainerScrollingTrait: Hashable {
    /// 表示是否处于活跃状态，即滚动视图正在被用户触摸跟踪
    public private(set) var isTracking: Bool

    /// 表示是否处于拖拽状态，即滚动视图正在被用户拖拽滚动
    public private(set) var isDragging: Bool

    /// 表示是否处于减速状态，即滚动视图在用户停止拖拽后正在缓慢减速到停止
    public private(set) var isDecelerating: Bool

    /// 初始化滚动特征参数
    /// - Parameter ontainerScrollView: 通过滚动容器
    public init(containerScrollView: NestedContainerScrollView) {
        self.isTracking = containerScrollView.isTracking
        self.isDragging = containerScrollView.isDragging
        self.isDecelerating = containerScrollView.isDecelerating
    }

    /// 合并嵌套视图状态
    /// - Parameter embeddedScrollView: 嵌套容器视图
    mutating func merge(_ embeddedScrollView: UIScrollView) {
        isTracking = isTracking || embeddedScrollView.isTracking
        isDragging = isDragging || embeddedScrollView.isDragging
        isDecelerating = isDecelerating || embeddedScrollView.isDecelerating
    }
}
