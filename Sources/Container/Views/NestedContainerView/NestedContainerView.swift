//
//  NestedContainerView.swift
//
//
//  Created by 吴哲 on 2024/1/26.
//

import UIKit

/// 嵌套容器视图
open class NestedContainerView: UIView {
    // MARK: - Public

    /// 嵌套容器手势协议
    public weak var gestureDelegate: NestedContainerViewGestureDelegate?

    /// 滑动指示器配色
    public var indicatorColor: UIColor? {
        get {
            scrollIndicator.indicatorView.backgroundColor
        }
        set {
            scrollIndicator.indicatorView.backgroundColor = newValue
        }
    }

    /// 配置 adjustedContentInset 的行为模式 默认 automatic
    public var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
        get {
            scrollView.contentInsetAdjustmentBehavior
        }
        set {
            scrollView.contentInsetAdjustmentBehavior = newValue
        }
    }

    /// 内容尺寸
    @objc
    public private(set) dynamic
    var contentSize: CGSize

    /// 内容偏移量
    @objc
    public private(set) dynamic
    var contentOffset: CGPoint = .zero

    /// 滚动特征
    public private(set) dynamic
    var scrollingTrait: NestedContainerScrollingTrait

    /// 内置容器
    open class var containerScrollViewClass: NestedContainerScrollView.Type {
        return CollectionView.self
    }

    // MARK: - Internal

    /// 数据协议
    weak var dataSource: NestedContainerViewDataSource?
    /// 代理协议
    weak var delegate: NestedContainerViewDelegate? {
        didSet {
            scrollView.delegateChange()
        }
    }

    /// 滚动容器视图
    public let scrollView: NestedContainerScrollView

    /// 滚动指示器
    let scrollIndicator = NestedScrollIndicator()

    /// 绑定适配器
    weak var nestedAdapter: NestedAdapter?

    // MARK: - Public Methods

    override public init(frame: CGRect) {
        var frame = frame
        if frame.size.width.isZero {
            frame.size.width = UIScreen.main.bounds.width
        }
        if frame.size.height.isZero {
            frame.size.height = UIScreen.main.bounds.height
        }
        self.scrollView = type(of: self).containerScrollViewClass.init(size: frame.size)
        self.contentSize = .init(width: frame.width, height: 0)
        self.scrollingTrait = .init(containerScrollView: scrollView)
        super.init(frame: frame)
        scrollView.bind(self)
        scrollView.containerSizeDidChange = { [weak self] in
            self?.nestedAdapter?.containerSizeDidChange()
        }
        addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        addSubview(scrollIndicator)
        scrollIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollIndicator.topAnchor.constraint(equalTo: topAnchor),
            scrollIndicator.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollIndicator.bottomAnchor.constraint(equalTo: bottomAnchor),
            scrollIndicator.widthAnchor.constraint(equalToConstant: 6)
        ])
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        if contentSize.width != bounds.width {
            contentSize.width = bounds.width
        }
    }

    /// 内容滚动时调用
    /// - Parameters:
    ///   - offset: 偏移量
    ///   - isActive: 滚动特征参数
    func didScroll(_ offset: CGFloat, scrollingTrait: NestedContainerScrollingTrait) {
        if contentOffset.y != offset {
            contentOffset.y = offset
        }
        if self.scrollingTrait != scrollingTrait {
            self.scrollingTrait = scrollingTrait
        }
        let isActive = scrollingTrait.isTracking || scrollingTrait.isDragging || scrollingTrait.isDecelerating
        scrollIndicator.didScroll(offset, isActive: isActive)
    }

    /// 内容高度发生变化时调用
    /// - Parameter height: 新的内容高度
    func contentHeightDidChange(_ height: CGFloat) {
        if contentSize.height != height {
            contentSize.height = height
        }
        scrollIndicator.contentHeightDidChange(height)
    }
}

/// 使用UICollectionView的嵌套容器
public class NestedContainerUsingUICollectionView: NestedContainerView {
    override public class var containerScrollViewClass: any NestedContainerScrollView.Type {
        return CollectionView.self
    }
}

/// 使用UITableView的嵌套容器
public class NestedContainerUsingUITableView: NestedContainerView {
    override public class var containerScrollViewClass: any NestedContainerScrollView.Type {
        return TableView.self
    }
}
