//
//  NestedAdapterDelegate.swift
//
//
//  Created by 吴哲 on 2024/1/26.
//

import UIKit

// swiftlint:disable line_length

/// 嵌套适配器代理回调协议
public protocol NestedAdapterDelegate: AnyObject {
    /// 当前section的信息数据模型即将显示
    ///
    /// - Parameters:
    ///   - nestedAdapter: 当前适配器
    ///   - sectionModel: 当前section的信息数据模型
    ///   - section: 对应的section位置
    func nestedAdapter(_ nestedAdapter: NestedAdapter, willDisplay sectionModel: NestedSectionModel, at section: Int)

    /// 当前section的信息数据模型展示结束
    ///
    /// - Parameters:
    ///   - nestedAdapter: 当前适配器
    ///   - sectionModel: 当前section的信息数据模型
    ///   - section: 对应的section位置
    func nestedAdapter(_ nestedAdapter: NestedAdapter, didEndDisplaying sectionModel: NestedSectionModel, at section: Int)

    /// HeaderFooterView控制器即将显示
    ///
    /// - Parameters:
    ///   - nestedAdapter: 当前适配器
    ///   - headerFooterViewController: HeaderFooterView控制器
    func nestedAdapter(_ nestedAdapter: NestedAdapter, willDisplay headerFooterViewController: NestedHeaderFooterViewController)

    /// HeaderFooterView控制器展示结束
    ///
    /// - Parameters:
    ///   - nestedAdapter: 当前适配器
    ///   - headerFooterViewController: HeaderFooterView控制器
    func nestedAdapter(_ nestedAdapter: NestedAdapter, didEndDisplaying headerFooterViewController: NestedHeaderFooterViewController)
}

// swiftlint:enable line_length
