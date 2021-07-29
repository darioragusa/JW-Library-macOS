//
//  SavesManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 03/01/21.
//

import Foundation
import SQLite3
import AppKit

// L'identifier (almeno nella Bibbia) sarebbe il versetto

class UserDataManager {
    static let userDataPath = FileManager.getDocumentsDirectory().appendingPathComponent("userData")
    static let dbPath = FileManager.getDocumentsDirectory().appendingPathComponent("userData/user_data.db")
    static let dbPathShm = FileManager.getDocumentsDirectory().appendingPathComponent("userData/user_data.db-shm")
    static let dbPathWal = FileManager.getDocumentsDirectory().appendingPathComponent("userData/user_data.db-wal")
    static let jsonPath = FileManager.getDocumentsDirectory().appendingPathComponent("userData/manifest.json")
    static let jsonDefPath = FileManager.getDocumentsDirectory().appendingPathComponent("userData/manifestDefault.json")

    // MARK: Highlight
    static func addHighlight(color: Int, identifier: Int, startToken: Int, endToken: Int, pubb: String, book: Int, chapter: Int, lang: Int = 4) {
        print("🆘 NUOVA OPERAZIONE 🆘")
        var pubbKey = pubb.split(separator: "_").first!
        if pubbKey == "nwt" { pubbKey = "nwtsty" }
        let existingArray = getExistingBlockRange(blockRange: BlockRange(identifier: identifier, startToken: startToken, endToken: endToken))
        if color > 0 {
            var newStartToken = startToken
            var newEndToken = endToken
            for existing in existingArray {
                newStartToken = existing.startToken < newStartToken ? existing.startToken : newStartToken
                newEndToken = existing.endToken > newEndToken ? existing.endToken : newEndToken
                removeBlockRange(userMarkId: existing.userMarkId)
                removeUserMark(userMarkId: existing.userMarkId)
            }
            let locationId = UserDataManager.getLocation(pubb: String(pubbKey), book: book, chapter: chapter)
            let markId = UserDataManager.addUserMark(color: color, locationId: locationId, pubbKey: String(pubbKey))
            UserDataManager.addBlockRange(identifier: identifier, startToken: newStartToken, endToken: newEndToken, markId: markId)
            print("Sottolineatura aggiunta ✅")
        } else {
            for existing in existingArray {
                let shouldSplit: Bool = existing.startToken < startToken && existing.endToken > endToken
                if shouldSplit { // Ricuco l'end e creo uno nuovo
                    updateBlockRange(existing: Existing(userMarkId: existing.userMarkId,
                                                            startToken: existing.startToken,
                                                            endToken: startToken - 1,
                                                            colorIndex: existing.colorIndex))
                    let locationId = UserDataManager.getLocation(pubb: String(pubbKey), book: book, chapter: chapter)
                    let markId = UserDataManager.addUserMark(color: existing.colorIndex, locationId: locationId, pubbKey: String(pubbKey))
                    UserDataManager.addBlockRange(identifier: identifier,
                                                  startToken: endToken + 1,
                                                  endToken: existing.endToken,
                                                  markId: markId)
                } else {
                    if startToken <= existing.startToken && endToken >= existing.startToken && endToken < existing.endToken { // Aumento lo start
                        updateBlockRange(existing: Existing(userMarkId: existing.userMarkId,
                                                                startToken: endToken + 1,
                                                                endToken: existing.endToken,
                                                                colorIndex: existing.colorIndex))
                    } else if endToken >= existing.endToken && startToken <= existing.endToken  && startToken > existing.startToken { // Riduco l'end
                        updateBlockRange(existing: Existing(userMarkId: existing.userMarkId,
                                                                startToken: existing.startToken,
                                                                endToken: startToken - 1,
                                                                colorIndex: existing.colorIndex))
                    } else if existing.startToken >= startToken && existing.endToken <= existing.endToken { // Lo elimino?
                        removeBlockRange(userMarkId: existing.userMarkId)
                        removeUserMark(userMarkId: existing.userMarkId)
                    }
                }
            }
            print("Sottolineatura rimossa ✅")
        }
    }
    static func getHighlight(pubb: String, book: Int, chapter: Int, lang: Int = 4) -> [Highlight] {
        var highlights: [Highlight] = []
        var pubbKey = pubb.split(separator: "_").first!
        if pubbKey == "nwt" { pubbKey = "nwtsty" }
        let locationId = getLocation(pubb: String(pubbKey), book: book, chapter: chapter)
        let userMarks: [UserMark] = getUserMark(locationId: locationId)
        for userMark in userMarks {
            let blockRange = getBlockRange(userMarkId: userMark.ID)
            highlights.append(Highlight(userMark: userMark, blockRange: blockRange))
        }
        print("Found \(highlights.count) userMark ✅")
        return highlights
    }

    // MARK: Location
    static func addLocation(pubb: String, book: Int, chapter: Int, lang: Int = 4) {
        var pubbKey = pubb.split(separator: "_").first!
        if pubbKey == "nwt" { pubbKey = "nwtsty" }
        var db: OpaquePointer?
        if sqlite3_open(dbPath.path, &db) == SQLITE_OK {
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
        if sqlite3_open(dbPath.path, &db) == SQLITE_OK {
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

    // MARK: BlockRange
    static func addBlockRange(identifier: Int, startToken: Int, endToken: Int, markId: Int) {
        var db: OpaquePointer?
        if sqlite3_open(dbPath.path, &db) == SQLITE_OK {
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
        if sqlite3_open(dbPath.path, &db) == SQLITE_OK {
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
        if sqlite3_open(dbPath.path, &db) == SQLITE_OK {
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
        if sqlite3_open(dbPath.path, &db) == SQLITE_OK {
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
        if sqlite3_open(dbPath.path, &db) == SQLITE_OK {
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

    // MARK: UserMark
    static func addUserMark(color: Int, locationId: Int, pubbKey: String, lang: Int = 4) -> Int {
        let markGuid: String = UUID().uuidString
        var db: OpaquePointer?
        var lastID: Int = 0
        if sqlite3_open(dbPath.path, &db) == SQLITE_OK {
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
        if sqlite3_open(dbPath.path, &db) == SQLITE_OK {
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
        if sqlite3_open(dbPath.path, &db) == SQLITE_OK {
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

    // MARK: Create backup
    static func createBackup() {
        let backupName = updateLastMod() + ".jwlibrary"
        storeDataInDB()
        let savePanel = NSSavePanel()
        savePanel.canCreateDirectories = true
        savePanel.showsTagField = false
        savePanel.nameFieldStringValue = backupName
        savePanel.level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.modalPanelWindow)))
        savePanel.begin { (result) in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                do {
                    if FileManager().fileExists(atPath: savePanel.url!.path) {
                        try FileManager().removeItem(at: savePanel.url!)
                    }
                    let archive = Archive(url: savePanel.url!, accessMode: .create)!
                    try archive.addEntry(with: "user_data.db", relativeTo: userDataPath)
                    try archive.addEntry(with: "manifest.json", relativeTo: userDataPath)
                    try FileManager().removeItem(at: jsonPath)
                } catch {
                    print("\(error) ⚠️")
                }
            }
        }
    }
    private static func updateLastMod() -> String {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: now)
        formatter.dateFormat = "HH:mm:ss"
        let timeString = formatter.string(from: now)
        let timeStamp = "\(dateString)T\(timeString)+01:00"
        updateLastmodDB(date: dateString, time: timeString, timeStamp: timeStamp)
        return createJson(date: dateString, timeStamp: timeStamp)
    }
    private static func updateLastmodDB(date: String, time: String, timeStamp: String) {
        var db: OpaquePointer?
        if sqlite3_open(dbPath.path, &db) == SQLITE_OK {
            let query = "UPDATE LastModified SET LastModified = '\(timeStamp)';"
            if sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK {
                print("LastMod updated to \(timeStamp) ✅")
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
    private static func storeDataInDB() {
        var db: OpaquePointer?
        if sqlite3_open(dbPath.path, &db) == SQLITE_OK {
            let query = "PRAGMA wal_checkpoint(TRUNCATE);"
            if sqlite3_exec(db, query, nil, nil, nil) == SQLITE_OK {
                print("Data stored in DB ✅")
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
    private static func createJson(date: String, timeStamp: String) -> String {
        do {
            var jsonData = try String(contentsOf: jsonDefPath, encoding: .utf8)
            let deviceName = Stuff.getMacName().replacingOccurrences(of: " ", with: "-")
            let backupName = "UserDataBackup_\(date)_\(deviceName)"
            jsonData = jsonData.replacingOccurrences(of: "@BackupName", with: backupName)
            jsonData = jsonData.replacingOccurrences(of: "@BackupDate", with: date)
            jsonData = jsonData.replacingOccurrences(of: "@BackupTimeStamp", with: timeStamp)
            jsonData = jsonData.replacingOccurrences(of: "@DeviceName", with: deviceName)
            jsonData = jsonData.replacingOccurrences(of: "@64CharHash", with: (deviceName + "_" + timeStamp).sha256())
            try jsonData.write(toFile: jsonPath.path, atomically: true, encoding: .utf8)
            return backupName
        } catch {
            print("\(error) ⚠️")
            return ""
        }
    }

    // MARK: Restore backup
    static func restoreBackup() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.begin { (result) -> Void in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                guard let archive = Archive(url: openPanel.url!, accessMode: .read) else {
                    return
                }
                do {
                    try? FileManager().removeItem(at: dbPath)
                    try? FileManager().removeItem(at: dbPathShm)
                    try? FileManager().removeItem(at: dbPathWal)
                    let result = try archive.extract(archive["user_data.db"]!, to: dbPath)
                    print("Backup imported successfully (\(result)) ✅")
                } catch {
                    print("Extracting entry from archive failed with error:\(error)")
                }
            }
        }
    }
}
