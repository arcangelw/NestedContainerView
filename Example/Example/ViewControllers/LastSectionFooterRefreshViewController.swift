//
//  LastSectionFooterRefreshViewController.swift
//  Example
//
//  Created by 吴哲 on 2024/3/4.
//

import NestedContainerView
import UIKit

final class LastSectionFooterRefreshViewController: NestedContainerViewController, NestedAdapterDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.scrollProcessorType = LastSectionFooterRefreshScrollProcessor.self
        adapter.dataSource = self
        nestedContainerView.scrollView.scrollsToTop = true
    }

    func sectionModels(for _: NestedAdapter) -> [NestedSectionModel] {
        return Array(0 ... 1).map(IndexModel.init(index:)).compactMap(NestedSectionModel.init(_:))
    }

    // swiftlint:disable:next line_length
    func nestedAdapter(_: NestedAdapter, sectionControllerFor sectionModel: NestedSectionModel) -> NestedSectionController? {
        // swiftlint:disable:next force_cast
        let model = sectionModel.base as! IndexModel
        if model.index == 0 {
            let controller = ListSectionController()
            controller.showFooter = false
            controller.listCount = 5
            controller.content.embeddedScrollView.scrollsToTop = !nestedContainerView.scrollView.scrollsToTop
            return controller
        } else {
            let controller = ListSectionFooterRefreshController()
            controller.content.embeddedScrollView.scrollsToTop = !nestedContainerView.scrollView.scrollsToTop
            return controller
        }
    }
}
