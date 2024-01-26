//
//  SectionIdentifiable.swift
//
//
//  Created by 吴哲 on 2024/2/1.
//

import Foundation

/// 协议：可区分Section标识
public protocol SectionIdentifiable {
    /// 唯一标识符类型
    associatedtype UniqueIdentifier: Hashable
    /// 用于区分Section的唯一标识
    var uniqueIdentifier: UniqueIdentifier { get }
}

/// 默认实现：遵循Hashable协议的Section
extension SectionIdentifiable where Self: Hashable {
    /// 如果Section遵循Hashable协议，将自身作为唯一标识
    @inlinable
    public var uniqueIdentifier: Self {
        return self
    }
}
