//
//  CollectionView.swift
//
//
//  Created by 吴哲 on 2024/2/27.
//

import UIKit

// swiftlint:disable line_length file_length

/// UICollectionView 容器
public final class CollectionView: UICollectionView, NestedContainerScrollView, UIGestureRecognizerDelegate {
    /// 是否调用滚动到顶部方法
    public var callScrollsToTop: Bool = false

    /// 当前展示内容的显示的section
    public var sectionsForVisibleContentViews: [Int] {
        return .init(Set(indexPathsForVisibleItems.map(\.section)))
    }

    /// 当前显示的内容视图
    public var visibleContentViews: [UIView] {
        guard let cells = visibleCells as? [CollectionViewCell] else {
            return []
        }
        return cells.compactMap(\.bindView)
    }

    /// header视图
    public var headerView: UIView? {
        didSet {
            defer {
                collectionViewLayout.invalidateLayout()
            }
            oldValue?.removeFromSuperview()
            // 设置headerView的高度为headerView的高度或0
            // swiftlint:disable:next force_cast
            (collectionViewLayout as! CollectionViewLayout).headerViewHeight = headerView?.frame.height ?? 0
            guard let headerView = headerView else { return }
            var frame = headerView.frame
            frame.origin = .zero
            frame.size.width = bounds.width
            headerView.frame = frame
            addSubview(headerView)
        }
    }

    /// footer视图
    public var footerView: UIView? {
        didSet {
            defer {
                collectionViewLayout.invalidateLayout()
            }
            oldValue?.removeFromSuperview()
            // 设置footerView的高度为footerView的高度或0
            // swiftlint:disable:next force_cast
            (collectionViewLayout as! CollectionViewLayout).footerViewHeight = footerView?.frame.height ?? 0
            guard let footerView = footerView else { return }
            var frame = footerView.frame
            frame.origin.x = 0
            frame.origin.y = contentSize.height - frame.height
            frame.size.width = bounds.width
            footerView.frame = frame
            addSubview(footerView)
        }
    }

    /// 容器尺寸变化
    public var containerSizeDidChange: (() -> Void)?
    private var containerSize: CGSize?

    /// 绑定的容器
    public private(set) weak var nestedContainerView: NestedContainerView?

    /// 已注册cell重用标识
    private var cellReuseIdentifiers: Set<String> = .init()
    /// 已注册header重用标识
    private var headerReuseIdentifiers: Set<String> = .init()
    /// 已注册footer重用标识
    private var footerReuseIdentifiers: Set<String> = .init()
    private enum Kind {
        /// headerView占位
        static let headerViewPlaceholder = "Kind.headerViewPlaceholder"
        /// footerView占位
        static let footerViewPlaceholder = "Kind.footerViewPlaceholder"
    }

    /// 复用标识
    private enum Reuse {
        static let headerView = "Reuse.headerView"
        static let footerView = "Reuse.footerView"
        static let error = "Reuse.error"
    }

    /// contentSize 监听
    private var observation: NSKeyValueObservation?

    /// 初始化方法
    public init() {
        super.init(frame: .zero, collectionViewLayout: .init())
        let layout = CollectionViewLayout { [weak self] section, environment in
            guard let self = self else { return .empty }
            return createSectionLayout(section: section, environment: environment)
        }
        setCollectionViewLayout(layout, animated: false)
        backgroundColor = .clear
        bounces = true
        alwaysBounceVertical = true
        alwaysBounceHorizontal = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        scrollsToTop = true
        contentInsetAdjustmentBehavior = .automatic
        // 提前注册占位容错内容
        register(CollectionReusableView.self, forSupplementaryViewOfKind: Kind.headerViewPlaceholder, withReuseIdentifier: Reuse.headerView)
        register(CollectionReusableView.self, forSupplementaryViewOfKind: Kind.footerViewPlaceholder, withReuseIdentifier: Reuse.footerView)
        register(CollectionViewCell.self, forCellWithReuseIdentifier: Reuse.error)
        register(CollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Reuse.error)
        register(CollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: Reuse.error)
        delegate = self
        dataSource = self
        // 监听contentSize的变化，更新footerView的位置
        self.observation = observe(\.contentSize) { [weak self] _, _ in
            guard let self = self, let footerView = self.footerView else { return }
            var frame = footerView.frame
            frame.origin.x = 0
            frame.origin.y = self.contentSize.height - frame.height
            frame.size.width = self.bounds.width
            footerView.frame = frame
        }
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

    /// 检查是否响应某个方法
    override public func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }
        return respondsToNestedContainerViewDelegate(aSelector)
    }

    /// 转发目标对象
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
        return cellForItem(at: .init(item: 0, section: section))
    }

    /// 重置布局使其失效
    /// - Parameters:
    ///   - completion: 完成回调
    public func invalidateLayout(completion: ((_ finished: Bool) -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        performBatchUpdates({
            self.collectionViewLayout.invalidateLayout()
        }, completion: completion)
        CATransaction.commit()
    }

    /// 使指定的一组 section 的布局失效并触发重置
    ///
    /// - Parameters:
    ///   - sections: 需要使布局失效的 section 的索引数组
    ///   - completion: 重置完成后的回调闭包，接收一个布尔值参数表示重置是否完成
    public func invalidateLayout(in sections: [Int], completion: ((_ finished: Bool) -> Void)?) {
        var items: [IndexPath] = []
        for section in sections {
            let count = numberOfItems(inSection: section)
            items += (0 ..< count).map { IndexPath(item: $0, section: section) }
        }
        // swiftlint:disable:next force_cast
        let cls = type(of: collectionViewLayout).invalidationContextClass as! UICollectionViewLayoutInvalidationContext.Type
        let context = cls.init()
        context.invalidateItems(at: items)
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        performBatchUpdates({
            self.collectionViewLayout.invalidateLayout(with: context)
        }, completion: completion)
        CATransaction.commit()
    }

    /// 绑定到嵌套容器
    ///
    /// - Parameter nestedContainerView: 当前嵌套容器
    public func bind(_ nestedContainerView: NestedContainerView) {
        self.nestedContainerView = nestedContainerView
    }

    /// 代理发生变化
    public func delegateChange() {
        delegate = nil
        delegate = self
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

// MARK: - Layout

extension CollectionView {
    /// 创建section布局
    /// - Parameters:
    ///   - section: 当前section
    ///   - environment: 环境参数
    /// - Returns: section layout
    private func createSectionLayout(section: Int, environment _: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection {
        // 查找代理对象
        guard let find = findDelegate() else { return .empty }

        // 检查是否是第一个section
        let isFirst = section == 0

        // 获取header、content和footer的高度
        let header = find.delegate.nestedContainerView!(find.containerView, heightForHeaderInSection: section)
        let content = find.delegate.nestedContainerView!(find.containerView, heightForContentInSection: section)
        let footer = find.delegate.nestedContainerView!(find.containerView, heightForFooterInSection: section)

        // 创建一个item
        let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))

        // 创建一个group，垂直布局，高度为content的高度
        let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(content)), subitems: [item])

        // 创建一个section布局
        let layoutSection = NSCollectionLayoutSection(group: group)

        // 创建boundarySupplementaryItems数组，用于存储边界补充视图
        var boundarySupplementaryItems: [NSCollectionLayoutBoundarySupplementaryItem] = []

        // 如果是第一个section，并且存在headerView，则创建一个占位的headerItem
        if isFirst, let headerView = headerView {
            // 使用空白的ReusableView作为占位，提供一个占位空间给headerView
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(headerView.frame.height + header)), elementKind: Kind.headerViewPlaceholder, alignment: .top)
            boundarySupplementaryItems.append(headerItem)
        }

        // 如果header的高度不为零，则创建一个headerItem，并将其添加到boundarySupplementaryItems数组中
        if !header.isZero {
            let headerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(header)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            headerItem.pinToVisibleBounds = true
            boundarySupplementaryItems.append(headerItem)
        }

        // 如果footer的高度不为零，则创建一个footerItem，并将其添加到boundarySupplementaryItems数组中
        if !footer.isZero {
            let footerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(footer)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)
            footerItem.pinToVisibleBounds = true
            boundarySupplementaryItems.append(footerItem)
        }

        // TODO: - 直接使用原生实现无法解决 header pinToVisibleBounds 问题，后期定制Layout优化
        // 如果是最后一个section，并且存在footerView，则创建一个占位的footerItem
        //            if isLast, let footerView = self.footerView {
        //                let footerItem = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(footerView.frame.height + footer)), elementKind: Kind.footerViewPlaceholder, alignment: .bottom)
        //                boundarySupplementaryItems.append(footerItem)
        //            }

        // 将boundarySupplementaryItems数组设置为layoutSection的boundarySupplementaryItems
        layoutSection.boundarySupplementaryItems = boundarySupplementaryItems

        return layoutSection
    }
}

// MARK: - UICollectionViewDataSource

extension CollectionView: UICollectionViewDataSource {
    /// 数据源
    /// - Returns: 数据源信息，包含容器视图和数据源
    private func findDataSource() -> (containerView: NestedContainerView, dataSource: NestedContainerViewDataSource)? {
        // 检查是否存在容器视图和数据源
        guard let nestedContainerView = nestedContainerView, let dataSource = nestedContainerView.dataSource else {
            NestedLogger.shared.warn("Cannot find dataSource - nestedContainerView: \(nestedContainerView), dataSource: \(nestedContainerView?.dataSource)")
            return nil
        }
        return (nestedContainerView, dataSource)
    }

    /// 获取集合视图中的section数量
    public func numberOfSections(in _: UICollectionView) -> Int {
        guard let find = findDataSource() else {
            return 0
        }
        return find.dataSource.numberOfSections(in: find.containerView)
    }

    /// 每个section配置仅有一个cell
    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return 1
    }

    /// 设置内容容器cell
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let find = findDataSource() else {
            // 如果找不到数据源或容器视图，则返回错误的重用标识的cell
            return collectionView.dequeueReusableCell(withReuseIdentifier: Reuse.error, for: indexPath)
        }
        // 获取指定section的内容容器视图
        let content = find.dataSource.nestedContainerView(find.containerView, viewForContentInSection: indexPath.section)
        let reuseIdentifier = String(describing: content.trait)
        // 检查是否已注册过该重用标识的cell，如果没有则进行注册
        if !cellReuseIdentifiers.contains(reuseIdentifier) {
            cellReuseIdentifiers.insert(reuseIdentifier)
            collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        }
        // 通过重用标识从缓存池中获取cell，并将内容视图设置到cell中
        // swiftlint:disable:next force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionViewCell
        cell.setContentViewIfNeeded(content.view)
        return cell
    }

    /// 设置容器ReusableView
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        // 返回错误的补充视图
        func errorView() -> UICollectionReusableView {
            collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Reuse.error, for: indexPath)
        }

        guard let find = findDataSource() else {
            return errorView()
        }

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            // 处理headerView的情况
            guard let header = find.dataSource.nestedContainerView(find.containerView, viewForHeaderInSection: indexPath.section) else {
                // 如果找不到指定section的headerView，则返回错误的补充视图
                NestedLogger.shared.assertionFailure("No pinHeaderView found for indexPath: \(indexPath)")
                return errorView()
            }
            let reuseIdentifier = String(describing: header.trait)
            // 检查是否已注册过该重用标识的补充视图，如果没有则进行注册
            if !headerReuseIdentifiers.contains(reuseIdentifier) {
                headerReuseIdentifiers.insert(reuseIdentifier)
                collectionView.register(CollectionReusableView.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
            }
            // 通过重用标识从缓存池中获取补充视图，并将headerView设置到补充视图中
            // swiftlint:disable:next force_cast
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionReusableView
            reusableView.setContentViewIfNeeded(header.view)
            return reusableView
        case UICollectionView.elementKindSectionFooter:
            // 处理footerView的情况
            guard let footer = find.dataSource.nestedContainerView(find.containerView, viewForFooterInSection: indexPath.section) else {
                // 如果找不到指定section的footerView，则返回错误的补充视图
                NestedLogger.shared.assertionFailure("No pinFooterView found for indexPath: \(indexPath)")
                return errorView()
            }
            let reuseIdentifier = String(describing: footer.trait)
            // 检查是否已注册过该重用标识的补充视图，如果没有则进行注册
            if !footerReuseIdentifiers.contains(reuseIdentifier) {
                footerReuseIdentifiers.insert(reuseIdentifier)
                collectionView.register(CollectionReusableView.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: reuseIdentifier)
            }
            // 通过重用标识从缓存池中获取补充视图，并将footerView设置到补充视图中
            // swiftlint:disable:next force_cast
            let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: reuseIdentifier, for: indexPath) as! CollectionReusableView
            reusableView.setContentViewIfNeeded(footer.view)
            return reusableView
        case Kind.headerViewPlaceholder:
            // 处理headerView占位的情况
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Reuse.headerView, for: indexPath)
        case Kind.footerViewPlaceholder:
            // 处理footerView占位的情况
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Reuse.footerView, for: indexPath)
        default:
            fatalError("Unknown kind: \(kind)")
        }
    }
}

// MARK: - UICollectionViewDelegate

extension CollectionView: UICollectionViewDelegate {
    /// 代理
    /// - Returns: 代理信息
    private func findDelegate() -> (containerView: NestedContainerView, delegate: NestedContainerViewDelegate)? {
        guard let nestedContainerView = nestedContainerView, let delegate = nestedContainerView.delegate else {
            NestedLogger.shared.warn("Cannot find delegate - nestedContainerView: \(nestedContainerView), delegate: \(nestedContainerView?.delegate)")
            return nil
        }
        return (nestedContainerView, delegate)
    }

    // MARK: - UICollectionViewDelegate

    /// 嵌套内容显示
    public func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let find = findDelegate(), let contentView = (cell as? CollectionViewCell)?.bindView else { return }
        find.delegate.nestedContainerView?(find.containerView, willDisplayContentView: contentView, forSection: indexPath.section)
    }

    public func collectionView(_: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        guard let find = findDelegate(), let view = (view as? CollectionReusableView)?.bindView else { return }
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            // 悬浮HeaderView显示
            find.delegate.nestedContainerView?(find.containerView, willDisplayHeaderView: view, forSection: indexPath.section)
        case UICollectionView.elementKindSectionFooter:
            // 悬浮FooterView显示
            find.delegate.nestedContainerView?(find.containerView, willDisplayFooterView: view, forSection: indexPath.section)
        default: ()
        }
    }

    /// 嵌套内容不显示
    public func collectionView(_: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let find = findDelegate(), let contentView = (cell as? CollectionViewCell)?.bindView else { return }
        find.delegate.nestedContainerView?(find.containerView, didEndDisplayingContentView: contentView, forSection: indexPath.section)
    }

    public func collectionView(_: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        guard let find = findDelegate(), let view = (view as? CollectionReusableView)?.bindView else { return }
        switch elementKind {
        case UICollectionView.elementKindSectionHeader:
            // 悬浮HeaderView不显示
            find.delegate.nestedContainerView?(find.containerView, didEndDisplayingHeaderView: view, forSection: indexPath.section)
        case UICollectionView.elementKindSectionFooter:
            // 悬浮FooterView不显示
            find.delegate.nestedContainerView?(find.containerView, didEndDisplayingFooterView: view, forSection: indexPath.section)
        default: ()
        }
    }
}

// swiftlint:enable line_length file_length
