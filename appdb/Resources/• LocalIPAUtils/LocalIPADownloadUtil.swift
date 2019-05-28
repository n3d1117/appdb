//
//  LocalIPADownloadUtil.swift
//  appdb
//
//  Created by ned on 09/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Alamofire

/*
 *   TL;DR A class that wraps a Alamofire.DownloadRequest, used to subscribe to progress notifications
 *
 *   It provides:
 *      - onPause() callback, called when upload request has been paused via pause() func
 *      - onProgress(Float, String) callback, called on upload progress, passes fraction completed (for UIProgressView)
 *          and a localized string
 *      - onCompletion(String?) callback, called when progress finishes, passes eventual localized error
 */

class LocalIPADownloadUtil {

    private var request: Alamofire.DownloadRequest?

    var isPaused: Bool {
        return paused
    }

    var lastCachedFraction: Float = 0.0
    var lastCachedProgress: String = "Waiting...".localized()

    private var paused: Bool = false

    var onPause: (() -> Void)?
    var onProgress: ((Float, String) -> Void)?
    var onCompletion: ((_ error: String?) -> Void)?

    init(_ request: Alamofire.DownloadRequest) {
        self.request = request

        self.request?.downloadProgress { progress in
            let readString: String = Global.humanReadableSize(bytes: progress.completedUnitCount)
            let totalString: String = Global.humanReadableSize(bytes: progress.totalUnitCount)
            let percentage = String(Int(progress.fractionCompleted * 100)) + "%"
            if progress.totalUnitCount == -1 { // Google Drive
                self.lastCachedProgress = "Downloading %@".localizedFormat(readString)
            } else {
                self.lastCachedProgress = "Downloading %@ of %@ (%@)".localizedFormat(readString, totalString, percentage)
            }
            self.lastCachedFraction = Float(progress.fractionCompleted)
            self.onProgress?(self.lastCachedFraction, self.lastCachedProgress)
        }

        self.request?.response { response in
            self.request = nil
            self.onCompletion?(response.error?.localizedDescription)
        }
    }

    func pause() {
        guard let request = request else { return }
        guard !paused else { return }
        request.suspend()
        paused = true
        onPause?()
    }

    func resume() {
        guard let request = request else { return }
        request.resume()
        paused = false
    }

    func stop() {
        guard let request = request else { return }
        request.cancel()
        paused = false
    }
}
