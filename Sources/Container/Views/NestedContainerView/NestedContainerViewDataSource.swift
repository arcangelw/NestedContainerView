//
//  NestedContainerViewDataSource.swift
//
//
//  Created by 吴哲 on 2024/1/26.
//

import UIKit

// swiftlint:disable line_length

/// 容器数据协议
protocol NestedContainerViewDataSource: AnyObject {
    /// 容器节点数据量
    /// - Parameter nestedContainerView: 当前容器
    /// - Returns: 节点数据
    func numberOfSections(in nestedContainerView: NestedContainerView) -> Int

    /// 返回指定section悬浮的headerView
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - section: section索引
    /// - Returns: 悬浮的headerView的trait和视图
    func nestedContainerView(_ nestedContainerView: NestedContainerView, viewForHeaderInSection section: Int) -> (trait: AnyObject, view: UIView)?

    /// 返回指定section的内容View
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - section: section索引
    /// - Returns: 内容View的trait和视图
    func nestedContainerView(_ nestedContainerView: NestedContainerView, viewForContentInSection section: Int) -> (trait: AnyObject, view: UIView)

    /// 返回指定section悬浮的footerView
    /// - Parameters:
    ///   - nestedContainerView: 当前容器
    ///   - section: section索引
    /// - Returns: 悬浮的footerView的trait和视图
    func nestedContainerView(_ nestedContainerView: NestedContainerView, viewForFooterInSection section: Int) -> (trait: AnyObject, view: UIView)?
}

// swiftlint:enable line_length
