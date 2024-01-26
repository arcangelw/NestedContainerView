//
//  HeadedListViewController.swift
//  Example
//
//  Created by 吴哲 on 2024/3/1.
//

import MJRefresh
import NestedContainerView
import UIKit

// swiftlint:disable line_length
final class HeadedListViewController: UIViewController, HeadedNestedAdapterDataSource, UITableViewDataSource, UITableViewDelegate {
    let headerView = HeadedHeaderView()

    let pinHeaderView = HeadedPinHeaderView()

    let contentView = SingleNestedContentView(UITableView(frame: .zero, style: .plain))
    var observation: NSKeyValueObservation?

    let nestedContainerView = NestedContainerView()
    private(set) lazy var adapter = HeadedNestedAdapter(viewController: self)

    private var isFirstLoad = true

    private var listCount = 5

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
        contentView.backgroundColor = .lightGray
        contentView.embeddedScrollView.rowHeight = 44
        contentView.embeddedScrollView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        contentView.embeddedScrollView.delegate = self
        contentView.embeddedScrollView.dataSource = self
        adapter.nestedContainerView = nestedContainerView
        adapter.headedDataSource = self
        observation = contentView.embeddedScrollView.observe(\.contentSize, options: .new, changeHandler: { [weak self] _, _ in
            self?.adapter.embeddedScrollViewDidChange()
        })
        adapter.refreshHandledByEmbeddedScrollView = true
        if adapter.refreshHandledByEmbeddedScrollView {
            contentView.embeddedScrollView.refreshControl = UIRefreshControl()
            contentView.embeddedScrollView.refreshControl?.addTarget(self, action: #selector(embeddedScrollViewRefresh), for: .valueChanged)
        } else {
            nestedContainerView.scrollView.refreshControl = UIRefreshControl()
            nestedContainerView.scrollView.refreshControl?.addTarget(self, action: #selector(containerScrollViewRefresh), for: .valueChanged)
        }
        let footer = MJRefreshAutoNormalFooter()
        footer.refreshingBlock = { [weak self] in
            self?.loadMore()
        }
        contentView.embeddedScrollView.mj_footer = footer
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isFirstLoad = false
            self.adapter.reloadData()
        }
        nestedContainerView.scrollView.scrollsToTop = true
        contentView.embeddedScrollView.scrollsToTop = !nestedContainerView.scrollView.scrollsToTop
    }

    @objc
    private func containerScrollViewRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.listCount = 5
            self.contentView.embeddedScrollView.reloadData()
            self.nestedContainerView.scrollView.refreshControl?.endRefreshing()
        }
    }

    @objc
    private func embeddedScrollViewRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.listCount = 5
            self.contentView.embeddedScrollView.reloadData()
            self.contentView.embeddedScrollView.refreshControl?.endRefreshing()
        }
    }

    private func loadMore() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.listCount += 5
            self.contentView.embeddedScrollView.reloadData()
            self.contentView.embeddedScrollView.mj_footer?.endRefreshing()
        }
    }

    func headerView(for _: HeadedNestedAdapter) -> HeadedNestedAdapterHeaderView? {
        return headerView
    }

    func pinHeaderView(for _: HeadedNestedAdapter) -> HeadedNestedAdapterPinHeaderView? {
        return pinHeaderView
    }

    func contentViewManagement(for _: HeadedNestedAdapter) -> HorizontalNestedContentViewManagement? {
        guard !isFirstLoad else { return nil }
        return contentView
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return listCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "cell row: \(indexPath.row) "
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        adapter.embeddedScrollViewEvent(.didScroll(scrollView))
    }
}

// swiftlint:enable line_length
