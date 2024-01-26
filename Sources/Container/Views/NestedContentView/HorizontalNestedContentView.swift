//
//  HorizontalNestedContentView.swift
//
//
//  Created by 吴哲 on 2024/3/1.
//

import UIKit

/// 水平嵌套内容容器的数据源协议。
public protocol HorizontalNestedContentViewDataSource: AnyObject {
    /// 获取当前的水平嵌套内容视图。
    func horizontalNestedContentView() -> UIView

    /// 获取当前嵌入的滚动视图。
    func currentEmbeddedScrollView() -> UIScrollView?

    /// 获取所有已加载的嵌入滚动视图。
    func loadedEmbeddedScrollViews() -> [UIScrollView]
}

/// 水平嵌套内容容器的事件代理协议。
public protocol HorizontalNestedContentViewDelegate: AnyObject {
    /// 将重置嵌入滚动视图的内容偏移量。
    func willResetEmbeddedScrollViewContentOffset(_ scrollView: UIScrollView)

    /// 配置水平嵌套列表的左右滑动是否启用。
    /// - Parameter isEnable: 是否启用左右滑动。
    func setHorizontalNestedScrollView(_ isEnable: Bool)
}

/// 水平嵌套内容管理协议。
public protocol HorizontalNestedContentViewManagement: AnyObject {
    /// 数据源。
    var dataSource: HorizontalNestedContentViewDataSource? { get }

    /// 事件代理。
    var delegate: HorizontalNestedContentViewDelegate? { get }
}
