//
//  Downloading.swift
//  appdb
//
//  Created by ned on 22/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import UIKit

class Downloading: LoadingCollectionView {

    private var downloadingApps = [DownloadingApp]()

    convenience init() {
        self.init(collectionViewLayout: UICollectionViewFlowLayout())
    }

    override func viewDidLoad() {
        self.hasSegment = true
        super.viewDidLoad()

        // Collection View
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = layout
        collectionView.contentInset.bottom = 25 ~~ 15
        collectionView.delaysContentTouches = false

        // UI
        view.theme_backgroundColor = Color.tableViewBackgroundColor
        collectionView.theme_backgroundColor = Color.tableViewBackgroundColor
        collectionView.register(DownloadingCell.self, forCellWithReuseIdentifier: "downloading")

        let apps = ObserveDownloadingApps.shared.apps
        if !apps.isEmpty {
            downloadingApps = apps
            if !self.isDone { self.state = .done(animated: false) }
            self.collectionView.reloadData()
        } else {
            setErrorMessageIfEmpty()
        }

        ObserveDownloadingApps.shared.onAdded = { [weak self] app in
            guard let self = self else { return }
            self.downloadingApps.insert(app, at: 0)
            if !self.isDone { self.state = .done(animated: false) }
            self.collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])
        }

        ObserveDownloadingApps.shared.onRemoved = { [weak self] app in
            guard let self = self else { return }
            if let index = self.downloadingApps.firstIndex(of: app) {
                self.downloadingApps[index].util = nil
                //self.downloadingApps.remove(at: index)
                //self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                //if self.downloadingApps.isEmpty {
                    //self.setErrorMessageIfEmpty()
                //}
            }
        }
    }

    private func setErrorMessageIfEmpty() {
        let noQueuesMessage = "No active downloads".localized()
        if case LoadingCollectionView.State.error(noQueuesMessage, _, _) = state {} else {
            state = .error(first: noQueuesMessage, second: "", animated: false)
        }
    }

    // MARK: - Orientation change

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            if !self.isLoading {
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.collectionViewLayout = self.layout
            }
        })
    }

    // MARK: - Collection view delegate

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (isLoading || hasError) ? 0 : downloadingApps.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard !isLoading else { return UICollectionViewCell() }
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "downloading", for: indexPath) as? DownloadingCell else { return UICollectionViewCell() }
        cell.configureForDownload(with: downloadingApps[indexPath.row])
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard downloadingApps.indices.contains(indexPath.row) else { return }
        presentOptions(downloadingApps[indexPath.row], indexPath)
    }

    // MARK: - Present options to pause, resume, stop or remove when finished

    private func presentOptions(_ app: DownloadingApp, _ indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet, adaptive: true)

        if let util = app.util {
            if !util.isPaused {
                alertController.addAction(UIAlertAction(title: "Pause".localized(), style: .default) { _ in
                    util.pause()
                })
            } else {
                alertController.addAction(UIAlertAction(title: "Resume".localized(), style: .default) { _ in
                    util.resume()
                })
            }
            alertController.addAction(UIAlertAction(title: "Stop".localized(), style: .destructive) { _ in
                util.stop()
            })
        } else {
            alertController.addAction(UIAlertAction(title: "Remove from list".localized(), style: .destructive) { _ in
                self.downloadingApps.remove(at: indexPath.row)
                self.collectionView.deleteItems(at: [IndexPath(row: indexPath.row, section: 0)])
                if self.downloadingApps.isEmpty {
                    self.setErrorMessageIfEmpty()
                }
            })
        }

        alertController.addAction(UIAlertAction(title: "Cancel".localized(), style: .cancel))

        if let presenter = alertController.popoverPresentationController, let attributes = collectionView.layoutAttributesForItem(at: indexPath) {
            presenter.theme_backgroundColor = Color.popoverArrowColor
            presenter.sourceView = self.view
            presenter.sourceRect = collectionView.convert(attributes.frame, to: collectionView.superview)
            presenter.permittedArrowDirections = [.up, .down]
        }

        DispatchQueue.main.async {
            self.present(alertController, animated: true)
        }
    }
}

// MARK: - iOS 13 Context Menus

@available(iOS 13.0, *)
extension Downloading {

    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard downloadingApps.indices.contains(indexPath.row) else { return nil }
        let app = downloadingApps[indexPath.row]

        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in

            if let util = app.util {
                var playPauseAction: UIAction!

                if !util.isPaused {
                    playPauseAction = UIAction(title: "Pause".localized(), image: UIImage(systemName: "pause.circle")) { _ in
                        util.pause()
                    }
                } else {
                    playPauseAction = UIAction(title: "Resume".localized(), image: UIImage(systemName: "play.circle")) { _ in
                        util.resume()
                    }
                }
                let stop = UIAction(title: "Stop".localized(), image: UIImage(systemName: "stop.circle"), attributes: .destructive) { _ in
                    util.stop()
                }
                return UIMenu(title: "", children: [playPauseAction, stop])
            } else {
                let remove = UIAction(title: "Remove from list".localized(), image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                    self.downloadingApps.remove(at: indexPath.row)
                    self.collectionView.deleteItems(at: [IndexPath(row: indexPath.row, section: 0)])
                    if self.downloadingApps.isEmpty {
                        self.setErrorMessageIfEmpty()
                    }
                }
                return UIMenu(title: "", children: [remove])
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath else { return nil }
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear

        if let collectionViewCell = collectionView.cellForItem(at: indexPath) {
            return UITargetedPreview(view: collectionViewCell.contentView, parameters: parameters)
        }
        return nil
    }
}
// MARK: - ETCollectionViewDelegateWaterfallLayout

extension Downloading: ETCollectionViewDelegateWaterfallLayout {
    var margin: CGFloat {
        return UIApplication.shared.statusBarOrientation.isLandscape && Global.hasNotch ? 60 : (20 ~~ 15)
    }

    var topInset: CGFloat {
        return Global.isIpad ? 25 : 15
    }

    var layout: ETCollectionViewWaterfallLayout {
        let layout = ETCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 20 ~~ 15
        layout.minimumInteritemSpacing = 15 ~~ 10
        layout.sectionInset = UIEdgeInsets(top: topInset, left: margin, bottom: topInset, right: margin)
        layout.columnCount = UIApplication.shared.statusBarOrientation.isPortrait ? 1 : 2
        return layout
    }

    var itemDimension: CGFloat {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            return view.bounds.width - margin * 2
        } else {
            return (view.bounds.width / 2) - margin * 1.5
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: itemDimension, height: (50 ~~ 40) + (15 ~~ 12) * 2)
    }
}
