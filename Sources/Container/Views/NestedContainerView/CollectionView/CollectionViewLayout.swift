//
//  CollectionViewLayout.swift
//
//
//  Created by 吴哲 on 2024/2/27.
//

import UIKit

/// 自定义的CollectionView布局
final class CollectionViewLayout: UICollectionViewCompositionalLayout {
    /// headerView的高度
    var headerViewHeight: CGFloat = 0
    /// footerView的高度
    var footerViewHeight: CGFloat = 0

    override var collectionViewContentSize: CGSize {
        var size = super.collectionViewContentSize
        // 当没有section时，在顶部配置headerView高度占位；有section时，在布局中使用占位视图进行兼容处理
        if collectionView?.numberOfSections == 0 {
            size.height += headerViewHeight
        }
        size.height += footerViewHeight
        return size
    }
}

extension NSCollectionLayoutSection {
    /// 提供一个空布局，用于占位
    class var empty: NSCollectionLayoutSection {
        return .init(
            group: .vertical(
                layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(0.5)),
                subitems: []
            )
        )
    }
}
