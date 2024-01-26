//
//  NestListViewController.swift
//  Example
//
//  Created by 吴哲 on 2024/2/1.
//

import NestedContainerView
import UIKit

final class NestListViewController: NestedContainerViewController, NestedAdapterDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.dataSource = self
        nestedContainerView.scrollView.scrollsToTop = true
    }

    func sectionModels(for _: NestedAdapter) -> [NestedSectionModel] {
        return Array(0 ... 9).map(IndexModel.init(index:)).compactMap(NestedSectionModel.init(_:))
    }

    func headerController(for _: NestedAdapter) -> NestedHeaderFooterViewController? {
        return HeaderController()
    }

    // swiftlint:disable:next line_length
    func nestedAdapter(_: NestedAdapter, sectionControllerFor sectionModel: NestedSectionModel) -> NestedSectionController? {
        // swiftlint:disable:next force_cast
        let model = sectionModel.base as! IndexModel
        if model.index % 2 == 0 {
            let displaySecton = DisplaySectionController()
            displaySecton.isDisableDebugPrint = true
            return displaySecton
        } else {
            let controller = ListSectionController()
            controller.content.embeddedScrollView.scrollsToTop = !nestedContainerView.scrollView.scrollsToTop
            return controller
        }
    }

    func footerController(for _: NestedAdapter) -> NestedHeaderFooterViewController? {
        return FooterController()
    }
}
