//
//  OnceDispatcher.swift
//
//
//  Created by 吴哲 on 2024/2/23.
//

import Foundation

/// 一次性执行调度器
final class OnceDispatcher {
    /// 一次性跟踪器，用于存储闭包的标识符
    private static var onceTracker = [String]()

    /// 调度执行闭包
    /// - Parameters:
    ///   - file: 调用所在的文件路径
    ///   - function: 调用所在的方法名
    ///   - line: 调用所在的行数
    ///   - block: 要执行的闭包
    static func dispatch(file: String = #file, function: String = #function, line: Int = #line, block: () -> Void) {
        let token = file + ":" + function + ":" + String(line)
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        if onceTracker.contains(token) {
            return
        }
        onceTracker.append(token)
        block()
    }
}
