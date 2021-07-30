//
//  NoteManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation
import SQLite3

class NoteManager {
    static func getNotes() -> [Note] {
        var notes: [Note] = []
        var db: OpaquePointer?
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
            let query = "SELECT NoteId, Title, Content FROM Note;"
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let id = Int(sqlite3_column_int(statement, 0))
                    let title = String(cString: sqlite3_column_text(statement, 1))
                    let content = String(cString: sqlite3_column_text(statement, 2))
                    notes.append(Note(ID: id, title: title, content: content))
                }
                sqlite3_finalize(statement)
            }
        } else {
            print("error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
        print("Found \(notes.count) notes ✅")
        return notes
    }
}
