//
//  NestedContainerScrollingTrait.swift
//
//
//  Created by 吴哲 on 2024/2/1.
//

import UIKit

/// 滚动特征参数
public struct NestedContainerScrollingTrait {
    /// 表示是否处于活跃状态，即滚动视图正在被用户触摸跟踪
    public let isTracking: Bool

    /// 表示是否处于拖拽状态，即滚动视图正在被用户拖拽滚动
    public let isDragging: Bool

    /// 表示是否处于减速状态，即滚动视图在用户停止拖拽后正在缓慢减速到停止
    public let isDecelerating: Bool

    /// 初始化滚动特征参数
    ///
    /// - Parameters:
    ///   - isTracking: 是否处于活跃状态，默认为false
    ///   - isDragging: 是否处于拖拽状态，默认为false
    ///   - isDecelerating: 是否处于减速状态，默认为false
    public init(isTracking: Bool = false, isDragging: Bool = false, isDecelerating: Bool = false) {
        self.isTracking = isTracking
        self.isDragging = isDragging
        self.isDecelerating = isDecelerating
    }
}
