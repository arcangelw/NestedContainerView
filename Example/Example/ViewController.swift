//
//  ViewController.swift
//  Example
//
//  Created by 吴哲 on 2024/2/1.
//

import UIKit

struct DemoItem {
    let name: String
    let controllerClass: UIViewController.Type
}

final class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let tableView = UITableView()

    let demoItems: [DemoItem] = [
        .init(name: "Empty View", controllerClass: EmptyViewController.self),
        .init(name: "Display View", controllerClass: DisplayViewController.self),
        .init(name: "NestList View", controllerClass: NestListViewController.self),
        .init(name: "LastSectionFooterRefresh View", controllerClass: LastSectionFooterRefreshViewController.self),
        .init(name: "HeadedList View", controllerClass: HeadedListViewController.self)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return demoItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = demoItems[indexPath.row].name
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let demo = demoItems[indexPath.row].controllerClass.init()
        navigationController?.pushViewController(demo, animated: true)
    }
}
