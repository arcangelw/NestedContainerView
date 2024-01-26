//
//  SectionFooter.swift
//  Example
//
//  Created by 吴哲 on 2024/2/26.
//

import PinLayout
import UIKit

final class SectionFooter: UIView {
    var section: Int = -1 {
        didSet {
            label.text = "Section \(section) Footer"
            setNeedsLayout()
        }
    }

    private let label = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .left
        label.backgroundColor = .white
        label.backgroundColor = .clear
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        backgroundColor = .green.withAlphaComponent(0.3)
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
