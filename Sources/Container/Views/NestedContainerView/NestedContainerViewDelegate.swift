//
//  NestedContainerViewDelegate.swift
//
//
//  Created by 吴哲 on 2024/1/26.
//

import UIKit

// swiftlint:disable line_length

/// 容器代理协议
@objc
protocol NestedContainerViewDelegate: UIScrollViewDelegate {
    /// 返回指定section悬浮的headerView的高度
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - section: section索引
    /// - Returns: headerView的高度
    @objc
    optional func nestedContainerView(_ nestedContainerView: NestedContainerView, heightForHeaderInSection section: Int) -> CGFloat

    /// 返回指定section的内容View的高度
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - section: section索引
    /// - Returns: 内容View的高度
    @objc
    optional func nestedContainerView(_ nestedContainerView: NestedContainerView, heightForContentInSection section: Int) -> CGFloat

    /// 返回指定section悬浮的footerView的高度
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - section: section索引
    /// - Returns: footerView的高度
    @objc
    optional func nestedContainerView(_ nestedContainerView: NestedContainerView, heightForFooterInSection section: Int) -> CGFloat

    /// 当section节点的headerView即将显示时调用
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - view: 将显示的headerView
    ///   - section: section索引
    @objc
    optional func nestedContainerView(_ nestedContainerView: NestedContainerView, willDisplayHeaderView view: UIView, forSection section: Int)

    /// 当section节点的contentView即将显示时调用
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - view: 将显示的contentView
    ///   - section: section索引
    @objc
    optional func nestedContainerView(_ nestedContainerView: NestedContainerView, willDisplayContentView view: UIView, forSection section: Int)

    /// 当section节点的footerView即将显示时调用
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - view: 将显示的footerView
    ///   - section: section索引
    @objc
    optional func nestedContainerView(_ nestedContainerView: NestedContainerView, willDisplayFooterView view: UIView, forSection section: Int)

    /// 当section节点的headerView消失时调用
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - view: 已消失的headerView
    ///   - section: section索引
    @objc
    optional func nestedContainerView(_ nestedContainerView: NestedContainerView, didEndDisplayingHeaderView view: UIView, forSection section: Int)

    /// 当section节点的contentView消失时调用
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - view: 已消失的contentView
    ///   - section: section索引
    @objc
    optional func nestedContainerView(_ nestedContainerView: NestedContainerView, didEndDisplayingContentView view: UIView, forSection section: Int)

    /// 当section节点的footerView消失时调用
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - view: 已消失的footerView
    ///   - section: section索引
    @objc
    optional func nestedContainerView(_ nestedContainerView: NestedContainerView, didEndDisplayingFooterView view: UIView, forSection section: Int)
}

// swiftlint:enable line_length
