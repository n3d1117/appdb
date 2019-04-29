//
//  IPAFileManager.swift
//  appdb
//
//  Created by ned on 28/04/2019.
//  Copyright © 2019 ned. All rights reserved.
//

import Foundation

struct LocalIPAFile: Equatable, Hashable {
    var filename: String = ""
}

struct IPAFileManager {
    
    static var shared = IPAFileManager()
    private init() { }
    
    func documentsDirectoryURL() -> URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    func inboxDirectoryURL() -> URL {
        return documentsDirectoryURL().appendingPathComponent("Inbox")
    }
    
    func moveEventualIPAFilesToDocumentsDirectory(from directory: URL) {
        guard FileManager.default.fileExists(atPath: directory.path) else { return }
        let inboxContents = try! FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
        let ipas = inboxContents.filter{ $0.pathExtension == "ipa" }
        for ipa in ipas {
            let startURL = directory.appendingPathComponent(ipa.lastPathComponent)
            var endURL = documentsDirectoryURL().appendingPathComponent(ipa.lastPathComponent)
            
            if !FileManager.default.fileExists(atPath: endURL.path) {
                try! FileManager.default.moveItem(at: startURL, to: endURL)
            } else {
                var i: Int = 0
                while FileManager.default.fileExists(atPath: endURL.path) {
                    i += 1
                    let newName = ipa.deletingPathExtension().lastPathComponent + "_\(i).ipa"
                    endURL = documentsDirectoryURL().appendingPathComponent(newName)
                }
                try! FileManager.default.moveItem(at: startURL, to: endURL)
            }
        }
    }
    
    func url(for ipa: LocalIPAFile) -> URL {
        return documentsDirectoryURL().appendingPathComponent(ipa.filename)
    }
    
    func rename(file: LocalIPAFile, to: String) {
        // todo handle error
        guard FileManager.default.fileExists(atPath: documentsDirectoryURL().appendingPathComponent(file.filename).path) else { return }
        let startURL = documentsDirectoryURL().appendingPathComponent(file.filename)
        let endURL = documentsDirectoryURL().appendingPathComponent(to)
        try! FileManager.default.moveItem(at: startURL, to: endURL)
    }
    
    func delete(file: LocalIPAFile) {
        // todo handle error
        guard FileManager.default.isDeletableFile(atPath: documentsDirectoryURL().appendingPathComponent(file.filename).path) else { return }
        try! FileManager.default.removeItem(at: documentsDirectoryURL().appendingPathComponent(file.filename))
    }
    
    func listLocalIpas() -> [LocalIPAFile] {
        var result = [LocalIPAFile]()

        moveEventualIPAFilesToDocumentsDirectory(from: inboxDirectoryURL())
        
        let contents = try! FileManager.default.contentsOfDirectory(at: documentsDirectoryURL(), includingPropertiesForKeys: nil)
        let ipas = contents.filter{ $0.pathExtension == "ipa" }
        for ipa in ipas {
            let ipa = LocalIPAFile(filename: ipa.lastPathComponent)
            if !result.contains(ipa) { result.append(ipa) }
        }
        result = result.sorted{ $0.filename.localizedStandardCompare($1.filename) == .orderedAscending }
        return result
    }
    
}
