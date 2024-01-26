//
//  NestedLogger.swift
//
//
//  Created by 吴哲 on 2024/2/27.
//

/// 嵌套日志记录器
public final class NestedLogger {
    // MARK: - Lifecycle

    /// 初始化嵌套日志记录器
    ///
    /// - Parameters:
    ///   - assert: 断言处理闭包，默认使用Swift.assert
    ///   - assertionFailure: 断言失败处理闭包，默认使用Swift.assertionFailure
    ///   - warn: 警告处理闭包，默认在DEBUG模式下打印日志
    public init(
        assert: @escaping Assert = { condition, message, file, line in
            // 如果直接使用`assert: Assert = Swift.assert`来默认使用Swift.assert，
            // 调用将意外地不受 -O 标志的影响，并且在发布模式下会崩溃
            // https://github.com/apple/swift/issues/60249
            Swift.assert(condition(), message(), file: file, line: line)
        },
        assertionFailure: @escaping AssertionFailure = { message, file, line in
            // 如果直接使用`assertionFailure: AssertionFailure = Swift.assertionFailure`来默认使用Swift.assertionFailure，
            // 调用将意外地不受 -O 标志的影响，并且在发布模式下会崩溃
            // https://github.com/apple/swift/issues/60249
            Swift.assertionFailure(message(), file: file, line: line)
        },
        warn: @escaping Warn = { message, _, _ in
            #if DEBUG
            print(message())
            #endif
        }
    ) {
        self._assert = assert
        self._assertionFailure = assertionFailure
        self._warn = warn
    }

    // MARK: - Public

    /// 记录断言发生的日志。
    public typealias Assert = (
        _ condition: @autoclosure () -> Bool,
        _ message: @autoclosure () -> String,
        _ fileID: StaticString,
        _ line: UInt
    ) -> Void

    /// 记录断言失败发生的日志。
    public typealias AssertionFailure = (
        _ message: @autoclosure () -> String,
        _ fileID: StaticString,
        _ line: UInt
    ) -> Void

    /// 记录警告消息的日志。
    public typealias Warn = (
        _ message: @autoclosure () -> String,
        _ fileID: StaticString,
        _ line: UInt
    ) -> Void

    /// 用于记录Epoxy断言和警告的共享实例。
    ///
    /// 将其设置为新的日志记录器实例以拦截Epoxy记录的断言和警告。
    public static var shared = NestedLogger()

    /// 记录断言发生的日志。
    public func assert(
        _ condition: @autoclosure () -> Bool,
        _ message: @autoclosure () -> String = String(),
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) {
        _assert(condition(), message(), fileID, line)
    }

    /// 记录断言失败发生的日志。
    public func assertionFailure(
        _ message: @autoclosure () -> String = String(),
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) {
        _assertionFailure(message(), fileID, line)
    }

    /// 记录警告消息的日志。
    public func warn(
        _ message: @autoclosure () -> String = String(),
        fileID: StaticString = #fileID,
        line: UInt = #line
    ) {
        _warn(message(), fileID, line)
    }

    // MARK: - Private

    private let _assert: Assert
    private let _assertionFailure: AssertionFailure
    private let _warn: Warn
}
