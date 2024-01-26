//
//  NestedContainerScrollView.swift
//
//
//  Created by 吴哲 on 2024/2/26.
//

import UIKit

/// 嵌套滚动容器协议
public protocol NestedContainerScrollView: UIScrollView {
    /// 默认初始化
    init()

    /// 是否调用滚动到顶部方法
    var callScrollsToTop: Bool { get set }

    /// 返回嵌套容器的section数量
    var numberOfSections: Int { get }

    /// 返回当前可见内容的section索引数组
    var sectionsForVisibleContentViews: [Int] { get }

    /// 返回当前显示的内容视图数组
    var visibleContentViews: [UIView] { get }

    /// 绑定的嵌套容器视图
    var nestedContainerView: NestedContainerView? { get }

    /// 头部视图
    var headerView: UIView? { get set }

    /// 尾部视图
    var footerView: UIView? { get set }

    /// 背景视图
    var backgroundView: UIView? { get set }

    /// 容器尺寸变化
    var containerSizeDidChange: (() -> Void)? { get set }

    /// 刷新数据
    func reloadData()

    /// 使布局失效并触发重置
    ///
    /// - Parameters:
    ///   - completion: 重置完成后的回调
    func invalidateLayout(completion: ((_ finished: Bool) -> Void)?)

    /// 使指定的一组 section 的布局失效并触发重置
    ///
    /// - Parameters:
    ///   - sections: 需要使布局失效的 section 的索引数组
    ///   - completion: 重置完成后的回调闭包，接收一个布尔值参数表示重置是否完成
    func invalidateLayout(in sections: [Int], completion: ((_ finished: Bool) -> Void)?)

    /// 将嵌套容器绑定到当前滚动容器
    ///
    /// - Parameter nestedContainerView: 要绑定的嵌套容器视图
    func bind(_ nestedContainerView: NestedContainerView)

    /// 处理代理的变化
    func delegateChange()
}

extension NestedContainerScrollView {
    /// 检查是否响应嵌套容器视图的代理方法
    /// - Parameter aSelector: 要检查的Selector
    /// - Returns: 如果嵌套容器视图的delegate响应该Selector，则返回true；否则返回false。
    func respondsToNestedContainerViewDelegate(_ aSelector: Selector!) -> Bool {
        // 检查allScrollDelegates是否包含aSelector，并且检查nestedContainerView的delegate是否响应aSelector
        return allScrollDelegates.contains(aSelector) && nestedContainerView?.delegate?.responds(to: aSelector) ?? false
    }
}

/// 需要转发的UIScrollView代理方法列表
private let allScrollDelegates: [Selector] = [
    #selector(UIScrollViewDelegate.scrollViewDidScroll(_:)),
    #selector(UIScrollViewDelegate.scrollViewDidZoom(_:)),
    #selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)),
    #selector(UIScrollViewDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)),
    #selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:)),
    #selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating(_:)),
    #selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:)),
    #selector(UIScrollViewDelegate.scrollViewDidEndScrollingAnimation(_:)),
    #selector(UIScrollViewDelegate.scrollViewShouldScrollToTop(_:)),
    #selector(UIScrollViewDelegate.scrollViewDidScrollToTop(_:)),
    #selector(UIScrollViewDelegate.scrollViewDidChangeAdjustedContentInset(_:))
]

extension UIScrollView {
    /// 判断是否是嵌套容器滚动视图
    public var isNestedContainerScrollView: Bool {
        return self is NestedContainerScrollView
    }
}
