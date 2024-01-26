//
//  NestedEmbeddedScrollViewEvent.swift
//
//
//  Created by 吴哲 on 2024/2/29.
//

import UIKit

/// 嵌入式滚动视图事件
/// 用于处理嵌入式滚动视图的各种事件
public enum NestedEmbeddedScrollViewEvent {
    /// 滚动视图正在滚动
    /// - scrollView: 正在滚动的滚动视图
    case didScroll(_ scrollView: UIScrollView)

    /// 将要开始拖动
    /// - scrollView: 即将被拖动的滚动视图
    case willBeginDragging(_ scrollView: UIScrollView)

    /// 已经结束拖动
    /// - scrollView: 已经结束拖动的滚动视图
    /// - decelerate: 是否需要减速
    case didEndDragging(_ scrollView: UIScrollView, decelerate: Bool)

    /// 已经结束减速
    /// - scrollView: 已经结束减速的滚动视图
    case didEndDecelerating(_ scrollView: UIScrollView)

    /// 当前滚动视图事件
    var scrollView: UIScrollView {
        switch self {
        case .didScroll(let scrollView): return scrollView
        case .willBeginDragging(let scrollView): return scrollView
        case .didEndDragging(let scrollView, _): return scrollView
        case .didEndDecelerating(let scrollView): return scrollView
        }
    }
}
