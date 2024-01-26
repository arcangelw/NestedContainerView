//
//  HeadedHeaderView.swift
//  Example
//
//  Created by 吴哲 on 2024/3/1.
//

import NestedContainerView
import UIKit

final class HeadedHeaderView: UIView, HeadedNestedAdapterHeaderView {
    var headerViewHeight: CGFloat = 240
    var headerViewPinHeight: CGFloat = 40

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .yellow
        self.frame.size.height = headerViewHeight
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
