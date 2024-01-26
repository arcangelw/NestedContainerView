//
//  NestedDisplayDelegate.swift
//
//
//  Created by 吴哲 on 2024/1/26.
//

import UIKit

// swiftlint:disable line_length

/// 嵌套控制器显示状态代理
public protocol NestedDisplayDelegate: AnyObject {
    /// 控制器即将展示
    ///
    /// - Parameters:
    ///   - nestedAdapter: 当前适配器
    ///   - sectionController: 当前控制器
    func nestedAdapter(_ nestedAdapter: NestedAdapter, willDisplay sectionController: NestedSectionController)

    /// 控制器结束展示
    ///
    /// - Parameters:
    ///   - nestedAdapter: 当前适配器
    ///   - sectionController: 当前控制器
    func nestedAdapter(_ nestedAdapter: NestedAdapter, didEndDisplaying sectionController: NestedSectionController)

    /// 控制器内容视图即将展示
    ///
    /// - Parameters:
    ///   - nestedAdapter: 当前适配器
    ///   - contentView: 内容视图
    ///   - sectionController: 当前控制器
    func nestedAdapter(_ nestedAdapter: NestedAdapter, willDisplay contentView: UIView, for sectionController: NestedSectionController)

    /// 控制器内容视图结束展示
    ///
    /// - Parameters:
    ///   - nestedAdapter: 当前适配器
    ///   - contentView: 内容视图
    ///   - sectionController: 当前控制器
    func nestedAdapter(_ nestedAdapter: NestedAdapter, didEndDisplaying contentView: UIView, for sectionController: NestedSectionController)

    /// 控制器悬浮headerView视图即将展示
    ///
    /// - Parameters:
    ///   - nestedAdapter: 当前适配器
    ///   - headerView: headerView视图
    ///   - sectionController: 当前控制器
    func nestedAdapter(_ nestedAdapter: NestedAdapter, willDisplayHeaderView headerView: UIView, for sectionController: NestedSectionController)

    /// 控制器悬浮headerView视图结束展示
    ///
    /// - Parameters:
    ///   - nestedAdapter: 当前适配器
    ///   - headerView: headerView视图
    ///   - sectionController: 当前控制器
    func nestedAdapter(_ nestedAdapter: NestedAdapter, didEndDisplayingHeaderView headerView: UIView, for sectionController: NestedSectionController)

    /// 控制器悬浮footerView视图即将展示
    ///
    /// - Parameters:
    ///   - nestedAdapter: 当前适配器
    ///   - headerView: footerView视图
    ///   - sectionController: 当前控制器
    func nestedAdapter(_ nestedAdapter: NestedAdapter, willDisplayFooterView footerView: UIView, for sectionController: NestedSectionController)

    /// 控制器悬浮footerView视图结束展示
    ///
    /// - Parameters:
    ///   - nestedAdapter: 当前适配器
    ///   - headerView: footerView视图
    ///   - sectionController: 当前控制器
    func nestedAdapter(_ nestedAdapter: NestedAdapter, didEndDisplayingFooterView footerView: UIView, for sectionController: NestedSectionController)
}

// swiftlint:enable line_length
