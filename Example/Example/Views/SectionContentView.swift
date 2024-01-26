//
//  SectionContentView.swift
//  Example
//
//  Created by 吴哲 on 2024/2/26.
//

import PinLayout
import UIKit

final class SectionContentView: UIView {
    var section: Int = -1 {
        didSet {
            label.text = "Section \(section) ContentView"
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
        backgroundColor = .blue.withAlphaComponent(0.3)
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
