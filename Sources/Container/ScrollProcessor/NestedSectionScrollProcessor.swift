//
//  NestedSectionScrollProcessor.swift
//
//
//  Created by 吴哲 on 2024/2/23.
//

import UIKit

/// 嵌套滚动计算器
open class NestedSectionScrollProcessor {
    /// 特征数据
    var trait: SectionTrait
    /// section位置
    public internal(set) var section: Int = 0
    /// 是否是第一组section
    public internal(set) var isFirstSection: Bool = false
    /// 是否是最后一组section
    public internal(set) var isLastSection: Bool = false

    /// 布局数据
    public var layoutAttributes: SectionLayoutAttributes {
        return trait.layoutAttributes
    }

    /// 容器滚动视图
    public internal(set) weak var containerScrollView: NestedContainerScrollView?

    /// 横向内容管理
    public weak var management: HorizontalNestedContentViewManagement?

    /// 嵌套滚动视图
    open internal(set) weak var embeddedScrollView: UIScrollView?

    /// 初始化计算器
    /// - Parameter trait: setion特征数据
    public required init(trait: SectionTrait) {
        self.trait = trait
    }

    /// 容器滚动
    /// - Parameter containerScrollView: 滚动容器视图
    open func containerScrollViewDidScroll(_: NestedContainerScrollView) {}

    /// 容器结束减速
    /// - Parameter containerScrollView: 滚动容器视图
    open func containerScrollViewDidEndDecelerating(_: NestedContainerScrollView) {}

    /// 内容滚动
    /// - Parameter embeddedScrollView: 滚动的内容视图
    open func embeddedScrollViewDidScroll(_: UIScrollView) {}
}
