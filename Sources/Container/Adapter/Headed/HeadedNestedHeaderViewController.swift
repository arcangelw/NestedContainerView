//
//  HeadedNestedHeaderViewController.swift
//
//
//  Created by 吴哲 on 2024/3/1.
//

import UIKit

/// 嵌套列表HeaderView控制器
final class HeadedNestedHeaderViewController: NestedHeaderFooterViewController {
    /// headerView
    var headerView: HeadedNestedAdapterHeaderView?

    /// 返回头部视图。
    override func headerFooterView() -> UIView {
        guard let headerView = headerView else {
            NestedLogger.shared.assertionFailure("headerView is nil")
            return UIView()
        }
        return headerView
    }

    /// 返回头部视图的高度模式。
    override func headerFooterViewHeightMode() -> NestedContainerHeaderFooterViewHeightMode {
        guard let headerView = headerView else {
            NestedLogger.shared.assertionFailure("headerView is nil")
            return .fixed(.absolute(0))
        }
        return .pin(
            .absolute(headerView.headerViewHeight),
            pinToVisibleHeightMode: .absolute(headerView.headerViewPinHeight)
        )
    }
}
