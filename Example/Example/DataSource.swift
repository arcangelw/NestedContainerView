//
//  DataSource.swift
//  Example
//
//  Created by 吴哲 on 2024/2/1.
//

import NestedContainerView
import UIKit

struct IndexModel: Hashable, SectionDifferentiable {
    let index: Int

    func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }

    static func == (lhs: IndexModel, rhs: IndexModel) -> Bool {
        lhs.index == rhs.index
    }
}

extension IndexModel: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(type(of: self)) {index: \(index)}"
    }
}

extension NestedAdapterDataSource {
    func headerController(for _: NestedAdapter) -> NestedHeaderFooterViewController? {
        return nil
    }

    func sectionModels(for _: NestedAdapter) -> [NestedSectionModel] {
        return []
    }

    func nestedAdapter(_: NestedAdapter, sectionControllerFor _: NestedSectionModel) -> NestedSectionController? {
        return nil
    }

    func footerController(for _: NestedAdapter) -> NestedHeaderFooterViewController? {
        return nil
    }

    func emptyView(for _: NestedAdapter) -> UIView? {
        return nil
    }
}
