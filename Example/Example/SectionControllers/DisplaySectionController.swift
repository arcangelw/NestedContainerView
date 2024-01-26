//
//  DisplaySectionController.swift
//  Example
//
//  Created by 吴哲 on 2024/2/1.
//

import NestedContainerView
import UIKit

final class DisplaySectionController: NestedSectionController, NestedDisplayDelegate {
    private lazy var header = SectionHeader()
    private lazy var content = SectionContentView()
    private lazy var footer = SectionFooter()

    var isDisableDebugPrint: Bool = false {
        didSet {
            displayDelegate = isDisableDebugPrint ? nil : self
        }
    }

    override init() {
        super.init()
        displayDelegate = self
    }

    override func sectionDidChange() {
        header.section = section
        content.section = section
        footer.section = section
    }

    override func sectionHeaderView() -> UIView? {
        return header
    }

    override func sectionHeaderHeight() -> CGFloat {
        return 20
    }

    override func sectionContentView() -> UIView {
        return content
    }

    override func sectionContentHeightMode() -> NestedSectionContentHeightMode {
        return .fixed(.fractionalHeight(0.3))
    }

    override func sectionFooterView() -> UIView? {
        return footer
    }

    override func sectionFooterHeight() -> CGFloat {
        return 20
    }

    func nestedAdapter(_: NestedAdapter, willDisplay _: NestedSectionController) {
        debugPrint(type(of: self), section, #function, "add")
    }

    func nestedAdapter(_: NestedAdapter, didEndDisplaying _: NestedSectionController) {
        debugPrint(type(of: self), section, #function, "remove")
    }

    func nestedAdapter(_: NestedAdapter, willDisplay _: UIView, for _: NestedSectionController) {
        debugPrint(type(of: self), section, #function)
    }

    func nestedAdapter(_: NestedAdapter, didEndDisplaying _: UIView, for _: NestedSectionController) {
        debugPrint(type(of: self), section, #function)
    }

    func nestedAdapter(_: NestedAdapter, willDisplayHeaderView _: UIView, for _: NestedSectionController) {
        debugPrint(type(of: self), section, #function)
    }

    func nestedAdapter(_: NestedAdapter, didEndDisplayingHeaderView _: UIView, for _: NestedSectionController) {
        debugPrint(type(of: self), section, #function)
    }

    func nestedAdapter(_: NestedAdapter, willDisplayFooterView _: UIView, for _: NestedSectionController) {
        debugPrint(type(of: self), section, #function)
    }

    func nestedAdapter(_: NestedAdapter, didEndDisplayingFooterView _: UIView, for _: NestedSectionController) {
        debugPrint(type(of: self), section, #function)
    }
}
