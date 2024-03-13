//
//  TableView.swift
//
//
//  Created by 吴哲 on 2024/2/26.
//

import UIKit

// swiftlint:disable line_length

/// UITableView 容器
public final class TableView: UITableView, NestedContainerScrollView, UIGestureRecognizerDelegate {
    /// 是否调用滚动到顶部方法
    public var callScrollsToTop: Bool = false

    /// 当前可见内容的显示的section
    public var sectionsForVisibleContentViews: [Int] {
        guard let sections = indexPathsForVisibleRows?.map(\.section) else {
            return []
        }
        return Array(Set(sections))
    }

    /// 当前可见的内容视图
    public var visibleContentViews: [UIView] {
        guard let cells = visibleCells as? [TableViewCell] else {
            return []
        }
        return cells.compactMap(\.bindView)
    }

    /// 表头视图
    public var headerView: UIView? {
        get {
            tableHeaderView
        }
        set {
            tableHeaderView = newValue
        }
    }

    /// 表尾视图
    public var footerView: UIView? {
        get {
            tableFooterView
        }
        set {
            tableFooterView = newValue
        }
    }

    /// 容器尺寸变化
    public var containerSizeDidChange: (() -> Void)?
    private var containerSize: CGSize?

    /// 绑定的嵌套容器
    public private(set) weak var nestedContainerView: NestedContainerView?

    /// 初始化方法
    public init() {
        super.init(frame: .zero, style: .plain)
        backgroundColor = .clear
        bounces = true
        alwaysBounceVertical = true
        alwaysBounceHorizontal = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        separatorStyle = .none
        scrollsToTop = true
        contentInsetAdjustmentBehavior = .automatic
        if #available(iOS 15.0, *) {
            sectionHeaderTopPadding = 0
        }
        delegate = self
        dataSource = self
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 布局变化
    override public func layoutSubviews() {
        super.layoutSubviews()
        guard containerSize != bounds.size else { return }
        containerSize = bounds.size
        containerSizeDidChange?()
    }

    /// 重写 `responds(to:)` 方法，用于处理嵌套容器视图的委托方法
    override public func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }
        return respondsToNestedContainerViewDelegate(aSelector)
    }

    /// 重写 `forwardingTarget(for:)` 方法，用于处理嵌套容器视图的委托方法
    override public func forwardingTarget(for aSelector: Selector!) -> Any? {
        if super.responds(to: aSelector) {
            return super.forwardingTarget(for: aSelector)
        }
        if respondsToNestedContainerViewDelegate(aSelector) {
            return nestedContainerView?.delegate
        }
        return super.forwardingTarget(for: aSelector)
    }

    /// 内容容器
    ///
    /// - Parameter section: 所在section
    public func contentContainerView(at section: Int) -> UIView? {
        return cellForRow(at: .init(row: 0, section: section))
    }

    /// 使布局无效并重置
    ///
    /// - Parameters:
    ///   - completion: 完成回调
    public func invalidateLayout(completion: ((_ finished: Bool) -> Void)?) {
        UIView.animate(withDuration: 0, delay: 0, options: [], animations: {
            self.performBatchUpdates(nil)
        }, completion: {
            completion?($0)
        })
    }

    /// 使指定的一组 section 的布局失效并触发重置
    ///
    /// - Parameters:
    ///   - sections: 需要使布局失效的 section 的索引数组
    ///   - completion: 重置完成后的回调闭包，接收一个布尔值参数表示重置是否完成
    public func invalidateLayout(in sections: [Int], completion: ((_ finished: Bool) -> Void)?) {
        UIView.animate(withDuration: 0, delay: 0, options: [], animations: {
            self.performBatchUpdates(nil)
        }, completion: {
            completion?($0)
        })
    }

    /// 绑定到嵌套容器
    ///
    /// - Parameter nestedContainerView: 当前的嵌套容器
    public func bind(_ nestedContainerView: NestedContainerView) {
        self.nestedContainerView = nestedContainerView
    }

    /// 委托发生变化
    public func delegateChange() {
        delegate = nil
        delegate = self
    }

    // MARK: - WrapperCell

    private let staticCellMap = NSMapTable<AnyObject, TableViewCell>.weakToStrongObjects()
    private func staticCellFor(trait: AnyObject) -> TableViewCell {
        if let cell = staticCellMap.object(forKey: trait) {
            return cell
        } else {
            let cell = TableViewCell(style: .default, reuseIdentifier: nil)
            staticCellMap.setObject(cell, forKey: trait)
            return cell
        }
    }

    // MARK: - UIGestureRecognizerDelegate

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let gestureDelegate = nestedContainerView?.gestureDelegate {
            return gestureDelegate.nestedNestedContainerViewGestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer)
        } else {
            return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
        }
    }
}

// MARK: - UITableViewDataSource

extension TableView: UITableViewDataSource {
    /// 查找数据源
    /// - Returns: 数据源信息，包括容器视图和数据源
    private func findDataSource() -> (containerView: NestedContainerView, dataSource: NestedContainerViewDataSource)? {
        guard let nestedContainerView = nestedContainerView, let dataSource = nestedContainerView.dataSource else {
            NestedLogger.shared.warn("无法找到数据源：nestedContainerView: \(nestedContainerView) dataSource: \(nestedContainerView?.dataSource)")
            return nil
        }
        return (nestedContainerView, dataSource)
    }

    /// 每个 section 配置仅有一个 cell
    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return 1
    }

    /// 返回当前的 section 数量
    /// - Parameter tableView: 表格视图
    /// - Returns: section 数量
    public func numberOfSections(in _: UITableView) -> Int {
        guard let find = findDataSource() else { return 0 }
        return find.dataSource.numberOfSections(in: find.containerView)
    }

    /// 设置内容容器的单元格
    /// - Parameters:
    ///   - tableView: 表格视图
    ///   - indexPath: 单元格的索引路径
    /// - Returns: 单元格实例
    public func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let find = findDataSource() else {
            return TableViewCell(style: .default, reuseIdentifier: nil)
        }
        let content = find.dataSource.nestedContainerView(find.containerView, viewForContentInSection: indexPath.section)
        let cell = staticCellFor(trait: content.trait)
        cell.setContentViewIfNeeded(content.view)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension TableView: UITableViewDelegate {
    /// 查找代理
    /// - Returns: 代理信息，包括容器视图和代理对象
    private func findDelegate() -> (containerView: NestedContainerView, delegate: NestedContainerViewDelegate)? {
        guard let nestedContainerView = nestedContainerView, let delegate = nestedContainerView.delegate else {
            NestedLogger.shared.warn("无法找到代理对象：nestedContainerView: \(nestedContainerView) delegate: \(nestedContainerView?.delegate)")
            return nil
        }
        return (nestedContainerView, delegate)
    }

    /// 返回悬浮的 headerView
    /// - Parameters:
    ///   - tableView: 表格视图
    ///   - section: section 索引
    /// - Returns: headerView 实例
    public func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let find = findDataSource() else { return nil }
        return find.dataSource.nestedContainerView(find.containerView, viewForHeaderInSection: section)?.view
    }

    /// 返回悬浮的 headerView 高度
    /// - Parameters:
    ///   - tableView: 表格视图
    ///   - section: section 索引
    /// - Returns: headerView 的高度
    public func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let find = findDelegate() else { return 0 }
        return find.delegate.nestedContainerView!(find.containerView, heightForHeaderInSection: section)
    }

    /// 返回内容单元格的高度
    /// - Parameters:
    ///   - tableView: 表格视图
    ///   - indexPath: 单元格的索引路径
    /// - Returns: 单元格的高度
    public func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let find = findDelegate() else { return 0 }
        return find.delegate.nestedContainerView!(find.containerView, heightForContentInSection: indexPath.section)
    }

    /// 返回悬浮的 footerView
    /// - Parameters:
    ///   - tableView: 表格视图
    ///   - section: section 索引
    /// - Returns: footerView 实例
    public func tableView(_: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let find = findDataSource() else { return nil }
        return find.dataSource.nestedContainerView(find.containerView, viewForFooterInSection: section)?.view
    }

    /// 返回悬浮的 footerView 高度
    /// - Parameters:
    ///   - tableView: 表格视图
    ///   - section: section 索引
    /// - Returns: footerView 的高度
    public func tableView(_: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let find = findDelegate() else { return 0 }
        return find.delegate.nestedContainerView!(find.containerView, heightForFooterInSection: section)
    }

    // MARK: - willDisplay

    /// 悬浮的 headerView 将要显示
    public func tableView(_: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let find = findDelegate() else { return }
        find.delegate.nestedContainerView!(find.containerView, willDisplayHeaderView: view, forSection: section)
    }

    /// 嵌套内容将要显示
    public func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let find = findDelegate(), let contentView = (cell as? TableViewCell)?.bindView else { return }
        find.delegate.nestedContainerView!(find.containerView, willDisplayContentView: contentView, forSection: indexPath.section)
    }

    /// 悬浮的 footerView 将要显示
    public func tableView(_: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        guard let find = findDelegate() else { return }
        find.delegate.nestedContainerView!(find.containerView, willDisplayFooterView: view, forSection: section)
    }

    // MARK: - didEndDisplaying

    /// 悬浮的 headerView 不再显示
    public func tableView(_: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        guard let find = findDelegate() else { return }
        find.delegate.nestedContainerView!(find.containerView, didEndDisplayingHeaderView: view, forSection: section)
    }

    /// 嵌套内容不再显示
    public func tableView(_: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let find = findDelegate(), let contentView = (cell as? TableViewCell)?.bindView else { return }
        find.delegate.nestedContainerView!(find.containerView, didEndDisplayingContentView: contentView, forSection: indexPath.section)
    }

    /// 悬浮的 footerView 不再显示
    public func tableView(_: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        guard let find = findDelegate() else { return }
        find.delegate.nestedContainerView!(find.containerView, didEndDisplayingFooterView: view, forSection: section)
    }
}

// swiftlint:enable line_length
