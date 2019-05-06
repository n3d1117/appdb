//
//  LocalIPAUploadUtil.swift
//  appdb
//
//  Created by ned on 04/05/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Alamofire

class LocalIPAUploadUtil {
    
    fileprivate var request: Alamofire.UploadRequest? = nil
    
    var isPaused: Bool {
        return paused
    }
    
    var lastCachedFraction: Float = 0.0
    var lastCachedProgress: String = ""
    
    fileprivate var paused: Bool = false
    
    var onProgress: ((Float, String) -> ())?
    var onCompletion: (() -> ())?
    
    init(_ request: Alamofire.UploadRequest) {
        self.request = request
        
        self.request?.uploadProgress { p in
            let readString = Global.humanReadableSize(bytes: p.completedUnitCount)
            let totalString = Global.humanReadableSize(bytes: p.totalUnitCount)
            let percentage = Int(p.fractionCompleted * 100)
            self.lastCachedProgress = "Uploading \(readString) of \(totalString) (\(percentage)%)" // todo localize
            self.lastCachedFraction = Float(p.fractionCompleted)
            self.onProgress?(self.lastCachedFraction, self.lastCachedProgress)
        }
        
        self.request?.responseJSON { _ in
            self.onCompletion?()
            self.request = nil
        }
    }
    
    func pause() -> Bool {
        guard let request = request else { return false }
        guard !paused else { return false }
        request.suspend()
        paused = true
        return true
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
