//
//  LocalIPAUploadUtil.swift
//  appdb
//
//  Created by ned on 04/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Alamofire

/*
 *   TL;DR A class that wraps a AF.UploadRequest, used to subscribe to progress notifications
 *
 *   It provides:
 *      - onPause() callback, called when upload request has been paused via pause() func
 *      - onProgress(Float, String) callback, called on upload progress, passes fraction completed (for UIProgressView)
 *          and a localized string
 *      - onCompletion() callback, called when progress finishes (with or without error)
 */

class LocalIPAUploadUtil {

    private var request: Alamofire.UploadRequest?

    var isPaused: Bool {
        paused
    }

    var lastCachedFraction: Float = 0.0
    var lastCachedProgress: String = "Waiting...".localized()

    private var paused: Bool = false

    var onPause: (() -> Void)?
    var onProgress: ((Float, String) -> Void)?
    var onCompletion: (() -> Void)?

    init(_ request: Alamofire.UploadRequest) {
        self.request = request

        self.request?.uploadProgress { progress in
            let readString: String = Global.humanReadableSize(bytes: progress.completedUnitCount)
            let totalString: String = Global.humanReadableSize(bytes: progress.totalUnitCount)
            let percentage = String(Int(progress.fractionCompleted * 100)) + "%"
            self.lastCachedProgress = "Uploading %@ of %@ (%@)".localizedFormat(readString, totalString, percentage)
            self.lastCachedFraction = Float(progress.fractionCompleted)
            self.onProgress?(self.lastCachedFraction, self.lastCachedProgress)
        }

        self.request?.responseJSON { _ in
            self.request = nil
            self.onCompletion?()
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
