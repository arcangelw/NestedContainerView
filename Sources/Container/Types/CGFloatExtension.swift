//
//  CGFloatExtension.swift
//
//
//  Created by 吴哲 on 2024/1/29.
//

import UIKit

extension CGFloat {
    /// 判断是否是动态高度配置
    var isDynamic: Bool {
        return self == UITableView.automaticDimension
    }
}
