//
//  NestedScrollIndicator.swift
//
//
//  Created by 吴哲 on 2024/2/23.
//

import UIKit

/// 嵌套容器滚动指示器
final class NestedScrollIndicator: UIView {
    /// 指示器视图
    private(set) lazy var indicatorView: UIView = {
        let view = UIView(frame: indicatorFrame)
        view.backgroundColor = .black.withAlphaComponent(0.3)
        view.layer.cornerRadius = 1.5
        view.alpha = 0
        return view
    }()

    /// 隐藏指示器任务
    private var hideIndicatorTask: DispatchWorkItem?

    /// 容器内容高度
    private var contentHeight: CGFloat = 0

    /// 当前容器偏移量
    private var currentOffset: CGFloat = 0

    /// 指示器位置尺寸
    private var indicatorFrame: CGRect = .init(origin: .zero, size: .init(width: 3, height: 10))

    /// 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        addSubview(indicatorView)
    }

    /// 不支持使用storyboard或xib进行初始化
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 释放资源
    deinit {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
    }

    /// 布局发生变化时调用
    override func layoutSubviews() {
        super.layoutSubviews()
        contentHeightDidChange(contentHeight)
    }

    /// 内容滚动时调用
    /// - Parameters:
    ///   - offset: 偏移量
    ///   - isActive: 滚动是否处于活跃状态
    func didScroll(_ offset: CGFloat, isActive: Bool) {
        let hideSelector = #selector(hideIndicator)
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: hideSelector, object: nil)
        if !isActive {
            // 如果滚动不活跃，则延时隐藏指示器
            perform(hideSelector, with: nil, afterDelay: 0.25)
        }

        if !isHidden, isActive {
            indicatorView.alpha = 1.0
        }

        guard currentOffset != offset else { return }

        currentOffset = offset
        updateOffset(offset)
    }

    /// 内容高度发生变化时调用
    /// - Parameter height: 新的内容高度
    func contentHeightDidChange(_ height: CGFloat) {
        let height = max(height, bounds.height)
        guard contentHeight != height else { return }
        contentHeight = height
        guard contentHeight > 0 else { return }

        // 根据内容高度更新指示器的尺寸
        indicatorFrame.size.height = max(10, bounds.height * (bounds.height / contentHeight))
        updateOffset(currentOffset)
    }

    /// 更新指示器的位置
    /// - Parameter offset: 新的偏移量
    private func updateOffset(_ offset: CGFloat) {
        let progress: CGFloat

        if contentHeight > bounds.height {
            progress = offset / (contentHeight - bounds.height)
        } else {
            progress = 0
        }

        let top = (bounds.height - indicatorFrame.height) * progress

        indicatorFrame = CGRect(x: bounds.width - 6, y: top, width: indicatorFrame.width, height: indicatorFrame.height)

        UIView.animate(withDuration: 0) {
            self.indicatorView.frame = self.indicatorFrame
        }
    }

    /// 隐藏指示器
    @objc
    private func hideIndicator() {
        UIView.animate(withDuration: 1.0) {
            self.indicatorView.alpha = 0
        }
    }
}
