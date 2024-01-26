//
//  SectionEquatable.swift
//
//
//  Created by 吴哲 on 2024/2/1.
//

import Foundation

/// 协议：Section可比较
public protocol SectionEquatable {
    /// 判断两个Section是否相等
    /// - Parameter source: 要比较的Section
    /// - Returns: 是否相等
    func isSectionEqual(to source: Self) -> Bool
}

/// 默认实现：遵循Equatable协议的Section
extension SectionEquatable where Self: Equatable {
    /// 判断两个Section是否相等
    /// - Parameter source: 要比较的Section
    /// - Returns: 是否相等
    @inlinable
    public func isSectionEqual(to source: Self) -> Bool {
        return self == source
    }
}
