//
//  NestedContainerScrollPosition.swift
//
//
//  Created by 吴哲 on 2024/1/29.
//

import Foundation

/// 嵌套容器滚动位置枚举
///
/// 定义了嵌套容器视图应该滚动到哪个位置的选项
public enum NestedContainerScrollPosition {
    /// 滚动到指定的节索引位置
    ///
    /// - Parameter section: 要滚动到的节索引
    case section(_ section: Int)

    /// 滚动到容器的头部视图控制器位置
    case header

    /// 滚动到容器的尾部视图控制器位置
    case footer
}
