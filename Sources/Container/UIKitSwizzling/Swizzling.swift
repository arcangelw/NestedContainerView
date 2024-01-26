//
//  Swizzling.swift
//
//
//  Created by 吴哲 on 2024/2/23.
//

import ObjectiveC
import UIKit

// swiftlint:disable line_length

enum Swizzling {
    /// 交换方法实现。
    ///
    /// - Parameters:
    ///   - cls: 目标类。
    ///   - originSelector: 原始方法选择器。
    ///   - swizzleSelector: 交换方法选择器。
    static func swizzleMethod(_ cls: AnyClass?, _ originSelector: Selector, _ swizzleSelector: Selector) {
        let originMethod = class_getInstanceMethod(cls, originSelector)
        let swizzleMethod = class_getInstanceMethod(cls, swizzleSelector)

        guard let swMethod = swizzleMethod, let oMethod = originMethod else {
            return
        }

        let didAddSuccess: Bool = class_addMethod(cls, originSelector, method_getImplementation(swMethod), method_getTypeEncoding(swMethod))

        if didAddSuccess {
            class_replaceMethod(cls, swizzleSelector, method_getImplementation(oMethod), method_getTypeEncoding(oMethod))
        } else {
            method_exchangeImplementations(oMethod, swMethod)
        }
    }

    /// hook UIKit相关代码 用以适配框架底层交互
    static func hookUIKit() {
        do {
//            if let data = Data(base64Encoded: "X25vdGlmeURpZFNjcm9sbA==") {
//                let originSelector = Selector(String(decoding: data, as: UTF8.self))
//                let swizzleSelector = #selector(UIScrollView.nested_scrollViewDidScroll)
//                swizzleMethod(UIScrollView.self, originSelector, swizzleSelector)
//            }
        }
    }
}

extension UIScrollView {
    @objc
    public dynamic func nested_scrollViewDidScroll() {
        nested_scrollViewDidScroll()
    }
}

// swiftlint:enable line_length
