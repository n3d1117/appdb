//
//  AdditionalInstallOptionsViewController.swift
//  appdb
//
//  Created by ned on 13/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit
import Cartography
import Static

protocol AdditionalInstallOptionsHeightDelegate: AnyObject {
    func updateHeight()
}

protocol InstallOptionsDylibSelectDelegate {
    func selectedDylibs(dylibs: [String])
}

// A custom UINavigationController suited to wrap a AdditionalInstallOptionsViewController with variable height

class AdditionalInstallOptionsNavController: UINavigationController, AdditionalInstallOptionsHeightDelegate {

    var group = ConstraintGroup()

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        setupConstraints()
    }

    // Setup constraints
    private func setupConstraints() {
        if let vc = self.viewControllers.first as? AdditionalInstallOptionsViewController {
            constrain(view, replace: group) { view in
                view.height ~== vc.getHeight()
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

class AdditionalInstallOptionsViewController: TableViewController {
    
    var installationOptions: [InstallationOption] = []

    weak var heightDelegate: AdditionalInstallOptionsHeightDelegate?

    var onCompletion: ((_ patchIap: Bool, _ enableGameTrainer: Bool, _ removePlugins: Bool, _ enablePushNotifications: Bool,
                        _ duplicateApp: Bool, _ newId: String, _ newName: String, _ selectedDylibs: [String]) -> Void)?

    private var newId: String = ""
    private var newName: String = ""
    private var selectedDylibs: [String] = []

    var cancelled = true

    private let placeholder: String = Global.randomString(length: 5).lowercased()

    private let rowHeight: CGFloat = 50
    func getHeight() -> CGFloat {
        let navbarHeight: CGFloat = navigationController?.navigationBar.frame.height ?? 44
        if sections.isEmpty || sections.first == nil {
            return 44 + rowHeight
        }
        return navbarHeight + rowHeight * CGFloat(sections.first!.rows.count)
    }
    
    var sections: [Static.Section] = [
        Section(header: .title("Loading...".localized()), rows: [
            Row(text: "Loading...")
        ], footer: .none, indexTitle: "", uuid: "loading")
    ]
    
     func loadSections() -> [Static.Section] {
        
        if installationOptions.isEmpty {
            return [
                Section(header: .title("Loading...".localized()), rows: [
                    Row(text: "Loading...")
                ], footer: .none, indexTitle: "", uuid: "loading")
            ]
        }
         
         navigationItem.rightBarButtonItem?.isEnabled = true
         
        var rows: [Static.Row] = []
                
        for installationOption in installationOptions {
            switch installationOption.identifier {
            case .name:
                rows.append(Row(text: "New display name".localized(), cellClass: StaticTextFieldCell.self, context:
                                    ["placeholder": "Use Original".localized(), "callback": { [unowned self] (newName: String) in
                                        self.newName = newName
                                        self.setInstallButtonEnabled()
                                    }]
                                ))
                break
            case .alongside:
                rows.append(Row(text: "Duplicate app".localized(), cellClass: SwitchCell.self, context: ["valueChange": { (new: Bool) in
                    Preferences.set(.duplicateApp, to: new)
                    self.setInstallButtonEnabled()
                    self.reloadTable()
                }, "value": Preferences.duplicateApp]))
                if Preferences.duplicateApp {
                    rows.append(Row(text: "New ID".localized(), cellClass: StaticTextFieldCell.self, context:
                                        ["placeholder": installationOption.placeholder /*placeholder*/, "callback": { [unowned self] (newId: String) in
                                            self.newId = newId.isEmpty ? /*installationOption.placeholder*/ self.placeholder : newId
                                            self.setInstallButtonEnabled()
                                        }, "forceLowercase": true, "characterLimit": 5]
                                    ))
                }
                break
            case .inapp:
                /* "Patch in-app Purchases".localized() */
                rows.append(Row(text: installationOption.question, cellClass: SwitchCell.self, context: ["valueChange": { new in
                    Preferences.set(.enableIapPatch, to: new)
                }, "value": Preferences.enableIapPatch]))
                break
            case .trainer:
                /* "Enable Game Trainer".localized() */
                rows.append(Row(text: installationOption.question, cellClass: SwitchCell.self, context: ["valueChange": { new in
                    Preferences.set(.enableTrainer, to: new)
                }, "value": Preferences.enableTrainer]))
                break
            case .removePlugins:
                /* "Remove Plugins".localized() */
                rows.append(Row(text: installationOption.question, cellClass: SwitchCell.self, context: ["valueChange": { new in
                    Preferences.set(.removePlugins, to: new)
                }, "value": Preferences.removePlugins]))
                break
            case .push:
                /* "Enable Push Notifications".localized() */
                rows.append(Row(text: installationOption.question, cellClass: SwitchCell.self, context: ["valueChange": { new in
                    Preferences.set(.enablePushNotifications, to: new)
                }, "value": Preferences.enablePushNotifications]))
                break
            case .injectDylibs:
                /*"Inject dylibs, frameworks or debs?".localized()*/
                rows.append(Row(text: installationOption.question, selection: { row in
                    self.askForDylibSelection(dylibOptions: installationOption.chooseFrom)
                }, cellClass: SimpleStaticDylibsSelectionCell.self, context: ["selectedDylibs": selectedDylibs]))
                break
            }
        }

        return [
            Section(rows: rows)
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Installation options".localized()

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Install".localized(), style: .done, target: self, action: #selector(proceedWithInstall))
        navigationItem.rightBarButtonItem?.isEnabled = false

        //newId = placeholder
        dataSource.sections = sections
        
        loadInstallationOptions()
    }

    @objc private func dismissAnimated() {
        cancelled = true
        dismiss(animated: true)
    }

    @objc private func proceedWithInstall() {
        onCompletion?(Preferences.enableIapPatch, Preferences.enableTrainer, Preferences.removePlugins, Preferences.enablePushNotifications, Preferences.duplicateApp, self.newId.lowercased(), self.newName, self.selectedDylibs)
        cancelled = false
        dismiss(animated: true)
    }

    private func setInstallButtonEnabled() {
        navigationItem.rightBarButtonItem?.isEnabled = !Preferences.duplicateApp || newId.count == 5 && !newId.contains(" ")
    }
    
    private func askForDylibSelection(dylibOptions: [String]) {
        
        let vc = InstallOptionsDylibSelectViewController(dylibOptions: dylibOptions, selectedDylibs: selectedDylibs)
        let nav = InstallOptionsDylibSelectNavController(rootViewController: vc)

        vc.heightDelegate = nav
        vc.dylibSelectDelegate = self
        
        let segue = Messages.shared.generateModalSegue(vc: nav, source: self, trackKeyboard: true)

        delay(0.3) {
            segue.perform()
        }
    }
    
    private func loadInstallationOptions() {
        API.getInstallationOptions { _installationOptions in
            self.installationOptions = _installationOptions
            self.reloadTable()
        } fail: { error in
            Messages.shared.showError(message: error.localizedDescription)
        }
    }
    
    func reloadTable() {
        sections = loadSections()
        dataSource.sections = sections
        tableView.reloadSections(IndexSet(integer: 0), with: .none)
        heightDelegate?.updateHeight()
    }
}

extension AdditionalInstallOptionsViewController: InstallOptionsDylibSelectDelegate {
    func selectedDylibs(dylibs: [String]) {
        selectedDylibs = dylibs
        self.reloadTable()
    }
}
