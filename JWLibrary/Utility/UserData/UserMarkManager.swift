//
//  UserMarkManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation
import SQLite3

class UserMarkManager {
    static func addUserMark(color: Int, locationId: Int, pubbKey: String, lang: Int = 4) -> Int {
        let markGuid: String = UUID().uuidString
        var db: OpaquePointer?
        var lastID: Int = 0
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
            let query = """
                        INSERT INTO UserMark (ColorIndex, LocationId, StyleIndex, UserMarkGuid, Version)
                        VALUES (\(color), \(locationId), 0, '\(markGuid)', 1);
                        """
            if sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK {
                print("VALUES (\(color), \(locationId), 0, \(pubbKey), \(lang), 0) ADDED TO UserMark ✅")
                lastID = Int(sqlite3_last_insert_rowid(db))
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error: \(errmsg) ⚠️")
            }
        } else {
            print("error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
        return lastID
    }
    static func getUserMark(locationId: Int) -> [UserMark] {
        var userMarks: [UserMark] = []
        var db: OpaquePointer?
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
            let query = "SELECT UserMarkId, ColorIndex FROM UserMark WHERE LocationId = \(locationId);"
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    let color = Int(sqlite3_column_int(statement, 1))
                    userMarks.append(UserMark(ID: id, color: color))
                }
                sqlite3_finalize(statement)
            }
        } else {
            print("error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
        print("Found \(userMarks.count) userMark ✅")
        return userMarks
    }
    static func removeUserMark(userMarkId: Int) {
        var db: OpaquePointer?
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
            let query = "DELETE FROM UserMark WHERE UserMarkId = \(userMarkId);"
            if sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK {
                print("UserMark removed ✅")
            } else {
                let errmsg = String(cString: sqlite3_errmsg(db)!)
                print("error \(errmsg) ⚠️")
            }
        } else {
            print("error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
    }

}
