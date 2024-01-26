//
//  HeadedNestedAdapterDataSource.swift
//
//
//  Created by 吴哲 on 2024/3/1.
//

import UIKit

/// HeadedNestedAdapter 的头部视图协议。
public protocol HeadedNestedAdapterHeaderView: UIView {
    /// 头部视图的高度。
    var headerViewHeight: CGFloat { get }

    /// 头部视图固定悬浮时的高度。
    var headerViewPinHeight: CGFloat { get }
}

/// 增加默认实现。
extension HeadedNestedAdapterHeaderView {
    /// 头部视图固定悬浮时的高度，默认为 0.0。
    public var headerViewPinHeight: CGFloat { return 0 }
}

/// HeadedNestedAdapter 的固定悬浮头部视图协议。
public protocol HeadedNestedAdapterPinHeaderView: UIView {
    /// 固定悬浮头部视图的高度。
    var pinHeaderViewHeight: CGFloat { get }
}

/// HeadedNestedAdapter 的数据源协议。
public protocol HeadedNestedAdapterDataSource: AnyObject {
    /// 返回需要展示的 headerView。
    ///
    /// - Parameter nestedAdapter: 当前适配器。
    /// - Returns: 需要展示的 headerView，如果不需要展示则返回 `nil`。
    func headerView(for nestedAdapter: HeadedNestedAdapter) -> HeadedNestedAdapterHeaderView?

    /// 返回需要展示的固定悬浮 headerView。
    ///
    /// - Parameter nestedAdapter: 当前适配器。
    /// - Returns: 需要展示的固定悬浮 headerView，如果不需要展示则返回 `nil`。
    func pinHeaderView(for nestedAdapter: HeadedNestedAdapter) -> HeadedNestedAdapterPinHeaderView?

    /// 返回需要展示的 listView 的管理对象。
    ///
    /// - Parameter nestedAdapter: 当前适配器。
    /// - Returns: 需要展示的 listView 的管理对象，该对象需遵循 `HorizontalNestedContentViewManagement` 协议。如果不需要展示 listView，则返回 `nil`。
    func contentViewManagement(for nestedAdapter: HeadedNestedAdapter) -> HorizontalNestedContentViewManagement?

    /// 返回适配器没有内容时展示的空页面视图。
    ///
    /// - Parameter nestedAdapter: 当前适配器。
    /// - Returns: 当适配器没有内容时展示的空页面视图。
    func emptyView(for nestedAdapter: HeadedNestedAdapter) -> UIView?
}

/// 增加默认实现。
extension HeadedNestedAdapterDataSource {
    /// 返回需要展示的固定悬浮 headerView。
    ///
    /// - Parameter nestedAdapter: 当前适配器。
    /// - Returns: 需要展示的固定悬浮 headerView，如果不需要展示则返回 `nil`。
    public func pinHeaderView(for _: HeadedNestedAdapter) -> HeadedNestedAdapterPinHeaderView? { return nil }

    /// 返回适配器没有内容时展示的空页面视图。
    ///
    /// - Parameter nestedAdapter: 当前适配器。
    /// - Returns: 当适配器没有内容时展示的空页面视图。
    public func emptyView(for _: HeadedNestedAdapter) -> UIView? { return nil }
}
