//
//  NestedContainerContext.swift
//
//
//  Created by 吴哲 on 2024/1/26.
//

import UIKit

// swiftlint:disable line_length

/// 嵌套容器适配器上下文信息
/// 这里不需要将实现细节对外暴露，提供一个协议接口给相关控制器调用
public protocol NestedContainerContext: AnyObject {
    /// 绑定的嵌套容器
    var nestedContainerView: NestedContainerView? { get }
    /// 当前适配器所在的控制器
    var viewController: UIViewController? { get }
    /// 容器的尺寸
    var containerSize: CGSize { get }
    /// 容器的特征信息
    var traitCollection: UITraitCollection { get }
    /// 容器的内容偏移
    var containerContentOffset: CGPoint { get }
    /// 容器的滚动特征信息
    var scrollingTrait: NestedContainerScrollingTrait { get }

    /// 获取容器内占用的尺寸
    ///
    /// - Parameter sectionController: 需要计算的控制器
    /// - Returns: 在容器内的尺寸
    func containerSize(for sectionController: NestedSectionController) -> CGSize

    /// 嵌入式滚动视图滚动时的事件回调
    ///
    /// - Parameters:
    ///   - event: 嵌入式滚动视图事件
    ///   - sectionController: 当前控制器
    func embeddedScrollViewEvent(_ event: NestedEmbeddedScrollViewEvent, for sectionController: NestedSectionController)

    /// 配置布局无效并重置
    ///
    /// - Parameters:
    ///   - sectionController: 需要配置的控制器
    ///   - completion: 配置完成后的回调
    func invalidateLayout(in sectionController: NestedSectionController, completion: ((_ finished: Bool) -> Void)?)

    /// 配置布局无效并重置
    ///
    /// - Parameters:
    ///   - headerFooterViewController: 需要配置的页眉/页脚视图控制器
    ///   - completion: 配置完成后的回调
    func invalidateLayout(in headerFooterViewController: NestedHeaderFooterViewController, completion: ((_ finished: Bool) -> Void)?)

    /// 滚动容器到指定的控制器
    ///
    /// - Parameters:
    ///   - sectionController: 要滚动到的控制器
    ///   - animated: 是否需要动画效果
    ///   - completion: 滚动完成后的回调，参数为滚动是否完成的布尔值
    func scrollContainer(to sectionController: NestedSectionController, animated: Bool, completion: ((_ finished: Bool) -> Void)?)

    /// 滚动容器到指定的头部/尾部视图控制器
    ///
    /// - Parameters:
    ///   - headerFooterViewController: 要滚动到的头部/尾部视图控制器
    ///   - animated: 是否需要动画效果
    ///   - completion: 滚动完成后的回调，参数为滚动是否完成的布尔值
    func scrollContainer(to headerFooterViewController: NestedHeaderFooterViewController, animated: Bool, completion: ((_ finished: Bool) -> Void)?)
}

// swiftlint:enable line_length
