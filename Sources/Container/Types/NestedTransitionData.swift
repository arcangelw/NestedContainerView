//
//  NestedTransitionData.swift
//
//
//  Created by 吴哲 on 2024/1/29.
//

import Foundation

/// 过渡数据
struct NestedTransitionData {
    /// 原始状态下的特性数组
    let fromTraits: [SectionTrait]

    /// 过渡后的特性数组
    var toTraits: [SectionTrait]

    /// 需要重新加载的特性数组
    let reloadTraits: [SectionTrait]

    /// 控制器数组
    let sectionControllers: [NestedSectionController]

    /// 页眉视图控制器
    let headerController: NestedHeaderFooterViewController?

    /// 页脚视图控制器
    let footerController: NestedHeaderFooterViewController?
}
