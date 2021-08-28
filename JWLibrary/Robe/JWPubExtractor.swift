//
//  JWPubExtractor.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 11/08/21.
//
//
// import Foundation
// import SQLite3
//
// MARK: USELESS, DON'T WASTE TIME
//
// class JWPubExtractor {
//    struct SearchIndex {
//        var WordID: Int
//        var TextUnitIndices: String
//        var PositionalList: String
//        var PositionalListIndex: String
//    }
//
//    static func testExtraction() {
//        var words: [Int: String] = [:]
//        var sIndexes: [SearchIndex] = []
//
//        let dbPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.absoluteString + "w_I_202110/contents/w_I_202110.db"
//        var db: OpaquePointer?
//        if sqlite3_open(dbPath, &db) == SQLITE_OK {
//            var query = """
//                        SELECT WordID, Word
//                        FROM Word;
//                        """
//            var statement: OpaquePointer?
//            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
//                while sqlite3_step(statement) == SQLITE_ROW {
//                    let id = Int(sqlite3_column_int(statement, 0))
//                    let word = String(describing: String(cString: sqlite3_column_text(statement, 1)))
//                    words[id] = word
//                }
//                sqlite3_finalize(statement)
//            }
//
//            query = """
//                        SELECT WordID, TextUnitIndices, PositionalList, PositionalListIndex
//                        FROM SearchIndexDocument;
//                        """
//            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
//                while sqlite3_step(statement) == SQLITE_ROW {
//                    let wordID = Int(sqlite3_column_int(statement, 0))
//                    let blobTextUnitIndices = sqlite3_column_blob(statement, 1)
//                    let blobPositionalList = sqlite3_column_blob(statement, 2)
//                    let blobPositionalListIndex = sqlite3_column_blob(statement, 3)
//                    let blobTextUnitIndicesLen = sqlite3_column_bytes(statement, 1)
//                    let blobPositionalListLen = sqlite3_column_bytes(statement, 2)
//                    let blobPositionalListIndexLen = sqlite3_column_bytes(statement, 3)
//                    let textUnitIndices = NSData(bytes: blobTextUnitIndices, length: Int(blobTextUnitIndicesLen))
//                    let positionalList = NSData(bytes: blobPositionalList, length: Int(blobPositionalListLen))
//                    let positionalListIndex = NSData(bytes: blobPositionalListIndex, length: Int(blobPositionalListIndexLen))
//
//                    sIndexes.append(SearchIndex.init(WordID: wordID, TextUnitIndices: textUnitIndices.intVal, PositionalList: positionalList.intVal, PositionalListIndex: positionalListIndex.intVal))
//                }
//                sqlite3_finalize(statement)
//            }
//        } else {
//            print("Error opening database")
//        }
//        sqlite3_close(db)
//        db = nil
//
//        var loop = true
//        var docID = 0
//        var curDocIndex: String = "128"
//        var fullText: [Int: String] = [:]
//        if fullText[docID] == nil {
//            fullText[docID] = ""
//        }
//
//        while loop {
//            var finded = false
//            for i in 0...(sIndexes.count - 1) {
//                if sIndexes[i].TextUnitIndices.starts(with: "128") {
//                    if sIndexes[i].PositionalList.starts(with: curDocIndex) {
//                        var rem = sIndexes[i].PositionalListIndex.prefix(3)
//                        if Int(rem)! > 128 {
//                            finded = true
//                            let wd = words[sIndexes[i].WordID] ?? ""
//                            if wd != String(fullText[docID]?.split(separator: " ").last ?? "").unaccent() {
//                                print(curDocIndex, wd)
//                                fullText[docID]!.append(wd + " ")
//                            }
//                            sIndexes[i].PositionalList.removeFirst(curDocIndex.count)
//                            sIndexes[i].PositionalList = sIndexes[i].PositionalList.trimmingCharacters(in: .whitespacesAndNewlines)
//                            rem = "\(Int(rem)! - 1)"
//                            sIndexes[i].PositionalListIndex.removeFirst(3)
//                            sIndexes[i].PositionalListIndex = rem + sIndexes[i].PositionalListIndex
//                            let curDocIndexArray = curDocIndex.split(separator: " ")
//                            var repo = false
//                            for j in 0...(curDocIndexArray.count - 1) {
//                                if j == 0 {
//                                    if (curDocIndexArray[j] == "255" && curDocIndexArray.count == 1) || (curDocIndexArray[j] == "127" && curDocIndexArray.count > 1) {
//                                        repo = true
//                                        curDocIndex = "0"
//                                        if repo && j == curDocIndexArray.count - 1 {
//                                            curDocIndex += " 129"
//                                            repo = false
//                                        }
//                                    } else {
//                                        curDocIndex = "\(Int(curDocIndexArray[j])! + 1)"
//                                        repo = false
//                                    }
//                                } else {
//                                    if repo {
//                                        if curDocIndexArray[j] == "255" {
//                                            repo = true
//                                            curDocIndex += " 129"
//                                            if repo && j == curDocIndexArray.count - 1 {
//                                                curDocIndex += " 129"
//                                                repo = false
//                                            }
//                                        } else {
//                                            curDocIndex += " \(Int(curDocIndexArray[j])! + 1)"
//                                            repo = false
//                                        }
//                                    } else {
//                                        curDocIndex += " \(curDocIndexArray[j])"
//                                    }
//                                }
//                            }
//                            break
//                        }
//                    }
//                }
//            }
//            if !finded {
//                var toRem: [Int] = []
//                for i in 0...(sIndexes.count - 1) {
//                    var docI = sIndexes[i].TextUnitIndices.prefix(3)
//                    sIndexes[i].TextUnitIndices.removeFirst(3)
//                    if Int(docI) == 128 {
//                        sIndexes[i].TextUnitIndices = sIndexes[i].TextUnitIndices.trimmingCharacters(in: .whitespacesAndNewlines)
//                        if sIndexes[i].TextUnitIndices != "" {
//                            docI = sIndexes[i].TextUnitIndices.prefix(3)
//                            sIndexes[i].TextUnitIndices.removeFirst(3)
//                            docI = "\(Int(docI)! - 1)"
//                            sIndexes[i].TextUnitIndices = docI + sIndexes[i].TextUnitIndices
//                        }
//                    } else {
//                        docI = "\(Int(docI)! - 1)"
//                        sIndexes[i].TextUnitIndices = docI + sIndexes[i].TextUnitIndices
//                    }
//                    if sIndexes[i].TextUnitIndices == "" {
//                        toRem.append(i)
//                    }
//                    let rem = sIndexes[i].PositionalListIndex.prefix(3)
//                    if Int(rem) == 128 {
//                        sIndexes[i].PositionalListIndex.removeFirst(3)
//                        sIndexes[i].PositionalListIndex = sIndexes[i].PositionalListIndex.trimmingCharacters(in: .whitespacesAndNewlines)
//                    }
//                }
//                for i in toRem.reversed() {
//                    sIndexes.remove(at: i)
//                }
//                docID += 1
//                if fullText[docID] == nil {
//                    fullText[docID] = ""
//                }
//                curDocIndex = "128"
//            }
//            if sIndexes.count == 0 {
//                loop = false
//            }
//        }
//        print(fullText)
//        for (id, text) in fullText where text != "" {
//            let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("w_I_202110/contents/\(id).txt")
//            do {
//                print(dir)
//                try text.write(to: dir, atomically: true, encoding: String.Encoding.utf8)
//            } catch {
//                print("Error")
//            }
//        }
//    }
// }
//
// extension NSData {
//    var intVal: String {
//        var hexString = ""
//        for byte in self {
//            hexString += "\(byte) "
//        }
//        return hexString
//    }
// }
// extension String {
//    func unaccent() -> String {
//        return self.folding(options: .diacriticInsensitive, locale: .current)
//    }
// }
