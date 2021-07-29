//
//  BlockRangeManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation
import SQLite3

class BlockRangeManager {
    static func addBlockRange(identifier: Int, startToken: Int, endToken: Int, markId: Int) {
        var db: OpaquePointer?
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
            let query = """
                        INSERT INTO BlockRange (BlockType, Identifier, StartToken, EndToken, UserMarkId)
                        VALUES (2, \(identifier), \(startToken), \(endToken), \(markId));
                        """
            if sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK {
                print("VALUES (\(identifier), \(startToken), \(endToken), \(markId)) ADDED TO BlockRange ✅")
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
    static func getExistingBlockRange(blockRange: BlockRange) -> [Existing] {
        var db: OpaquePointer?
        var existingArray: [Existing] = []
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
            let query = """
                        SELECT BlockRange.UserMarkId, BlockRange.StartToken, BlockRange.EndToken, ColorIndex FROM  BlockRange
                        JOIN UserMark On BlockRange.UserMarkId = UserMark.UserMarkId
                        WHERE BlockRange.Identifier = \(blockRange.identifier) AND
                        ((EndToken BETWEEN \(blockRange.startToken) AND \(blockRange.endToken)) OR
                         (StartToken BETWEEN \(blockRange.startToken) AND \(blockRange.endToken)) OR
                        (StartToken >= \(blockRange.startToken) AND EndToken <= \(blockRange.endToken)));
                        """
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let userMarkId = Int(sqlite3_column_int(statement, 0))
                    let startToken = Int(sqlite3_column_int(statement, 1))
                    let endToken = Int(sqlite3_column_int(statement, 2))
                    let colorIndex = Int(sqlite3_column_int(statement, 3))
                    existingArray.append(Existing(userMarkId: userMarkId,
                                                  startToken: startToken,
                                                  endToken: endToken,
                                                  colorIndex: colorIndex))
                    print("Esisting BlockRange found ‼️")
                }
                sqlite3_finalize(statement)
            }
        } else {
            print("error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
        return existingArray
    }
    static func getBlockRange(userMarkId: Int) -> BlockRange {
        var db: OpaquePointer?
        var blockRange = BlockRange(identifier: -1, startToken: -1, endToken: -1)
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
            let query = "SELECT Identifier, StartToken, EndToken FROM BlockRange WHERE UserMarkId = \(userMarkId);"
            var statement: OpaquePointer?
            if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK {
                while sqlite3_step(statement) == SQLITE_ROW {
                    let identifier = Int(sqlite3_column_int(statement, 0))
                    let startToken = Int(sqlite3_column_int(statement, 1))
                    let endToken = Int(sqlite3_column_int(statement, 2))
                    blockRange = BlockRange(identifier: identifier, startToken: startToken, endToken: endToken)
                    print("BlockRange found ✅")
                }
                sqlite3_finalize(statement)
            }
        } else {
            print("error opening database ⚠️")
        }
        sqlite3_close(db)
        db = nil
        return blockRange
    }
    static func removeBlockRange(userMarkId: Int) {
        var db: OpaquePointer?
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
            let query = "DELETE FROM BlockRange WHERE UserMarkId = \(userMarkId);"
            if sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK {
                print("BlockRange removed ✅")
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
    static func updateBlockRange(existing: Existing) {
        var db: OpaquePointer?
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
            let query = "UPDATE BlockRange SET StartToken = \(existing.startToken), EndToken = \(existing.endToken) WHERE UserMarkId = \(existing.userMarkId);"
            if sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK {
                print("BlockRange updated ✅")
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
