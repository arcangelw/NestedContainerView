//
//  AnySectionDifferentiable.swift
//
//
//  Created by 吴哲 on 2024/2/29.
//

import Foundation

public typealias NestedSectionModel = AnySectionDifferentiable

/// 提供一个抹去不同 `Section` 类型差异的容器
public struct AnySectionDifferentiable: SectionDifferentiable {
    /// 包装值
    @inlinable
    public var base: Any {
        return box.base
    }

    /// 唯一标识符
    @inlinable
    public var uniqueIdentifier: AnyHashable {
        return box.uniqueIdentifier
    }

    /// 包装容器
    @usableFromInline
    let box: AnySectionDifferentiableBox

    /// 创建一个抹去类型差异的包装器
    ///
    /// - Parameter base: 需要包装的类型实例
    public init<D: SectionDifferentiable>(_ base: D) {
        if let anySectionDifferentiable = base as? AnySectionDifferentiable {
            self = anySectionDifferentiable
        } else {
            self.box = SectionDifferentiableBox(base)
        }
    }

    /// 判断两个 `AnySectionDifferentiable` 实例的包装值是否相等
    ///
    /// - Parameter source: 要比较的另一个 `AnySectionDifferentiable` 实例
    /// - Returns: 如果两个实例的包装值相等，则为 `true`，否则为 `false`
    @inlinable
    public func isSectionEqual(to source: AnySectionDifferentiable) -> Bool {
        return box.isSectionEqual(to: source.box)
    }

    /// 判断两个 `AnySectionDifferentiable` 实例的包装值是否具有相同的内存地址
    ///
    /// - Parameter source: 要比较的另一个 `AnySectionDifferentiable` 实例
    /// - Returns: 如果两个实例的包装值具有相同的内存地址，则为 `true`，否则为 `false`
    @inlinable
    func isSamePointer(to source: AnySectionDifferentiable) -> Bool {
        return ObjectIdentifier(base as AnyObject) == ObjectIdentifier(source.base as AnyObject)
    }
}

extension AnySectionDifferentiable: CustomDebugStringConvertible, CustomStringConvertible {
    public var description: String {
        return "AnySectionDifferentiable(\(String(reflecting: base)))"
    }

    public var debugDescription: String {
        return description
    }
}

@usableFromInline
protocol AnySectionDifferentiableBox {
    /// 类型擦除
    var base: Any { get }
    /// 唯一标识符的属性
    var uniqueIdentifier: AnyHashable { get }
    /// 比较两个 AnySectionDifferentiableBox 实例是否相等
    func isSectionEqual(to source: AnySectionDifferentiableBox) -> Bool
}

@usableFromInline
struct SectionDifferentiableBox<Base: SectionDifferentiable>: AnySectionDifferentiableBox {
    /// 保有底层数据
    @usableFromInline
    let baseComponent: Base

    /// 类型擦除
    @inlinable
    var base: Any {
        return baseComponent
    }

    /// 唯一标识符的属性
    @inlinable
    var uniqueIdentifier: AnyHashable {
        return baseComponent.uniqueIdentifier
    }

    /// 初始化
    /// - Parameter base: 底层数据
    @usableFromInline
    init(_ base: Base) {
        self.baseComponent = base
    }

    @inlinable
    func isSectionEqual(to source: AnySectionDifferentiableBox) -> Bool {
        // 如果 source 的底层部分无法转换为 Base 类型，则返回 false
        guard let sourceBase = source.base as? Base else {
            return false
        }
        // 调用底层部分的 isSectionEqual 方法进行比较
        return baseComponent.isSectionEqual(to: sourceBase)
    }
}
