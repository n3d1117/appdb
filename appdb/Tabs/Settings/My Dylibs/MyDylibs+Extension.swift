//
//  MyDylibs+Extension.swift
//  appdb
//
//  Created by stev3fvcks on 19.03.23.
//  Copyright © 2023 stev3fvcks. All rights reserved.
//

import UIKit
import UniformTypeIdentifiers

extension MyDylibs {

    convenience init() {
        if #available(iOS 13.0, *) {
            self.init(style: .insetGrouped)
        } else {
            self.init(style: .grouped)
        }
    }

    func setUp() {

        tableView.tableFooterView = UIView()
        tableView.theme_backgroundColor = Color.tableViewBackgroundColor
        tableView.theme_separatorColor = Color.borderColor

        tableView.cellLayoutMarginsFollowReadableWidth = true

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 45

        if #available(iOS 13.0, *) { } else {
            // Hide the 'Back' text on back button
            let backItem = UIBarButtonItem(title: "", style: .done, target: nil, action: nil)
            navigationItem.backBarButtonItem = backItem
        }
        
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addDylibClicked))
        navigationItem.rightBarButtonItem = addItem

        state = .loading
        animated = true
    }
    
    
    // Only enable button if text is not empty
    /*@objc func repoUrlTextfieldTextChanged(sender: UITextField) {
        var responder: UIResponder = sender
        while !(responder is UIAlertController) { responder = responder.next! }
        if let alert = responder as? UIAlertController {
            (alert.actions[1] as UIAlertAction).isEnabled = !(sender.text ?? "").isEmpty
        }
    }*/
    
    @objc func addDylibClicked() {
        self.addDylibFromUrl()
        /*
        let alertController = UIAlertController(title: "How do you want to add the dylib?".localized(), message: nil, preferredStyle: .actionSheet, adaptive: true)
        
        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Upload file".localized(), style: .default, handler: { _ in
            self.addDylibFromFile()
        }))
        
        alertController.addAction(UIAlertAction(title: "From URL".localized(), style: .default, handler: { _ in
            self.addDylibFromUrl()
        }))
        
        present(alertController, animated: true)*/
    }
    
    /*
    func addDylibFromFile() {
        var docPicker: UIDocumentPickerViewController?
        
        if #available(iOS 14.0, *) {
            docPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.data])
        } else {
            docPicker = UIDocumentPickerViewController(documentTypes: ["dylib", "framework.zip", "deb"], in: .open)
        }
        
        docPicker!.delegate = self
        docPicker!.allowsMultipleSelection = false
        if #available(iOS 13.0, *) {
            docPicker!.shouldShowFileExtensions = true
        }
        self.present(docPicker!, animated: true, completion: nil)
    }*/
    
    func addDylibFromUrl() {
        let alertController = UIAlertController(title: "Please enter URL to .dylib/.deb/.framework.zip".localized(), message: nil, preferredStyle: .alert, adaptive: true)
        alertController.addTextField { textField in
            textField.placeholder = "Dylib URL".localized()
            textField.theme_keyboardAppearance = [.light, .dark, .dark]
            textField.keyboardType = .URL
            //textField.addTarget(self, action: #selector(self.repoUrlTextfieldTextChanged(sender:)), for: .editingChanged)
            textField.clearButtonMode = .whileEditing
        }
        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))
        
        let addAction = UIAlertAction(title: "Add .dylib/.deb/.framework.zip".localized(), style: .default, handler: { _ in
            guard let text = alertController.textFields?[0].text else { return }
            API.addDylib(url: text) {
                Messages.shared.showSuccess(message: "Dylib was added successfully".localized(), context: .viewController(self))
                self.loadDylibs()
            } fail: { error in
                Messages.shared.showError(message: "An error occurred while adding the new dylib".localized(), context: .viewController(self))
            }
        })
        alertController.addAction(addAction)
        //addAction.isEnabled = false
        
        present(alertController, animated: true)
    }
}

/*
extension MyDylibs: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if let dylibFile = urls.first {
            
            var hasValidSuffix = false
            
            for validSuffix in ["dylib", "framework.zip", "deb"] {
                if dylibFile.path.hasSuffix(validSuffix) {
                    hasValidSuffix = true
                }
            }
            
            if hasValidSuffix {
                API.uploadDylib(fileURL: dylibFile) { r in
                    
                } completion: { error in
                    if error == nil {
                        Messages.shared.showSuccess(message: "The dylib has been uploaded successfully".localized())
                        self.loadDylibs()
                    } else {
                        Messages.shared.showError(message: error!)
                    }
                }
            } else {
                Messages.shared.showError(message: "Invalid file type. Only .dylib, .framework.zip, and .deb files are allowed")
            }
        }
    }
}
*/
