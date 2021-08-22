//
//  LocationManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation
import SQLite3

class LocationManager {
    static func addLocation(pub: Publication, documentId: Int? = nil) {
        var db: OpaquePointer?
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
            let query = pub.isBible ?
                        """
                        INSERT INTO Location (BookNumber, ChapterNumber, IssueTagNumber, KeySymbol, MepsLanguage, Type)
                        SELECT \(pub.book ?? 0), \(pub.chapter ?? 0), 0, '\(pub.keySymbol)', \(pub.mepsLanguageId), 0
                        WHERE NOT EXISTS(SELECT * FROM Location
                                         WHERE BookNumber = \(pub.book ?? 0)
                                         AND ChapterNumber = \(pub.chapter ?? 0)
                                         AND KeySymbol = '\(pub.keySymbol)'
                                         AND MepsLanguage = \(pub.mepsLanguageId));
                        """ :
                        """
                        INSERT INTO Location (DocumentID, IssueTagNumber, KeySymbol, MepsLanguage, Type)
                        SELECT \(documentId ?? 0), \(pub.issueTagNumber), '\(pub.keySymbol)', \(pub.mepsLanguageId), 0
                        WHERE NOT EXISTS(SELECT * FROM Location
                                         WHERE DocumentID = \(documentId ?? 0)
                                         AND IssueTagNumber = \(pub.issueTagNumber)
                                         AND KeySymbol = '\(pub.keySymbol)'
                                         AND MepsLanguage = \(pub.mepsLanguageId));
                        """
            if sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK {
                print("VALUES (\(pub.book ?? 0), \(pub.chapter ?? 0), \(documentId ?? 0), \(pub.issueTagNumber), \(pub.keySymbol), \(pub.mepsLanguageId), 0) IN Location ✅")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error: \(errmsg) ⚠️")
            }
        } else {
            print("Error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
    }
    static func getLocation(pub: Publication, documentId: Int? = nil) -> Int {
        var db: OpaquePointer?
        var location: Int = 0
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
            let query = pub.isBible ?
                        """
                        SELECT LocationId FROM Location
                        WHERE KeySymbol = '\(pub.keySymbol)' AND BookNumber = \(pub.book ?? 0) AND ChapterNumber = \(pub.chapter ?? 0) AND MepsLanguage  = \(pub.mepsLanguageId);
                        """ :
                        """
                        SELECT LocationId FROM Location
                        WHERE KeySymbol = '\(pub.keySymbol)' AND DocumentId = \(documentId ?? 0) AND IssueTagNumber = \(pub.issueTagNumber) AND MepsLanguage  = \(pub.mepsLanguageId);
                        """
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    location = Int(sqlite3_column_int(statement, 0))
                }
                sqlite3_finalize(statement)
            }
        } else {
            print("Error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
        return location
    }

}
