//
//  DBManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 01/01/21.
//

import Foundation
import SQLite3

class DBManager {
    static func getBibleBooks() -> [BibleBook] {
        var bibleBooks: [BibleBook] = []
        let biblePath = FileManager.getDocumentsDirectory().appendingPathComponent("nwt_I/contents/nwt_I.db")
        var db: OpaquePointer?
        if sqlite3_open("\(biblePath)", &db) == SQLITE_OK {
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
            print("Error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
        return bibleBooks
    }
    static func getPublications() -> [Publication] {
        var publications: [Publication] = []
        let catalogPath = FileManager.getDocumentsDirectory().appendingPathComponent("catalog.db")
        var db: OpaquePointer?
        if sqlite3_open("\(catalogPath)", &db) == SQLITE_OK {
            let query = """
                        SELECT Id, KeySymbol, Year, MepsLanguageId, PublicationTypeId, IssueTagNumber, Title, IssueTitle
                        FROM Publication
                        WHERE MepsLanguageId = 4;
                        """
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let ID = Int(sqlite3_column_int(statement, 0))
                    let keySymbol = String(cString: sqlite3_column_text(statement, 1))
                    let year = Int(sqlite3_column_int(statement, 2))
                    let mepsLanguageId = Int(sqlite3_column_int(statement, 3))
                    let publicationTypeId = Int(sqlite3_column_int(statement, 4))
                    let issueTagNumber = Int(sqlite3_column_int(statement, 5))
                    let title = String(cString: sqlite3_column_text(statement, 6))
                    let issueTitle: String?  = sqlite3_column_type(statement, 7) != SQLITE_NULL ? String(cString: sqlite3_column_text(statement, 7)) : nil
                    publications.append(Publication(ID: ID, keySymbol: keySymbol, year: year, mepsLanguageId: mepsLanguageId, publicationTypeId: publicationTypeId, issueTagNumber: issueTagNumber, title: title, issueTitle: issueTitle))
                }
                sqlite3_finalize(statement)
            }
        } else {
            print("Error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
        print("\(publications.count) publications found ✅")
        return publications
    }
}
//
