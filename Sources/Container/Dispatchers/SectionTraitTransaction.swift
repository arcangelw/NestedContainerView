//
//  SectionTraitTransaction.swift
//  WZNestedContainerView
//
//  Created by 吴哲 on 2024/3/19.
//

import CoreFoundation

enum SectionTraitTransaction {
    /// 存储适配器的弱引用集合
    private static let adapters: NSHashTable<NestedAdapter> = .init(options: .weakMemory)

    /// 当前的主线程 RunLoop 观察者
    private static var currentObserver: CFRunLoopObserver?

    /// 添加需要检查的适配器
    /// - Parameter adapter: 适配器实例
    static func addCheck(_ adapter: NestedAdapter) {
        if !adapters.contains(adapter) {
            adapters.add(adapter)
        }
        guard !adapters.allObjects.isEmpty else { return }
        registerAsMainRunloopObserver()
    }

    /// 移除需要检查的适配器
    /// - Parameter adapter: 适配器实例
    static func removeCheck(_ adapter: NestedAdapter) {
        if adapters.contains(adapter) {
            adapters.remove(adapter)
        }
        guard adapters.allObjects.isEmpty else { return }
        unRegisterAsMainRunloopObserver()
    }

    /// 将当前类注册为主线程的 RunLoop 观察者
    private static func registerAsMainRunloopObserver() {
        guard currentObserver == nil else { return }
        // 获取主线程的 RunLoop 实例
        let runLoop = CFRunLoopGetMain()
        // 创建 RunLoop 观察者并设置回调处理程序
        // 观察 BeforeWaiting 和 Exit 事件，并在发生时执行回调
        let observer = CFRunLoopObserverCreateWithHandler(
            nil, CFRunLoopActivity.beforeWaiting.rawValue | CFRunLoopActivity.exit.rawValue,
            true, .max, { _, _ in
                SectionTraitTransaction.commit()
            }
        )
        currentObserver = observer
        // 将观察者添加到 RunLoop 的 commonModes 模式中
        // 这样在 RunLoop 的每个循环中都会检查观察者事件
        CFRunLoopAddObserver(runLoop, observer, .commonModes)
    }

    /// 将当前类注销为主线程的 RunLoop 观察者
    private static func unRegisterAsMainRunloopObserver() {
        guard let observer = currentObserver else { return }
        currentObserver = nil
        // 获取主线程的 RunLoop 实例
        let runLoop = CFRunLoopGetMain()
        if CFRunLoopContainsObserver(runLoop, observer, .commonModes) {
            CFRunLoopRemoveObserver(runLoop, observer, .commonModes)
        }
        if CFRunLoopObserverIsValid(observer) {
            CFRunLoopObserverInvalidate(observer)
        }
    }

    /// 执行适配器的内容特性检查
    private static func commit() {
        let toCheckAdapters = adapters.allObjects
        for adapter in toCheckAdapters {
            adapter.checkContentTrait()
        }
    }
}
