//
//  NestedSectionMap.swift
//
//  Created by 吴哲 on 2024/1/29.
//

import UIKit

// swiftlint:disable line_length

/// 映射嵌套分区的结构体，将分区与其对应的嵌套分区控制器和滚动处理器关联起来。
final class NestedSectionMap {
    /// 从分区特征到其对应的嵌套分区控制器的映射表。
    private let traitToController: NSMapTable<SectionTrait, NestedSectionController>

    /// 从嵌套分区控制器到其对应的分区的映射表。
    private let controllerToSection: NSMapTable<NestedSectionController, NSNumber>

    /// 从分区特征到其对应的滚动处理器的映射表。
    private let traitToScrollProcessor: NSMapTable<SectionTrait, NestedSectionScrollProcessor>

    /// 所有分区特征的数组。
    private(set) var traits: [SectionTrait] = []

    /// 该映射的页眉控制器。
    var headerController: NestedHeaderFooterViewController?

    /// 该映射的页脚控制器。
    var footerController: NestedHeaderFooterViewController?

    /// 返回该映射是否为空。
    var isEmpty: Bool {
        guard traits.isEmpty else { return false }

        // 如果没有分区特征，并且页眉或页脚的高度不为零，则该映射不为空。
        if let headerController = headerController, headerController.headerFooterViewHeight() > 0 {
            return false
        }
        if let footerController = footerController, footerController.headerFooterViewHeight() > 0 {
            return false
        }

        return true
    }

    /// 创建滚动处理器
    var createScrollProcessor: (_ trait: SectionTrait) -> NestedSectionScrollProcessor

    /// 初始化方法。
    init() {
        let keyPointerFunctions = NSPointerFunctions(options: .strongMemory)
        keyPointerFunctions.hashFunction = SectionTrait.hashFunction()
        keyPointerFunctions.isEqualFunction = SectionTrait.equalFunction()
        self.traitToController = .init(keyPointerFunctions: keyPointerFunctions, valuePointerFunctions: .init(options: .strongMemory), capacity: 0)
        self.controllerToSection = .init(keyOptions: [.strongMemory, .objectPointerPersonality], valueOptions: .strongMemory)
        self.traitToScrollProcessor = .init(keyPointerFunctions: keyPointerFunctions, valuePointerFunctions: .init(options: .strongMemory), capacity: 0)
        self.createScrollProcessor = { DefaultScrollProcessor(trait: $0) }
    }

    // MARK: - Func

    /// 根据嵌套分区控制器查找其所在的分区。
    /// - Parameter controller: 要查找的嵌套分区控制器。
    /// - Returns: 控制器所在的分区，如果未找到则返回 nil。
    func section(for controller: NestedSectionController) -> Int? {
        controllerToSection.object(forKey: controller)?.intValue
    }

    /// 根据分区索引查找对应的嵌套分区控制器。
    /// - Parameter section: 要查找的分区索引。
    /// - Returns: 对应的嵌套分区控制器，如果未找到则返回 nil。
    func controller(for section: Int) -> NestedSectionController? {
        return traitToController.object(forKey: trait(for: section))
    }

    /// 根据分区特征查找对应的嵌套分区控制器。
    /// - Parameter trait: 要查找的分区特征。
    /// - Returns: 对应的嵌套分区控制器，如果未找到则返回 nil。
    func controller(for trait: SectionTrait) -> NestedSectionController? {
        traitToController.object(forKey: trait)
    }

    /// 根据分区索引查找对应的分区特征。
    /// - Parameter section: 要查找的分区索引。
    /// - Returns: 对应的分区特征，如果未找到则返回 nil。
    func trait(for section: Int) -> SectionTrait? {
        guard traits.indices.contains(section) else { return nil }
        return traits[section]
    }

    /// 根据嵌套分区控制器查找对应的分区特征。
    /// - Parameter controller: 要查找的嵌套分区控制器。
    /// - Returns: 对应的分区特征，如果未找到则返回 nil。
    func trait(for controller: NestedSectionController) -> SectionTrait? {
        guard let section = section(for: controller) else {
            return nil
        }
        return trait(for: section)
    }

    /// 根据分区特征查找对应的分区索引。
    /// - Parameter trait: 要查找的分区特征。
    /// - Returns: 对应的分区索引，如果未找到则返回 nil。
    func section(for trait: SectionTrait) -> Int? {
        return traits.firstIndex(of: trait)
    }

    /// 根据分区特征查找对应的滚动处理器。
    /// - Parameter trait: 要查找的分区特征。
    /// - Returns: 对应的滚动处理器，如果未找到则返回 nil。
    func processor(for trait: SectionTrait) -> NestedSectionScrollProcessor? {
        return traitToScrollProcessor.object(forKey: trait)
    }

    /// 根据嵌套分区控制器查找对应的滚动处理器。
    /// - Parameter controller: 要查找的嵌套分区控制器。
    /// - Returns: 对应的滚动处理器，如果未找到则返回 nil。
    func processor(for controller: NestedSectionController) -> NestedSectionScrollProcessor? {
        return traitToScrollProcessor.object(forKey: trait(for: controller))
    }

    /// 更新映射表的分区特征、嵌套分区控制器和滚动处理器。
    /// - Parameters:
    ///   - traits: 新的分区特征数组。
    ///   - controllers: 新的嵌套分区控制器数组。
    ///   - containerScrollView: 滚动容器
    func update(traits: [SectionTrait], controllers: [NestedSectionController], for containerScrollView: NestedContainerScrollView) {
        NestedLogger.shared.assert(traits.count == controllers.count)
        reset()
        self.traits = traits
        let firstTrait = traits.first
        let lastTrait = traits.last

        for (section, trait) in traits.enumerated() {
            let controller = controllers[section]
            traitToController.setObject(controller, forKey: trait)
            controllerToSection.setObject(.init(value: section), forKey: controller)
            controller.isFirstSection = trait === firstTrait
            controller.isLastSection = trait === lastTrait
            controller.section = section
            let processor = createScrollProcessor(trait)
            processor.section = section
            processor.isFirstSection = controller.isFirstSection
            processor.isLastSection = controller.isLastSection
            processor.containerScrollView = containerScrollView
            processor.embeddedScrollView = controller.sectionEmbeddedScrollView()
            // 这里单独判断横向嵌套内容 绑定管理
            if let controller = controller as? HorizontalNestedContentSectionController {
                processor.management = controller.management
            }
            traitToScrollProcessor.setObject(processor, forKey: trait)
        }
    }

    /// 更新指定分区特征对应的嵌套分区控制器、滚动处理器和分区索引。
    /// - Parameter trait: 要更新的分区特征。
    func update(trait: SectionTrait) {
        guard let section = section(for: trait) else {
            return
        }
        let controller = controller(for: trait)
        traitToController.setObject(controller, forKey: trait)
        let processor = processor(for: trait)
        processor?.trait = trait
        processor?.section = section
        traitToScrollProcessor.setObject(processor, forKey: trait)
        controllerToSection.setObject(.init(value: section), forKey: controller)
        traits[section] = trait
    }

    /// 重置映射表，将所有的分区控制器和滚动处理器相关的属性重置为默认值。
    func reset() {
        enumerate { _, sectionController, _, _, _ in
            sectionController?.section = NSNotFound
            sectionController?.isFirstSection = false
            sectionController?.isLastSection = false
        }
        traitToController.removeAllObjects()
        controllerToSection.removeAllObjects()
        traitToScrollProcessor.removeAllObjects()
    }

    /// 遍历映射表，并执行指定的闭包。
    /// - Parameter block: 遍历闭包，接受分区特征、控制器、滚动处理器、分区索引和停止标志作为参数。
    func enumerate(using block: (_ trait: SectionTrait, _ controller: NestedSectionController?, _ processor: NestedSectionScrollProcessor?, _ section: Int, _ stop: inout Bool) -> Void) {
        let traits = self.traits
        var stop = false
        for (section, trait) in traits.enumerated() {
            let controller = controller(for: section)
            let processor = processor(for: trait)
            block(trait, controller, processor, section, &stop)
            if stop {
                break
            }
        }
    }
}

// swiftlint:enable line_length
