//
//  NestedHeaderFooterViewHeightMode.swift
//
//
//  Created by 吴哲 on 2024/1/29.
//

import CoreGraphics

/// 嵌套容器页眉页脚视图高度模式
public enum NestedContainerHeaderFooterViewHeightMode { // swiftlint:disable:this type_name
    /// 固定模式
    case fixed(_ heightMode: NestedContentHeightMode)

    /// 特殊嵌套类型模式，仅适用于只有一组Section配置的情况，只对页眉生效且在内部封装中使用
    /// - Parameters:
    ///   - heightMode: 高度模式
    ///   - pinToVisibleHeightMode: 悬浮显示高度模式
    case pin(_ heightMode: NestedContentHeightMode, pinToVisibleHeightMode: NestedContentHeightMode)
}

extension NestedContainerHeaderFooterViewHeightMode: Swift.ExpressibleByIntegerLiteral {
    public init(integerLiteral value: IntegerLiteralType) {
        self = .fixed(.absolute(CGFloat(value)))
    }
}

extension NestedContainerHeaderFooterViewHeightMode: Swift.ExpressibleByFloatLiteral {
    public init(floatLiteral value: FloatLiteralType) {
        self = .fixed(.absolute(value))
    }
}

extension NestedContainerHeaderFooterViewHeightMode: Swift.ExpressibleByNilLiteral {
    public init(nilLiteral _: ()) {
        self = .fixed(.absolute(0))
    }
}
