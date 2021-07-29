//
//  BackupManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation
import AppKit
import SQLite3

class BackupManager {
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
                    try archive.addEntry(with: "user_data.db", relativeTo: Paths.userDataPath)
                    try archive.addEntry(with: "manifest.json", relativeTo: Paths.userDataPath)
                    try FileManager().removeItem(at: Paths.jsonPath)
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
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
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
        if sqlite3_open(Paths.dbPath.path, &db) == SQLITE_OK {
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
            var jsonData = try String(contentsOf: Paths.jsonDefPath, encoding: .utf8)
            let deviceName = Stuff.getMacName().replacingOccurrences(of: " ", with: "-")
            let backupName = "UserDataBackup_\(date)_\(deviceName)"
            jsonData = jsonData.replacingOccurrences(of: "@BackupName", with: backupName)
            jsonData = jsonData.replacingOccurrences(of: "@BackupDate", with: date)
            jsonData = jsonData.replacingOccurrences(of: "@BackupTimeStamp", with: timeStamp)
            jsonData = jsonData.replacingOccurrences(of: "@DeviceName", with: deviceName)
            jsonData = jsonData.replacingOccurrences(of: "@64CharHash", with: (deviceName + "_" + timeStamp).sha256())
            try jsonData.write(toFile: Paths.jsonPath.path, atomically: true, encoding: .utf8)
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
                    try? FileManager().removeItem(at: Paths.dbPath)
                    try? FileManager().removeItem(at: Paths.dbPathShm)
                    try? FileManager().removeItem(at: Paths.dbPathWal)
                    let result = try archive.extract(archive["user_data.db"]!, to: Paths.dbPath)
                    print("Backup imported successfully (\(result)) ✅")
                } catch {
                    print("Extracting entry from archive failed with error:\(error)")
                }
            }
        }
    }
}
