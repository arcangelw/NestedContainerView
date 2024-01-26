//
//  EmptyView.swift
//  Example
//
//  Created by 吴哲 on 2024/2/26.
//

import PinLayout
import UIKit

final class EmptyView: UIView {
    private let label = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.backgroundColor = .clear
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        backgroundColor = .gray.withAlphaComponent(0.3)
        label.text = "No more data!"
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.pin.center().sizeToFit()
    }
}
