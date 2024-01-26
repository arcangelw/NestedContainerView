//
//  NestedDisplayHandler.swift
//
//
//  Created by 吴哲 on 2024/1/26.
//

import UIKit

// TODO: - 当前逻辑相对繁琐 需要优化计算逻辑
// swiftlint:disable line_length
/// 内容绘制处理
struct NestedSectionDisplayHandler {
    /// 当前显示section控制器
    private let visibleSections = NSCountedSet()
    /// 当前显示headerFooter控制器
    private let visibleHeaderFooters = NSCountedSet()
    /// 当前显示视图同section控制器特征映射
    private let visibleTraitMap = NSMapTable<UIView, SectionTrait>.strongToStrongObjects()
    /// 当前显示headerFooterView同控制器特征映射
    private let visibleHeaderFooterMap = NSMapTable<UIView, NestedHeaderFooterViewController>.strongToStrongObjects()

    /// 可见的section控制器集合
    var visibleSectionControllers: [NestedSectionController] {
        // swiftlint:disable:next force_cast
        return visibleSections.allObjects as! [NestedSectionController]
    }

    /// 可见的header/footer控制器集合
    var visibleHeaderFooterControllers: [NestedHeaderFooterViewController] {
        // swiftlint:disable:next force_cast
        return visibleHeaderFooters.allObjects as! [NestedHeaderFooterViewController]
    }

    // MARK: - headerFooter

    /// 当header/footer视图将要显示时调用
    ///
    /// - Parameters:
    ///   - nestedAdapter: 嵌套适配器
    ///   - view: 要显示的header/footer视图
    ///   - controller: 对应的header/footer控制器
    func nestedAdapter(_ nestedAdapter: NestedAdapter, willDisplayHeaderFooterView view: UIView, for controller: NestedHeaderFooterViewController) {
        visibleHeaderFooterMap.setObject(controller, forKey: view)
        if visibleHeaderFooters.count(for: controller) == 0 {
            nestedAdapter.delegate?.nestedAdapter(nestedAdapter, willDisplay: controller)
        }
        visibleHeaderFooters.add(controller)
    }

    /// 当header/footer视图结束显示时调用
    ///
    /// - Parameters:
    ///   - nestedAdapter: 嵌套适配器
    ///   - view: 结束显示的header/footer视图
    ///   - controller: 对应的header/footer控制器
    func nestedAdapter(_ nestedAdapter: NestedAdapter, didEndDisplayingHeaderFooterView view: UIView, for controller: NestedHeaderFooterViewController) {
        guard pluckHeaderFooterController(for: view) != nil else { return }
        visibleHeaderFooters.remove(controller)
        if visibleHeaderFooters.count(for: controller) == 0 {
            nestedAdapter.delegate?.nestedAdapter(nestedAdapter, didEndDisplaying: controller)
        }
    }

    // MARK: - Section

    /// 当内容视图将要显示时调用
    ///
    /// - Parameters:
    ///   - nestedAdapter: 嵌套适配器
    ///   - view: 要显示的内容视图
    ///   - controller: 对应的section控制器
    ///   - trait: section特征
    ///   - section: section索引
    func nestedAdapter(_ nestedAdapter: NestedAdapter, willDisplayContentView view: UIView, for controller: NestedSectionController, trait: SectionTrait, at section: Int) {
        willDisplay(view, for: nestedAdapter, sectionController: controller, trait: trait, at: section)
        controller.willDisplay(contentView: view, for: nestedAdapter)
    }

    /// 当内容视图结束显示时调用
    ///
    /// - Parameters:
    ///   - nestedAdapter: 嵌套适配器
    ///   - view: 结束显示的内容视图
    ///   - controller: 对应的section控制器
    ///   - trait: section特征
    ///   - section: section索引
    func nestedAdapter(_ nestedAdapter: NestedAdapter, didEndDisplayingContentView view: UIView, for controller: NestedSectionController, trait: SectionTrait, at section: Int) {
        guard pluckTrait(for: view) != nil else { return }
        controller.endDisplaying(contentView: view, for: nestedAdapter)
        endDisplaying(view, for: nestedAdapter, sectionController: controller, trait: trait, at: section)
    }

    /// 当section header视图将要显示时调用
    ///
    /// - Parameters:
    ///   - nestedAdapter: 嵌套适配器
    ///   - view: 要显示的section header视图
    ///   - controller: 对应的section控制器
    ///   - trait: section特征
    ///   - section: section索引
    func nestedAdapter(_ nestedAdapter: NestedAdapter, willDisplaySectionHeaderView view: UIView, for controller: NestedSectionController, trait: SectionTrait, at section: Int) {
        willDisplay(view, for: nestedAdapter, sectionController: controller, trait: trait, at: section)
        controller.willDisplay(headerView: view, for: nestedAdapter)
    }

    /// 当section header视图结束显示时调用
    ///
    /// - Parameters:
    ///   - nestedAdapter: 嵌套适配器
    ///   - view: 结束显示的section header视图
    ///   - controller: 对应的section控制器
    ///   - trait: section特征
    ///   - section: section索引
    func nestedAdapter(_ nestedAdapter: NestedAdapter, didEndDisplayingSectionHeaderView view: UIView, for controller: NestedSectionController, trait: SectionTrait, at section: Int) {
        guard pluckTrait(for: view) != nil else { return }
        controller.endDisplaying(headerView: view, for: nestedAdapter)
        endDisplaying(view, for: nestedAdapter, sectionController: controller, trait: trait, at: section)
    }

    /// 当section footer视图将要显示时调用
    ///
    /// - Parameters:
    ///   - nestedAdapter: 嵌套适配器
    ///   - view: 要显示的section footer视图
    ///   - controller: 对应的section控制器
    ///   - trait: section特征
    ///   - section: section索引
    func nestedAdapter(_ nestedAdapter: NestedAdapter, willDisplaySectionFooterView view: UIView, for controller: NestedSectionController, trait: SectionTrait, at section: Int) {
        willDisplay(view, for: nestedAdapter, sectionController: controller, trait: trait, at: section)
        controller.willDisplay(footerView: view, for: nestedAdapter)
    }

    /// 当section footer视图结束显示时调用
    ///
    /// - Parameters:
    ///   - nestedAdapter: 嵌套适配器
    ///   - view: 结束显示的section footer视图
    ///   - controller: 对应的section控制器
    ///   - trait: section特征
    ///   - section: section索引
    func nestedAdapter(_ nestedAdapter: NestedAdapter, didEndDisplayingSectionFooterView view: UIView, for controller: NestedSectionController, trait: SectionTrait, at section: Int) {
        guard pluckTrait(for: view) != nil else { return }
        controller.endDisplaying(footerView: view, for: nestedAdapter)
        endDisplaying(view, for: nestedAdapter, sectionController: controller, trait: trait, at: section)
    }

    // MARK: - Private

    /// 从 `visibleTraitMap` 中获取并移除给定视图对应的节特征。
    ///
    /// - Parameter view: 需要获取节特征的视图。
    /// - Returns: 如果存在对应的节特征，则返回该特征；否则返回 `nil`。
    private func pluckTrait(for view: UIView) -> SectionTrait? {
        let trait = visibleTraitMap.object(forKey: view)
        visibleTraitMap.removeObject(forKey: view)
        return trait
    }

    /// 从 `visibleHeaderFooterMap` 中获取并移除给定视图对应的页眉/页脚控制器。
    ///
    /// - Parameter view: 需要获取页眉/页脚控制器的视图。
    /// - Returns: 如果存在对应的页眉/页脚控制器，则返回该控制器；否则返回 `nil`。
    private func pluckHeaderFooterController(for view: UIView) -> NestedHeaderFooterViewController? {
        let controller = visibleHeaderFooterMap.object(forKey: view)
        visibleHeaderFooterMap.removeObject(forKey: view)
        return controller
    }

    /// 将要显示视图时的处理，更新 `visibleTraitMap`、添加节控制器到可见集合，并在控制器不可见时通知代理。
    ///
    /// - Parameters:
    ///   - view: 将要显示的视图。
    ///   - nestedAdapter: 嵌套适配器。
    ///   - sectionController: 节控制器。
    ///   - trait: 节控制器特征。
    ///   - section: 节索引。
    private func willDisplay(_ view: UIView, for nestedAdapter: NestedAdapter, sectionController: NestedSectionController, trait: SectionTrait, at section: Int) {
        visibleTraitMap.setObject(trait, forKey: view)
        if visibleSections.count(for: sectionController) == 0 {
            nestedAdapter.delegate?.nestedAdapter(nestedAdapter, willDisplay: trait.model, at: section)
            sectionController.willDisplay(nestedAdapter: nestedAdapter)
        }
        visibleSections.add(sectionController)
    }

    /// 结束显示视图时的处理，从可见集合中移除节控制器，并在控制器不再可见时通知代理。
    ///
    /// - Parameters:
    ///   - view: 结束显示的视图。
    ///   - nestedAdapter: 嵌套适配器。
    ///   - sectionController: 节控制器。
    ///   - trait: 节控制器特征。
    ///   - section: 节索引。
    private func endDisplaying(_: UIView, for nestedAdapter: NestedAdapter, sectionController: NestedSectionController, trait: SectionTrait, at section: Int) {
        visibleSections.remove(sectionController)
        if visibleSections.count(for: sectionController) == 0 {
            sectionController.endDisplaying(nestedAdapter: nestedAdapter)
            nestedAdapter.delegate?.nestedAdapter(nestedAdapter, didEndDisplaying: trait.model, at: section)
        }
    }
}

// swiftlint:enable line_length
