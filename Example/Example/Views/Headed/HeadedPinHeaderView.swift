//
//  HeadedPinHeaderView.swift
//  Example
//
//  Created by 吴哲 on 2024/3/1.
//

import NestedContainerView
import UIKit

final class HeadedPinHeaderView: UIView, HeadedNestedAdapterPinHeaderView {
    var pinHeaderViewHeight: CGFloat = 40
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .red
        self.frame.size.height = pinHeaderViewHeight
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
