//
//  LocationManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation
import SQLite3

class LocationManager {
    static func addLocation(pubb: String, book: Int, chapter: Int, lang: Int = 4) {
        var pubbKey = pubb.split(separator: "_").first!
        if pubbKey == "nwt" { pubbKey = "nwtsty" }
        var db: OpaquePointer?
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
            let query = """
                        INSERT INTO Location (BookNumber, ChapterNumber, IssueTagNumber, KeySymbol, MepsLanguage, Type)
                        SELECT \(book), \(chapter), 0, '\(pubbKey)', \(lang), 0
                        WHERE NOT EXISTS(SELECT * FROM Location
                                         WHERE BookNumber = \(book)
                                         AND ChapterNumber = \(chapter)
                                         AND KeySymbol = '\(pubbKey)'
                                         AND MepsLanguage = \(lang));
                        """
            if sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK {
                print("VALUES (\(book), \(chapter), 0, \(pubbKey), \(lang), 0) ADDED TO Lcation ✅")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error: \(errmsg) ⚠️")
            }
        } else {
            print("error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
    }
    static func getLocation(pubb: String, book: Int, chapter: Int, lang: Int = 4) -> Int {
        var db: OpaquePointer?
        var location: Int = 0
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
            let query = """
                        SELECT LocationId FROM Location
                        WHERE KeySymbol = '\(pubb)' AND BookNumber = \(book) AND ChapterNumber = \(chapter) AND MepsLanguage  = \(lang);
                        """
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    location = Int(sqlite3_column_int(statement, 0))
                }
                sqlite3_finalize(statement)
            }
        } else {
            print("error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
        return location
    }

}
