//
//  JWPubManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 01/01/21.
//

import Foundation
import SQLite3
import AppKit

class JWPubManager {
    static func extractPub(url: URL) {
        let sourceURL = FileManager.getDocumentsDirectory().appendingPathComponent(url.lastPathComponent)
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
            print("Extraction of ZIP archive failed with error: \(error) ⚠️")
        }
    }

    static func deleteFile(filePath: URL) {
        do {
            try FileManager.default.removeItem(at: filePath)
            print("File deleted ✅")
        } catch {
            print("Error ⚠️")
        }
    }

    static func downloadDocuments(pub: Publication) {
        let pubName = "\(pub.keySymbol)_I\(pub.issueTagNumber != 0 ? "_\("\(pub.issueTagNumber)".hasSuffix("00") ? pub.issueTagNumber / 100 : pub.issueTagNumber)" : "")"
        let dbPath = FileManager.getDocumentsDirectory().appendingPathComponent("\(pubName)/contents/\(pubName).db")
        var db: OpaquePointer?
        if sqlite3_open("\(dbPath)", &db) == SQLITE_OK {
            let query = """
                        SELECT MepsDocumentId FROM Document;
                        """
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let documentId = Int(sqlite3_column_int(statement, 0))
                    let articleURL = "https://wol.jw.org/it/wol/d/r6/lp-i/\(documentId)"
                    FileDownloader.downloadArticle(url: URL(string: articleURL)!, path: "Documents_I/\(documentId).html")
                }
                sqlite3_finalize(statement)
            }
        } else {
            print("Error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
    }

    static func getDocuments(pub: Publication) -> [Document] {
        var documents: [Document] = []
        let pubName = "\(pub.keySymbol)_I\(pub.issueTagNumber != 0 ? "_\("\(pub.issueTagNumber)".hasSuffix("00") ? pub.issueTagNumber / 100 : pub.issueTagNumber)" : "")"
        let dbPath = FileManager.getDocumentsDirectory().appendingPathComponent("\(pubName)/contents/\(pubName).db")
        var db: OpaquePointer?
        if sqlite3_open("\(dbPath)", &db) == SQLITE_OK {
            let query = """
                        SELECT MepsDocumentId, Title FROM Document;
                        """
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let documentId = Int(sqlite3_column_int(statement, 0))
                    let title = String(cString: sqlite3_column_text(statement, 1))
                    documents.append(Document(documentId: documentId, title: title))
                }
                sqlite3_finalize(statement)
            }
        } else {
            print("Error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
        return documents
    }

    static func getDocumentImages(pub: Publication, documentNumber: Int) -> [NSData] {
        var images: [NSData] = []
        let pubName = "\(pub.keySymbol)_I\(pub.issueTagNumber != 0 ? "_\("\(pub.issueTagNumber)".hasSuffix("00") ? pub.issueTagNumber / 100 : pub.issueTagNumber)" : "")"
        let contentPath = FileManager.getDocumentsDirectory().appendingPathComponent("\(pubName)/contents/")
        let dbPath = contentPath.appendingPathComponent("\(pubName).db")
        var db: OpaquePointer?
        if sqlite3_open("\(dbPath)", &db) == SQLITE_OK {
            let query = """
                        SELECT FilePath FROM DocumentMultimedia
                        INNER JOIN Document ON Document.DocumentId = DocumentMultimedia.DocumentId
                        INNER JOIN Multimedia ON Multimedia.MultimediaId = DocumentMultimedia.MultimediaId
                        WHERE Document.MepsDocumentId = \(documentNumber)
                        AND (BeginParagraphOrdinal IS NOT NULL OR EndParagraphOrdinal IS NOT NULL)
                        ORDER BY Multimedia.MultimediaId;
                        """
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let fileName = String(cString: sqlite3_column_text(statement, 0))
                    let imgPath = contentPath.appendingPathComponent(fileName)
                    if let image = NSData(contentsOfFile: imgPath.path) {
                        images.append(image)
                    }
                }
                sqlite3_finalize(statement)
            }
        } else {
            print("Error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
        return images
    }
}
