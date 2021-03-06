//
//  Categories.swift
//  appdb
//
//  Created by ned on 23/10/2016.
//  Copyright © 2016 ned. All rights reserved.
//

import UIKit
import Cartography
import AlamofireImage

private var categories: [Genre] = []
private var checked: [Int: [Bool]] = [0: [true], 1: [true], 2: [true]]
private var selected: Int = 0
private var savedScrollPosition: CGFloat = 0.0

class Categories: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var tableView: UITableView!
    var headerView: ILTranslucentView!
    var control: UISegmentedControl!
    var line: UIView!

    weak var delegate: ChangeCategory?

    // Constraints group, will be replaced when orientation changes
    var group = ConstraintGroup()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let tableView = tableView { tableView.setContentOffset(CGPoint(x: 0, y: savedScrollPosition), animated: false) }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        savedScrollPosition = tableView.contentOffset.y
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide bottom hairline
        if let nav = navigationController { nav.navigationBar.hideBottomHairline() }

        // Init and add subviews
        if !Global.isIpad, #available(iOS 13.0, *) {
            tableView = UITableView(frame: view.frame, style: .insetGrouped)
            tableView.automaticallyAdjustsScrollIndicatorInsets = false
            tableView.contentInset.top = -20 // sigh, Apple...
        } else {
            tableView = UITableView(frame: view.frame, style: .plain)
        }
        tableView.delegate = self
        tableView.dataSource = self

        // Fix random separator margin issues
        tableView.cellLayoutMarginsFollowReadableWidth = false

        tableView.theme_separatorColor = Color.borderColor

        headerView = ILTranslucentView(frame: .zero)
        headerView.translucentAlpha = 1

        control = UISegmentedControl(items: ["iOS".localized(), "Cydia".localized(), "Books".localized()])
        control.addTarget(self, action: #selector(self.indexDidChange), for: .valueChanged)
        control.selectedSegmentIndex = selected
        reloadAfterIndexChange(index: selected)

        line = UIView(frame: .zero)
        line.backgroundColor = tableView.separatorColor

        headerView.addSubview(line)
        headerView.addSubview(control)
        view.addSubview(headerView)
        view.addSubview(tableView)

        // Set constraints
        setConstraints()

        // Set up
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "category_ios")
        tableView.register(CategoryCell.self, forCellReuseIdentifier: "category_books")
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        title = "Select Category".localized()

        // Hide last separator
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))

        // Add cancel button
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel".localized(), style: .plain, target: self, action: #selector(self.dismissAnimated))
    }

    // MARK: - Index changed

    @objc func indexDidChange(sender: UISegmentedControl) {
        selected = sender.selectedSegmentIndex
        reloadAfterIndexChange(index: selected)
    }

    func reloadAfterIndexChange(index: Int) {
        switch index {
        case 0: // iOS
            tableView.rowHeight = 50
            categories = Preferences.genres.filter({ $0.category == "ios" }).sorted { $0.name.lowercased() < $1.name.lowercased() }
            putCategoriesAtTheTop(compound: "0-ios")
        case 1: // Cydia
            tableView.rowHeight = 50
            categories = Preferences.genres.filter({ $0.category == "cydia" }).sorted { $0.name.lowercased() < $1.name.lowercased() }
            putCategoriesAtTheTop(compound: "0-cydia")
        case 2: // Books
            tableView.rowHeight = 60
            categories = Preferences.genres.filter({ $0.category == "books" }).sorted { $0.name.lowercased() < $1.name.lowercased() }
            putCategoriesAtTheTop(compound: "0-books")

        default: break
        }

        for _ in categories { checked[selected]!.append(false) }
        tableView.reloadData()
    }

    func putCategoriesAtTheTop(compound: String) {
        if categories.first?.compound != compound, let top = categories.first(where: {$0.compound == compound}) {
            if let index = categories.firstIndex(of: top) {
                categories.remove(at: index)
                categories.insert(top, at: 0)
            }
        }
    }

    // MARK: - Constraints

    private func setConstraints() {
        constrain(tableView, headerView, control, line, replace: group) { tableView, header, control, line in

            header.top ~== header.superview!.topMargin
            header.leading ~== header.superview!.leading
            header.trailing ~== header.superview!.trailing
            header.height ~== 40

            line.height ~== (1 / UIScreen.main.scale)
            line.leading ~== header.leading
            line.trailing ~== header.trailing
            line.top ~== header.bottom ~- 0.5

            control.top ~== header.top
            control.centerX ~== header.centerX
            control.width ~== 280

            tableView.top ~== header.bottom
            tableView.bottom ~== tableView.superview!.bottom
            tableView.trailing ~== tableView.superview!.trailing
            tableView.leading ~== tableView.superview!.leading
        }
    }

    // Update constraints to reflect orientation change (recalculate navigationBar + statusBar height)
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { (_: UIViewControllerTransitionCoordinatorContext!) -> Void in
            guard self.tableView != nil else { return }
            self.setConstraints()
        }, completion: nil)
    }

    // MARK: - Dismiss animated

    @objc func dismissAnimated() { dismiss(animated: true) }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let isBookCell = control.selectedSegmentIndex == 2
        let placeholder = isBookCell ? #imageLiteral(resourceName: "placeholderCover") : #imageLiteral(resourceName: "placeholderIcon")
        let reusableId = isBookCell ? "category_books" : "category_ios"

        guard let cell = tableView.dequeueReusableCell(withIdentifier: reusableId, for: indexPath) as? CategoryCell else { return UITableViewCell() }

        cell.name.text = categories[indexPath.row].name
        cell.amount.text = categories[indexPath.row].amount

        if let url = URL(string: categories[indexPath.row].icon) {
            cell.icon.af.setImage(withURL: url, placeholderImage: placeholder, filter: isBookCell ? nil : Global.roundedFilter(from: 30), imageTransition: .crossDissolve(0.2))
        }

        cell.name.theme_textColor = checked[selected]![indexPath.row] ? Color.mainTint : Color.title
        cell.name.font = checked[selected]![indexPath.row] ? .boldSystemFont(ofSize: cell.name.font.pointSize) : .systemFont(ofSize: cell.name.font.pointSize)

        cell.amount.theme_textColor = checked[selected]![indexPath.row] ? Color.mainTint : Color.darkGray
        cell.amount.font = checked[selected]![indexPath.row] ? .boldSystemFont(ofSize: cell.amount.font.pointSize) : .systemFont(ofSize: cell.amount.font.pointSize)

        cell.accessoryType = checked[selected]![indexPath.row] ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        checked[selected]!.removeAll(keepingCapacity: true)
        for i in 0..<categories.count { checked[selected]!.append(i == indexPath.row) }
        tableView.reloadData()

        dismissAnimated()

        switch control.selectedSegmentIndex {
        case 0: delegate?.reloadViewAfterCategoryChange(id: categories[indexPath.row].id, type: .ios)
        case 1: delegate?.reloadViewAfterCategoryChange(id: categories[indexPath.row].id, type: .cydia)
        case 2: delegate?.reloadViewAfterCategoryChange(id: categories[indexPath.row].id, type: .books)
        default: break
        }
    }
}
