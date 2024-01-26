//
//  FooterController.swift
//  Example
//
//  Created by 吴哲 on 2024/2/1.
//

import NestedContainerView
import UIKit

final class FooterController: NestedHeaderFooterViewController {
    private let footer = {
        let view = HeaderFooterView()
        view.title = "FooterView"
        return view
    }()

    override func headerFooterView() -> UIView {
        return footer
    }

    override func headerFooterViewHeightMode() -> NestedContainerHeaderFooterViewHeightMode {
        return .fixed(.filled)
    }
}
