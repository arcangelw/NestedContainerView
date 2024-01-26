//
//  EmptyViewController.swift
//  Example
//
//  Created by 吴哲 on 2024/2/1.
//

import NestedContainerView
import UIKit

final class EmptyViewController: NestedContainerViewController, NestedAdapterDataSource {
    let emptyView = EmptyView()

    override func viewDidLoad() {
        super.viewDidLoad()
        adapter.dataSource = self
    }

    func emptyView(for _: NestedAdapter) -> UIView? {
        return emptyView
    }
}
