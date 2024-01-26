//
//  CollectionReusableView.swift
//
//
//  Created by 吴哲 on 2024/2/27.
//

import UIKit

/// 用于包装可复用视图的协议，继承自UICollectionReusableView
protocol CollectionReusableViewWrapper: UICollectionReusableView {
    /// 绑定的视图
    var bindView: UIView? { get set }
    /// 内容视图
    var contentView: UIView { get }
}

extension CollectionReusableViewWrapper {
    /// 设置内容视图
    func setContentViewIfNeeded(_ view: UIView) {
        // 如果绑定的视图与传入的视图不同，并且绑定的视图的父视图是内容视图，则将绑定的视图从父视图中移除
        if bindView !== view, bindView?.superview === contentView {
            bindView?.removeFromSuperview()
        }
        bindView = view
        // 如果传入的视图的父视图不是内容视图，则将传入的视图添加到内容视图中
        if view.superview !== contentView {
            contentView.addSubview(view)
        }
        // 如果内容视图的尺寸不为零，则将传入的视图的frame设置为与内容视图相同的尺寸
        guard contentView.bounds.size != .zero else { return }
        if view.frame != contentView.bounds {
            view.frame = contentView.bounds
        }
    }

    /// 视图布局变化
    fileprivate func layout() {
        // 如果绑定的视图的frame与内容视图的bounds不同，则将绑定的视图的frame设置为与内容视图相同的尺寸
        if bindView?.frame != contentView.bounds {
            bindView?.frame = contentView.bounds
        }
    }
}

/// 提供一个用于包装Cell的容器类
final class CollectionViewCell: UICollectionViewCell, CollectionReusableViewWrapper {
    weak var bindView: UIView?

    /// 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 视图布局变化
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
}

/// 提供一个用于包装ReusableView的容器类
final class CollectionReusableView: UICollectionReusableView, CollectionReusableViewWrapper {
    weak var bindView: UIView?
    var contentView: UIView {
        return self
    }

    /// 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 视图布局变化
    override func layoutSubviews() {
        super.layoutSubviews()
        layout()
    }
}
