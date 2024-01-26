//
//  DisplayViewController.swift
//  Example
//
//  Created by 吴哲 on 2024/2/1.
//

import NestedContainerView
import UIKit

// swiftlint:disable line_length

final class DisplayViewController: NestedContainerViewController, NestedAdapterDataSource, NestedAdapterDelegate, UIScrollViewDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.scrollViewDelegate = self
        adapter.delegate = self
        adapter.dataSource = self
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
//            guard let self = self else { return }
//            self.displayIndexs.removeAll { $0.index == 2 }
//            self.displayIndexs.append(.init(index: 2))
//            self.displayIndexs.shuffle()
//            self.displayIndexs.insert(.init(index: 1), at: 0)
//            self.adapter.reloadData()
//        }
    }

    private var displayIndexs = Array(1 ... 10).map(IndexModel.init(index:))

    func sectionModels(for _: NestedAdapter) -> [NestedSectionModel] {
        return displayIndexs.compactMap(NestedSectionModel.init(_:))
    }

    func headerController(for _: NestedAdapter) -> NestedHeaderFooterViewController? {
        return HeaderController()
    }

    func nestedAdapter(_: NestedAdapter, sectionControllerFor _: NestedSectionModel) -> NestedSectionController? {
        return DisplaySectionController()
    }

    func footerController(for _: NestedAdapter) -> NestedHeaderFooterViewController? {
        return FooterController()
    }

    func nestedAdapter(_ nestedAdapter: NestedAdapter, willDisplay _: NestedSectionModel, at section: Int) {
        guard let controller = nestedAdapter.sectionController(for: section) else { return }
        debugPrint(type(of: controller), section, #function)
    }

    func nestedAdapter(_ nestedAdapter: NestedAdapter, didEndDisplaying _: NestedSectionModel, at section: Int) {
        guard let controller = nestedAdapter.sectionController(for: section) else { return }
        debugPrint(type(of: controller), section, #function)
    }

    func nestedAdapter(_: NestedAdapter, willDisplay headerFooterViewController: NestedHeaderFooterViewController) {
        debugPrint(type(of: headerFooterViewController), #function)
    }

    func nestedAdapter(_: NestedAdapter, didEndDisplaying headerFooterViewController: NestedHeaderFooterViewController) {
        debugPrint(type(of: headerFooterViewController), #function)
    }

    func scrollViewShouldScrollToTop(_: UIScrollView) -> Bool {
        debugPrint(type(of: self), #function)
        return Bool.random()
    }

    func scrollViewDidScrollToTop(_: UIScrollView) {
        debugPrint(type(of: self), #function)
    }
}

// swiftlint:enable line_length
