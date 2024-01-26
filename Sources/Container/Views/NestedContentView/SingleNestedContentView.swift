//
//  SingleNestedContentView.swift
//
//
//  Created by 吴哲 on 2024/2/2.
//

import UIKit

// swiftlint:disable line_length

/// 嵌套的单个列表内容视图
public final class SingleNestedContentView<EmbeddedScrollView: UIScrollView>: UIView, HorizontalNestedContentViewManagement, HorizontalNestedContentViewDataSource, HorizontalNestedContentViewDelegate {
    public weak var dataSource: HorizontalNestedContentViewDataSource?

    public weak var delegate: HorizontalNestedContentViewDelegate?

    /// 列表视图
    public let embeddedScrollView: EmbeddedScrollView

    /// 中间容器滚动视图，用于优化手势处理
    private let nestedScrollView = UIScrollView()

    /// 初始化方法
    /// - Parameter innerScrollView: 内部滚动视图
    public init(_ embeddedScrollView: EmbeddedScrollView) {
        self.embeddedScrollView = embeddedScrollView
        super.init(frame: .zero)
        self.dataSource = self
        self.delegate = self
        configureNestedScrollView()
    }

    /// 不支持使用storyboard或xib进行初始化
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 布局发生变化时调用
    override public func layoutSubviews() {
        super.layoutSubviews()

        // 如果bounds没有改变，则不进行布局更新
        guard bounds != nestedScrollView.frame else { return }

        nestedScrollView.frame = bounds
        nestedScrollView.contentSize = bounds.size
        embeddedScrollView.frame = nestedScrollView.bounds
    }

    /// 配置中间容器滚动视图
    private func configureNestedScrollView() {
        nestedScrollView.isPagingEnabled = true
        nestedScrollView.showsHorizontalScrollIndicator = false
        nestedScrollView.showsVerticalScrollIndicator = false
        nestedScrollView.scrollsToTop = false
        nestedScrollView.bounces = false
        nestedScrollView.contentInsetAdjustmentBehavior = .never

        addSubview(nestedScrollView)
        nestedScrollView.addSubview(embeddedScrollView)
    }

    // MARK: - HorizontalNestedContentViewDataSource

    /// 获取当前的水平嵌套内容视图。
    public func horizontalNestedContentView() -> UIView {
        return self
    }

    /// 获取当前嵌入的滚动视图。
    public func currentEmbeddedScrollView() -> UIScrollView? {
        return embeddedScrollView
    }

    /// 获取所有已加载的嵌入滚动public 视图。
    public func loadedEmbeddedScrollViews() -> [UIScrollView] {
        return [embeddedScrollView]
    }

    // MARK: - HorizontalNestedContentViewDelegate

    /// 将重置嵌入滚动视图的内容偏移量。
    public func willResetEmbeddedScrollViewContentOffset(_: UIScrollView) {}

    /// 配置水平嵌套列表的左右滑动是否启用。
    /// - Parameter isEnable: 是否启用左右滑动。
    public func setHorizontalNestedScrollView(_: Bool) {}
}

// swiftlint:enable line_length
