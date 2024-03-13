//
//  CGFloatExtension.swift
//
//
//  Created by 吴哲 on 2024/1/29.
//

import UIKit

extension CGFloat {
    /// 一像素
    static let onePixel: CGFloat = 1.0 / Swift.max(1.0, UITraitCollection.current.displayScale)

    /// 判断是否是动态高度配置
    var isDynamic: Bool {
        return self == UITableView.automaticDimension
    }
}
