//
//  HeadedNestedSectionController.swift
//
//
//  Created by 吴哲 on 2024/3/1.
//

import UIKit

/// 嵌套列表内容控制器
final class HeadedNestedSectionController: HorizontalNestedContentSectionController {
    /// 悬浮headerView
    var pinHeaderView: HeadedNestedAdapterPinHeaderView?

    /// 返回部分的头部视图
    override func sectionHeaderView() -> UIView? {
        return pinHeaderView
    }

    /// 返回部分的头部视图高度
    override func sectionHeaderHeight() -> CGFloat {
        return pinHeaderView?.pinHeaderViewHeight ?? 0
    }

    /// 返回分区内容的高度。
    ///
    /// - Returns: 分区内容的高度。
    override func sectionContentHeight() -> CGFloat {
        return filledHeight()
    }
}
