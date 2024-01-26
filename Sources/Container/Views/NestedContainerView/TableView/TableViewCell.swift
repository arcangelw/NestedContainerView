//
//  TableViewCell.swift
//
//
//  Created by 吴哲 on 2024/2/27.
//

import UIKit

/// TableView容器Cell
final class TableViewCell: UITableViewCell {
    /// 绑定的内容视图
    weak var bindView: UIView?

    /// 初始化
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// 设置内容视图
    ///
    /// - Parameter view: 要绑定的内容视图
    func setContentViewIfNeeded(_ view: UIView) {
        bindView = view
        if view.superview != contentView {
            contentView.addSubview(view)
        }
        // 确保cell的大小已经确定
        guard contentView.bounds.size != .zero else { return }
        // 如果内容视图的frame不等于cell的bounds，则将其调整为cell的bounds
        if view.frame != contentView.bounds {
            view.frame = contentView.bounds
        }
    }

    /// 布局变化时调用
    override func layoutSubviews() {
        super.layoutSubviews()
        // 如果内容视图的frame不等于cell的bounds，则将其调整为cell的bounds
        if bindView?.frame != contentView.bounds {
            bindView?.frame = contentView.bounds
        }
    }
}
