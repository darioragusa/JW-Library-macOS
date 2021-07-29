//
//  Ext_FileManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation

extension FileManager {
    func copyfileToUserDocumentDirectory(destPath: URL) throws {
        let fileFullName = destPath.lastPathComponent
        let fileName = String(fileFullName.split(separator: ".").first!)
        let fileExt = String(fileFullName.split(separator: ".").last!)
        if let bundlePath = Bundle.main.path(forResource: fileName, ofType: fileExt) {
            let fullDestPathString = destPath.path
            if !self.fileExists(atPath: fullDestPathString) {
                try self.copyItem(atPath: bundlePath, toPath: fullDestPathString)
            }
        }
    }

    static func articleExist(path: String) -> Bool { // nwt_I/66/22.html
        let destinationUrl = getDocumentsDirectory().appendingPathComponent(path)
        return FileManager().fileExists(atPath: destinationUrl.path)
    }

    static func fileExist(url: URL) -> Bool { // https://download-a.akamaihd.net/files/media_publication/c1/nwt_I.jwpub
        let destinationUrl = getDocumentsDirectory().appendingPathComponent(url.lastPathComponent)
        return FileManager().fileExists(atPath: destinationUrl.path.replacingOccurrences(of: ".jwpub", with: ""))
    }

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
        // file:///Users/darioragusa/Library/Containers/com.darioragusa.JWLibrary/Data/Documents/
    }
}
