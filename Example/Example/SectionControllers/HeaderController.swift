//
//  HeaderController.swift
//  Example
//
//  Created by 吴哲 on 2024/2/1.
//

import NestedContainerView
import UIKit

final class HeaderController: NestedHeaderFooterViewController {
    private let header = {
        let view = HeaderFooterView()
        view.title = "HeaderView"
        return view
    }()

    override func headerFooterView() -> UIView {
        return header
    }

    override func headerFooterViewHeightMode() -> NestedContainerHeaderFooterViewHeightMode {
        return .fixed(.absolute(200))
    }
}
