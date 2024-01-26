//
//  SectionHeader.swift
//  Example
//
//  Created by 吴哲 on 2024/2/26.
//

import PinLayout
import UIKit

final class SectionHeader: UIView {
    var section: Int = -1 {
        didSet {
            label.text = "Section \(section) Header"
            setNeedsLayout()
        }
    }

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
        backgroundColor = .yellow.withAlphaComponent(0.3)
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

final class SectionEditHeader: UIView {
    var section: Int = -1 {
        didSet {
            label.text = "Section \(section) Header"
            setNeedsLayout()
        }
    }

    var action: (() -> Void)?

    private let button = UIButton(type: .custom)

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
        backgroundColor = .yellow.withAlphaComponent(0.3)
        addSubview(button)
        button.setTitle("刷新", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(didTap), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        label.pin.center().sizeToFit()
        button.pin.right(15).vCenter().sizeToFit()
    }

    @objc
    private func didTap() {
        action?()
    }
}
