//
//  Paths.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation

struct Paths {
    static let dbPath = FileManager.getDocumentsDirectory().appendingPathComponent("userData/user_data.db")
    static let userDataPath = FileManager.getDocumentsDirectory().appendingPathComponent("userData")
    static let dbPathShm = FileManager.getDocumentsDirectory().appendingPathComponent("userData/user_data.db-shm")
    static let dbPathWal = FileManager.getDocumentsDirectory().appendingPathComponent("userData/user_data.db-wal")
    static let jsonPath = FileManager.getDocumentsDirectory().appendingPathComponent("userData/manifest.json")
    static let jsonDefPath = FileManager.getDocumentsDirectory().appendingPathComponent("userData/manifestDefault.json")
}
