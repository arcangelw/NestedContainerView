//
//  NestedSectionContentHeightMode.swift
//
//
//  Created by 吴哲 on 2024/1/29.
//

import CoreGraphics

/// 内容高度模式
public enum NestedSectionContentHeightMode: Hashable {
    /// 固定模式
    case fixed(_ heightMode: NestedContentHeightMode)

    /// 嵌套内容高度模式，用于具有嵌套滚动视图的情况，动态读取高度
    /// 需要配合`invalidateLayout`方法进行布局更新
    /// `visibleHeightMode` 配置的时候，设置最小展示高度
    case embedded(_ visibleHeightMode: NestedContentHeightMode?, embeddedContentHeight: CGFloat)
}

extension NestedSectionContentHeightMode: Swift.ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .fixed(.absolute(CGFloat(value)))
    }
}

extension NestedSectionContentHeightMode: Swift.ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .fixed(.absolute(value))
    }
}

extension NestedSectionContentHeightMode: Swift.ExpressibleByNilLiteral {
    public init(nilLiteral _: ()) {
        self = .fixed(.absolute(0))
    }
}
