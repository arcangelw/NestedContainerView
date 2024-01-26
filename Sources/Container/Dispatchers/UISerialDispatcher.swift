//
//  UISerialDispatcher.swift
//
//
//  Created by 吴哲 on 2024/2/23.
//

import Foundation

/// 串行调度器
final class UISerialDispatcher {
    /// 主线程队列特征键
    private static let dispatchSpecificKey = DispatchSpecificKey<UInt8>()
    /// 主线程队列特征值
    private static let dispatchSpecificValue = UInt8.max
    /// 一次执行标识
    private static var once: () = {
        DispatchQueue.main.setSpecific(
            key: UISerialDispatcher.dispatchSpecificKey,
            value: dispatchSpecificValue
        )
    }()

    /// 计数器
    private let counter = UnsafeMutablePointer<Int32>.allocate(capacity: 1)

    /// 初始化调度器
    init() {
        _ = UISerialDispatcher.once
        counter.initialize(to: 0)
    }

    /// 销毁调度器
    deinit {
        counter.deinitialize(count: 1)
        counter.deallocate()
    }

    /// 调度执行代码块
    /// - Parameter action: 需要执行的代码块
    func dispatch(_ action: @escaping () -> Void) {
        let count = OSAtomicIncrement32(counter)
        // swiftlint:disable:next line_length
        if count == 1, DispatchQueue.getSpecific(key: UISerialDispatcher.dispatchSpecificKey) == UISerialDispatcher.dispatchSpecificValue {
            // 当前为主线程且没有其他任务在执行，直接执行代码块
            action()
            OSAtomicDecrement32(counter)
        } else {
            // 非主线程或有其他任务在执行，将代码块放入主线程队列异步执行
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    return
                }

                action()
                OSAtomicDecrement32(self.counter)
            }
        }
    }
}
