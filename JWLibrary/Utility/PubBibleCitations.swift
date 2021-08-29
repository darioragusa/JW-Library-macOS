//
//  PubBibleCitations.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 26/08/21.
//

import Foundation
import SQLite3
import WebKit
import JavaScriptCore

class PubBibleCitations {
    private static func getBibleCitation(_ pub: Publication, _ documentNumber: Int, _ paragraphOrdinal: Int, _ verseIndex: Int) -> ClosedRange<Int>? {
        var bibleCitation: ClosedRange<Int>?
        let pubName = "\(pub.keySymbol)_I\(pub.issueTagNumber != 0 ? "_\("\(pub.issueTagNumber)".hasSuffix("00") ? pub.issueTagNumber / 100 : pub.issueTagNumber)" : "")"
        let contentPath = FileManager.getDocumentsDirectory().appendingPathComponent("\(pubName)/contents/")
        let dbPath = contentPath.appendingPathComponent("\(pubName).db")
        var db: OpaquePointer?
        if sqlite3_open("\(dbPath)", &db) == SQLITE_OK {
            let query = """
                        SELECT FirstBibleVerseId, LastBibleVerseId FROM BibleCitation
                        WHERE DocumentId = \(documentNumber) AND ParagraphOrdinal = \(paragraphOrdinal)
                        ORDER BY BlockNumber, ElementNumber
                        LIMIT \(verseIndex), 1;
                        """
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let first = Int(sqlite3_column_int(statement, 0))
                    let last = Int(sqlite3_column_int(statement, 1))
                    bibleCitation = first...last
                }
                sqlite3_finalize(statement)
            }
        } else {
            print("Error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
        return bibleCitation
    }

    static func getBibleVerse(pub: Publication, documentNumber: Int, paragraphOrdinal: Int, verseIndex: Int) -> BibleVerses {
        var bibleVerses: BibleVerses = BibleVerses(bookNumber: 0, chapterNumber: 0, versesIds: [])
        let citationRange = getBibleCitation(pub, documentNumber, paragraphOrdinal, verseIndex)
        if let citationRange = citationRange {
            let dbPath = FileManager.getDocumentsDirectory().appendingPathComponent("nwt_I/contents/nwt_I.db")
            var db: OpaquePointer?
            if sqlite3_open("\(dbPath)", &db) == SQLITE_OK {
                let query = """
                            SELECT BookNumber, ChapterNumber, FirstVerseId FROM BibleChapter
                            WHERE (\(citationRange.min() ?? 0) BETWEEN FirstVerseId AND LastVerseId)
                            AND (\(citationRange.max() ?? 0) BETWEEN FirstVerseId AND LastVerseId);
                            """
                var statement: OpaquePointer?
                if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                    while sqlite3_step(statement) == SQLITE_ROW {
                        let book = Int(sqlite3_column_int(statement, 0))
                        let chapter = Int(sqlite3_column_int(statement, 1))
                        let first = Int(sqlite3_column_int(statement, 2))
                        let range = Array((citationRange.lowerBound - first + 1)...(citationRange.upperBound - first + 1))
                        bibleVerses = BibleVerses(bookNumber: book, chapterNumber: chapter, versesIds: range)
                    }
                    sqlite3_finalize(statement)
                }
            } else {
                print("Error opening database ⚠️")
            }
            sqlite3_close(db)
            db = nil

        }
        return bibleVerses
    }
}
