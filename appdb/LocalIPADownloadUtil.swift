//
//  LocalIPADownloadUtil.swift
//  appdb
//
//  Created by ned on 09/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Alamofire

class LocalIPADownloadUtil {
    
    fileprivate var request: Alamofire.DownloadRequest?
    
    var isPaused: Bool {
        return paused
    }
    
    var lastCachedFraction: Float = 0.0
    var lastCachedProgress: String = "Waiting...".localized()
    
    fileprivate var paused: Bool = false
    
    var onPause: (() -> ())?
    var onProgress: ((Float, String) -> ())?
    var onCompletion: ((_ error: String?) -> ())?
    
    init(_ request: Alamofire.DownloadRequest) {
        self.request = request
        
        self.request?.downloadProgress { p in
            let readString = Global.humanReadableSize(bytes: p.completedUnitCount)
            let totalString = Global.humanReadableSize(bytes: p.totalUnitCount)
            let percentage = Int(p.fractionCompleted * 100)
            if p.totalUnitCount == -1 { // Google Drive
                self.lastCachedProgress = "Downloading %@".localizedFormat(readString)
            } else {
                self.lastCachedProgress = "Downloading %@ of %@ (%@%)".localizedFormat(readString, totalString, percentage)
            }
            self.lastCachedFraction = Float(p.fractionCompleted)
            self.onProgress?(self.lastCachedFraction, self.lastCachedProgress)
        }
        
        self.request?.response { r in
            self.request = nil
            self.onCompletion?(r.error?.localizedDescription)
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

