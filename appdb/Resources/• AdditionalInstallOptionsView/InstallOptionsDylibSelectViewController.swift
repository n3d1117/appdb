//
//  InstallOptionsDylibSelectViewController.swift
//  appdb
//
//  Created by stev3fvcks on 19.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit
import Cartography
import Static

class InstallOptionsDylibSelectNavController: UINavigationController, AdditionalInstallOptionsHeightDelegate {
    
    var group = ConstraintGroup()

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        setupConstraints()
    }

    // Setup constraints
    private func setupConstraints() {
        if let vc = self.viewControllers.first as? InstallOptionsDylibSelectViewController {
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

    func updateHeight() {
        setupConstraints()
        if let sv = view.superview {
            UIView.animate(withDuration: 0.2, animations: sv.layoutIfNeeded)
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class InstallOptionsDylibSelectViewController: TableViewController {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(dylibOptions: [String], selectedDylibs: [String]) {
        super.init(style: .plain)
        
        self.dylibOptions = dylibOptions
        self.selectedDylibs = selectedDylibs
    }
    
    var dylibOptions: [String] = []

    weak var heightDelegate: AdditionalInstallOptionsHeightDelegate?
    var dylibSelectDelegate: InstallOptionsDylibSelectDelegate?
    
    private var selectedDylibs: [String] = []

    private let rowHeight: CGFloat = 50
    var height: CGFloat {
        let navbarHeight: CGFloat = navigationController?.navigationBar.frame.height ?? 44
        return navbarHeight + rowHeight * CGFloat(sections.first!.rows.count)
    }
    
    /**
     ["callback": { [unowned self] (newDylibs: [String]) in
         self.selectedDylibs = newDylibs.isEmpty ? [] : newDylibs
     }]
     */

    lazy var sections: [Static.Section] = {
        return loadSections()
    }()
    
    func loadSections() -> [Static.Section] {
        var currentIndex = 0
        let rows = dylibOptions.map { dylibOption -> Row in
            let selected = selectedDylibs.contains(dylibOption)
            currentIndex += 1
            return Row(text: dylibOption, selection: { row in
                if selected {
                    self.selectedDylibs.removeAll { option in
                        return option == dylibOption
                    }
                } else {
                    self.selectedDylibs.append(dylibOption)
                }
                self.sections = self.loadSections()
                self.dataSource.sections = self.sections
                self.tableView.reloadRows(at: [IndexPath(row: currentIndex - 1, section: 0)], with: .none)
            }, accessory: (selected ? .checkmark : .checkmarkPlaceholder), cellClass: SimpleStaticCell.self)
        }
        
        return [
            Section(rows: rows)
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Select Dylibs, Frameworks or Debs".localized()

        tableView.theme_separatorColor = Color.borderColor
        tableView.theme_backgroundColor = Color.veryVeryLightGray
        view.theme_backgroundColor = Color.veryVeryLightGray

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }

        tableView.rowHeight = rowHeight
        tableView.isScrollEnabled = false

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(dismissAnimated))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.submitSelection))
        navigationItem.rightBarButtonItem?.isEnabled = true

        //newId = placeholder
        dataSource.sections = sections
    }

    @objc private func dismissAnimated() {
        dismiss(animated: true)
    }

    @objc private func submitSelection() {
        dylibSelectDelegate?.selectedDylibs(dylibs: selectedDylibs)
        dismiss(animated: true)
    }
}

