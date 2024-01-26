//
//  QueuedCompletionDispatcher.swift
//
//
//  Created by 吴哲 on 2024/1/30.
//

import Foundation

/// 完结回调调度队列
final class QueuedCompletionDispatcher {
    /// 顺序存储完结代码块
    private var completionBlocks: [() -> Void] = []

    /// 批量更新时的延迟
    /// - Parameter block: 完结回调
    func deferBlockBetweenBatchUpdates(_ block: @escaping () -> Void) {
        if completionBlocks.isEmpty {
            block()
        } else {
            completionBlocks.append(block)
        }
    }

    /// 即将批量更新
    func enterBatchUpdates() {
        // 清除现有完结回调
        completionBlocks.removeAll()
    }

    /// 完成批量更新
    func exitBatchUpdates() {
        // 执行完结回调
        let blocks = completionBlocks
        completionBlocks.removeAll()
        for block in blocks {
            block()
        }
    }
}
