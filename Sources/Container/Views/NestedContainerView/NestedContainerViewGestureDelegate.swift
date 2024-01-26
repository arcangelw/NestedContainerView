//
//  NestedContainerViewGestureDelegate.swift
//
//
//  Created by 吴哲 on 2024/1/26.
//

import UIKit

// swiftlint:disable line_length

/// 嵌套容器手势协议
public protocol NestedContainerViewGestureDelegate: AnyObject {
    /// 当嵌套内容中有水平滚动的scrollView正在左右滑动时，防止与列表的上下滑动手势冲突。通过此代理方法进行对应处理。
    /// - Parameters:
    ///   - gestureRecognizer: 当前手势识别器
    ///   - otherGestureRecognizer: 其他手势识别器
    /// - Returns: 是否允许同时识别两个手势
    func nestedNestedContainerViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
}

extension NestedContainerViewGestureDelegate {
    /// 默认实现，当嵌套容器中的手势识别器和其他手势识别器都是滑动手势时，允许同时识别两个手势
    public func nestedNestedContainerViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) && otherGestureRecognizer.isKind(of: UIPanGestureRecognizer.self)
    }
}

// swiftlint:enable line_length
