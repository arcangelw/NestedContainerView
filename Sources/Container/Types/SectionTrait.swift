//
//  SectionTrait.swift
//
//
//  Created by 吴哲 on 2024/2/29.
//

import Foundation

// swiftlint:disable line_length

/// `Section`特征信息。
public final class SectionTrait: Hashable {
    /// Section模型。
    var model: AnySectionDifferentiable

    /// 布局属性。
    var layoutAttributes = SectionLayoutAttributes()

    /// 初始化方法。
    /// - Parameter model: Section模型。
    init(model: AnySectionDifferentiable) {
        self.model = model
    }

    /// 添加`uniqueIdentifier`到hasher。
    /// - Parameter hasher: Hasher对象。
    public func hash(into hasher: inout Hasher) {
        hasher.combine(model.uniqueIdentifier)
    }

    /// 判断两个SectionTrait对象是否相等。
    /// - Parameters:
    ///   - lhs: 第一个SectionTrait对象。
    ///   - rhs: 第二个SectionTrait对象。
    /// - Returns: 是否相等。
    public static func == (lhs: SectionTrait, rhs: SectionTrait) -> Bool {
        return lhs === rhs || lhs.model.isSectionEqual(to: rhs.model)
    }
}

extension SectionTrait {
    /// 去除重复的`Section`模型信息。
    /// - Parameter models: `Section`模型数组。
    /// - Returns: 去重后的`Section`模型数组。
    static func duplicateRemoved(_ models: [AnySectionDifferentiable]) -> [AnySectionDifferentiable] {
        guard !models.isEmpty else { return [] }
        var hashMap: [AnyHashable: AnySectionDifferentiable] = [:]
        var uniqueModels: [AnySectionDifferentiable] = []

        for model in models {
            let key = model.uniqueIdentifier

            if let previousModel = hashMap[key] {
                NestedLogger.shared.warn("Duplicate uniqueIdentifier \(model.uniqueIdentifier) for object \(model) with object \(previousModel)")
            } else {
                hashMap[key] = model
                uniqueModels.append(model)
            }
        }

        return uniqueModels
    }

    /// 对比新旧的`SectionTrait`信息并返回更新后的`SectionTrait`数组和需要刷新的`SectionTrait`数组。
    /// - Parameters:
    ///   - models: 新的`Section`模型数组。
    ///   - previousTraits: 旧的`SectionTrait`数组。
    /// - Returns: 一个元组，包含更新后的`SectionTrait`数组和需要刷新的`SectionTrait`数组。
    static func traits(models: [AnySectionDifferentiable], previousTraits: [SectionTrait]) -> (traits: [SectionTrait], reloadTraits: [SectionTrait]) {
        guard !previousTraits.isEmpty else {
            let traits = models.map(SectionTrait.init(model:))
            return (traits, traits)
        }

        var hashMap: [AnyHashable: SectionTrait] = [:]
        for trait in previousTraits {
            hashMap[trait.model.uniqueIdentifier] = trait
        }

        var traits: [SectionTrait] = []
        var reloadTraits: [SectionTrait] = []

        for model in models {
            let key = model.uniqueIdentifier

            if let trait = hashMap[key] {
                traits.append(trait)

                // 判断`Section`是否是同一个内存地址，如果不是则标记需要更新。
                if !model.isSamePointer(to: trait.model) {
                    trait.model = model
                    reloadTraits.append(trait)
                    NestedLogger.shared.warn(model.description)
                }
            } else {
                let trait = SectionTrait(model: model)
                traits.append(trait)
            }
        }

        return (traits, reloadTraits)
    }
}

extension SectionTrait {
    /// 返回一个桥接的 C 函数块，用于计算特征的哈希值。
    /// - Returns: C 函数块。
    static func hashFunction() -> (@convention(c) (UnsafeRawPointer, (@convention(c) (UnsafeRawPointer) -> Int)?) -> Int) {
        return { item, _ in
            unsafeBitCast(item, to: SectionTrait.self).hashValue
        }
    }

    /// 返回一个桥接的 C 函数块，用于判断特征是否相等。
    /// - Returns: C 函数块。
    static func equalFunction() -> (@convention(c) (UnsafeRawPointer, UnsafeRawPointer, (@convention(c) (UnsafeRawPointer) -> Int)?) -> ObjCBool) {
        return { lhs, rhs, _ in
            .init(unsafeBitCast(lhs, to: SectionTrait.self) == unsafeBitCast(rhs, to: SectionTrait.self))
        }
    }
}

// swiftlint:enable line_length
