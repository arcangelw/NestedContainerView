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
        if frame.size == .zero {
            frame.size = UIScreen.main.bounds.size
        }
        self.scrollView = type(of: self).containerScrollViewClass.init()
        super.init(frame: frame)
        scrollView.frame = bounds
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
}
