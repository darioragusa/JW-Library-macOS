//
//  DBManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 01/01/21.
//

import Foundation
import SQLite3

class DBManager {
    var path: String = "myDataBaseName.sqlite"
    func read(filePath: String) -> [Int] {
        var db: OpaquePointer?
        var mainList: [Int] = []
        if sqlite3_open(filePath, &db) == SQLITE_OK {
            let query = "SELECT * FROM your_table_name;"
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    // Int(sqlite3_column_int(statement, 0))
                    // String(describing: String(cString: sqlite3_column_text(statement, 1)))
                    mainList.append(1)
                }
            }
            sqlite3_finalize(statement)
        } else {
            print("error opening database")
        }
        sqlite3_close(db)
        db = nil
        return mainList
    }

    static func getBibleBooks() -> [BibleBook] {
        var bibleBooks: [BibleBook] = []
        let biblePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.absoluteString + "/nwt_I/contents/nwt_I.db"
        var db: OpaquePointer?
        if sqlite3_open(biblePath, &db) == SQLITE_OK {
            let query = """
                        SELECT BibleBook.BibleBookId, BibleBook.BookDisplayTitle, MAX(BibleChapter.ChapterNumber)
                        FROM BibleBook
                        JOIN BibleChapter ON BibleBook.BibleBookId =  BibleChapter.BookNumber
                        GROUP BY BibleBook.BibleBookId;
                        """
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let ID = Int(sqlite3_column_int(statement, 0))
                    let fullName = String(describing: String(cString: sqlite3_column_text(statement, 1)))
                    let chapters = Int(sqlite3_column_int(statement, 2))
                    bibleBooks.append(BibleBook(ID: ID, shortName: Stuff.clearBibleBookName(name: fullName), fullName: fullName, chapters: chapters))
                }
                sqlite3_finalize(statement)
            }
        } else {
            print("error opening database")
        }
        sqlite3_close(db)
        db = nil
        return bibleBooks
    }
}
