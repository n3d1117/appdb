//
//  AskBundleBeforeUploadViewController.swift
//  appdb
//
//  Created by ned on 26/06/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography
import Static

// A custom UINavigationController suited to wrap a AskBundleBeforeUploadViewController

class AskBundleBeforeUploadNavController: UINavigationController {

    var group = ConstraintGroup()

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        setupConstraints()
    }

    // Setup constraints
    private func setupConstraints() {
        if let vc = self.viewControllers.first as? AskBundleBeforeUploadViewController {
            constrain(view, replace: group) { view in
                view.height ~== vc.height
                view.width ~<= 500
            }
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            self.setupConstraints()
        }, completion: nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class AskBundleBeforeUploadViewController: TableViewController {

    var onCompletion: ((String, Bool) -> Void)?

    private var originalBundleId: String = ""

    private var newBundleId: String = ""
    private var overwriteFile: Bool = false

    var cancelled: Bool = true

    private let rowHeight: CGFloat = 50
    var height: CGFloat {
        let navbarHeight: CGFloat = navigationController?.navigationBar.frame.height ?? 0
        return navbarHeight + rowHeight * 2
    }

    var sections: [Static.Section] {
        [
            Section(rows: [
                Row(selection: { [unowned self] _ in
                    self.newBundleId = Global.randomString(length: 4) + "." + self.originalBundleId
                    self.refresh()
                }, cellClass: StaticSubtitleTextFieldCell.self, context:
                    ["initialText": self.newBundleId, "callback": { [unowned self] (newBundleId: String) in
                        self.newBundleId = newBundleId
                        self.setUploadButtonEnabled()
                    }, "title": "New bundle id".localized(), "subtitle": "Tap to generate random".localized()]
                ),
                Row(text: "Overwrite file".localized(), accessory: .switchToggle(value: overwriteFile) { [unowned self] newValue in
                    self.overwriteFile = newValue
                }, cellClass: SimpleStaticCell.self)
            ])
        ]
    }

    convenience init(originalBundleId: String) {
        self.init()
        self.originalBundleId = originalBundleId
        self.newBundleId = originalBundleId
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Bundle ID Change".localized()

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.veryVeryLightGray
        view.theme_backgroundColor = Color.veryVeryLightGray

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        tableView.rowHeight = rowHeight
        tableView.isScrollEnabled = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(dismissAnimated))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Change".localized(), style: .done, target: self, action: #selector(proceedWithChange))
        navigationItem.rightBarButtonItem?.isEnabled = true

        refresh()
    }

    private func refresh() {
        dataSource.sections = sections
    }

    @objc private func dismissAnimated() {
        cancelled = true
        dismiss(animated: true)
    }

    @objc private func proceedWithChange() {
        onCompletion?(self.newBundleId, self.overwriteFile)
        cancelled = false
        dismiss(animated: true)
    }

    private func setUploadButtonEnabled() {
        navigationItem.rightBarButtonItem?.isEnabled = !newBundleId.isEmpty && !newBundleId.contains(" ")
    }
}
