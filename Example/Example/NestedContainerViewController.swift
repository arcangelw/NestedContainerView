//
//  NestedContainerViewController.swift
//  Example
//
//  Created by 吴哲 on 2024/2/1.
//

import NestedContainerView
import UIKit

class NestedContainerViewController: UIViewController {
    let nestedContainerView = NestedContainerView()
    private(set) lazy var adapter = NestedAdapter(viewController: self)
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(nestedContainerView)
        nestedContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: nestedContainerView.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: nestedContainerView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: nestedContainerView.trailingAnchor),
            view.safeAreaLayoutGuide.topAnchor.constraint(equalTo: nestedContainerView.topAnchor)
        ])
        adapter.nestedContainerView = nestedContainerView
    }
}
