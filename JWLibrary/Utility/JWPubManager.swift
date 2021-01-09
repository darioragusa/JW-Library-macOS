//
//  JWPubManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 01/01/21.
//

import Foundation

class JWPubManager {
    static func extractPubb(url: URL) {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sourceURL = documentsUrl.appendingPathComponent(url.lastPathComponent)
        let destinationURL = URL(string: sourceURL.absoluteString.replacingOccurrences(of: ".jwpub", with: ""))!
        print(sourceURL)
        print(destinationURL)
        do {
            try FileManager().createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager().unzipItem(at: sourceURL, to: destinationURL)
            let contentsFileURL = URL(string: destinationURL.absoluteString + "/contentsFile")!
            let contentsFolderURL = URL(string: destinationURL.absoluteString + "/contents")!
            print(contentsFileURL)
            print(contentsFolderURL)
            deleteFile(filePath: sourceURL)
            do {
                try FileManager().moveItem(at: contentsFolderURL, to: contentsFileURL)
                try FileManager().createDirectory(at: contentsFolderURL, withIntermediateDirectories: true, attributes: nil)
                try FileManager().unzipItem(at: contentsFileURL, to: contentsFolderURL)
                deleteFile(filePath: contentsFileURL)
            }
        } catch {
            print("Extraction of ZIP archive failed with error:\(error)")
        }
    }

    static func deleteFile(filePath: URL) {
        do {
            try FileManager.default.removeItem(at: filePath)
            print("File deleted")
        } catch {
            print("Error")
        }
    }
}
