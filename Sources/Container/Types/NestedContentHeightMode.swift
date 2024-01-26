//
//  NestedContentHeightMode.swift
//
//
//  Created by 吴哲 on 2024/3/4.
//

import CoreGraphics

/// 高度模式
public enum NestedContentHeightMode: Hashable {
    /// 固定高度模式，使用指定的高度
    case absolute(_ height: CGFloat)

    /// 填充容器模式，高度与容器视图等高
    case filled

    /// 相对容器高度比例模式，高度相对于容器视图的比例，取值范围为0.0-1.0之间
    case fractionalHeight(_ fractionalHeight: CGFloat)
}

extension NestedContentHeightMode: Swift.ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .absolute(CGFloat(value))
    }
}

extension NestedContentHeightMode: Swift.ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .absolute(value)
    }
}

extension NestedContentHeightMode: Swift.ExpressibleByNilLiteral {
    public init(nilLiteral _: ()) {
        self = .absolute(0)
    }
}
