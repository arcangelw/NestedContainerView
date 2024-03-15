//
//  NestedAdapterDataSource.swift
//
//
//  Created by 吴哲 on 2024/1/26.
//

import UIKit

// swiftlint:disable line_length

/// 嵌套适配器数据源协议
public protocol NestedAdapterDataSource: AnyObject {
    /// 返回需要展示的HeaderView控制器。
    ///
    /// - Parameter nestedAdapter: 当前适配器。
    /// - Returns: 需要展示的HeaderView控制器，如果不需要展示则返回 `nil`。
    func headerController(for nestedAdapter: NestedAdapter) -> NestedHeaderFooterViewController?

    /// 返回需要展示的section信息数据模型数组。
    ///
    /// - Parameter nestedAdapter: 当前适配器。
    /// - Returns: 需要展示的section信息数据模型数组。
    func sectionModels(for nestedAdapter: NestedAdapter) -> [NestedSectionModel]

    /// 返回对应section数据模型的控制器。
    ///
    /// - Parameters:
    ///   - nestedAdapter: 当前适配器。
    ///   - sectionModel: 当前section的信息数据模型。
    /// - Returns: 对应的section控制器。
    func nestedAdapter(_ nestedAdapter: NestedAdapter, sectionControllerFor sectionModel: NestedSectionModel) -> NestedSectionController?

    /// 返回需要展示的FooterView控制器。
    ///
    /// - Parameter nestedAdapter: 当前适配器。
    /// - Returns: 需要展示的FooterView控制器，如果不需要展示则返回 `nil`。
    func footerController(for nestedAdapter: NestedAdapter) -> NestedHeaderFooterViewController?

    /// 返回适配器没有内容时展示的空页面视图。
    ///
    /// - Parameter nestedAdapter: 当前适配器。
    /// - Returns: 当适配器没有内容时展示的空页面视图。
    func emptyView(for nestedAdapter: NestedAdapter) -> UIView?
}

/// 默认实现
extension NestedAdapterDataSource {
    /// 返回需要展示的HeaderView控制器。
    ///
    /// - Parameter nestedAdapter: 当前适配器。
    /// - Returns: 需要展示的HeaderView控制器，如果不需要展示则返回 `nil`。
    public func headerController(for nestedAdapter: NestedAdapter) -> NestedHeaderFooterViewController? { return nil }

    /// 返回需要展示的FooterView控制器。
    ///
    /// - Parameter nestedAdapter: 当前适配器。
    /// - Returns: 需要展示的FooterView控制器，如果不需要展示则返回 `nil`。
    public func footerController(for nestedAdapter: NestedAdapter) -> NestedHeaderFooterViewController? { return nil }

    /// 返回适配器没有内容时展示的空页面视图。
    ///
    /// - Parameter nestedAdapter: 当前适配器。
    /// - Returns: 当适配器没有内容时展示的空页面视图。
    public func emptyView(for nestedAdapter: NestedAdapter) -> UIView? { return nil }
}

// swiftlint:enable line_length
