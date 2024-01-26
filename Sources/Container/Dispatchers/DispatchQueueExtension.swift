//
//  DispatchQueueExtension.swift
//
//
//  Created by 吴哲 on 2024/2/23.
//

import Foundation

extension DispatchQueue {
    /// 延时执行指定闭包。
    /// - Parameters:
    ///   - delay: 延迟执行的时间间隔，以秒为单位。
    ///   - closure: 要执行的闭包。
    func after(_ delay: TimeInterval, execute closure: @escaping () -> Void) {
        asyncAfter(deadline: .now() + delay, execute: closure)
    }

    /// 延时执行指定闭包。
    /// - Parameters:
    ///   - delay: 延迟执行的时间间隔，以秒为单位。
    ///   - workItem: 要执行的工作调度。
    func after(_ delay: TimeInterval, execute workItem: DispatchWorkItem) {
        asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}
