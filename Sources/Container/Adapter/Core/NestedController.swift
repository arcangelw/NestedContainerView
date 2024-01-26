//
//  NestedController.swift
//
//
//  Created by 吴哲 on 2024/1/29.
//

import UIKit

/// 嵌套控制器基础协议
protocol NestedController: AnyObject {
    /// 所在控制器
    var viewController: UIViewController? { get set }
    /// 适配器上下文信息
    var containerContext: NestedContainerContext? { get set }
}
