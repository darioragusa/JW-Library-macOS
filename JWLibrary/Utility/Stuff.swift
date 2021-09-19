//
//  Stuff.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 02/01/21.
//

import Foundation
import SwiftUI

class Stuff {
    static func clearBibleBookName(name: String) -> String {
        var clearName = name.replacingOccurrences(of: "Primo", with: "1")
        clearName = clearName.replacingOccurrences(of: "Prima", with: "1")
        clearName = clearName.replacingOccurrences(of: "Secondo", with: "2")
        clearName = clearName.replacingOccurrences(of: "Seconda", with: "2")
        clearName = clearName.replacingOccurrences(of: "Terza", with: "3")
        clearName = clearName.replacingOccurrences(of: "libro di ", with: "")
        clearName = clearName.replacingOccurrences(of: "libro dei ", with: "")
        clearName = clearName.replacingOccurrences(of: "libro delle ", with: "")
        clearName = clearName.replacingOccurrences(of: " (Qoèlet)", with: "")
        clearName = clearName.replacingOccurrences(of: "Vangelo secondo ", with: "")
        clearName = clearName.replacingOccurrences(of: " degli Apostoli", with: "")
        clearName = clearName.replacingOccurrences(of: "Lettera ai ", with: "")
        clearName = clearName.replacingOccurrences(of: "Lettera agli ", with: "")
        clearName = clearName.replacingOccurrences(of: "Lettera a ", with: "")
        clearName = clearName.replacingOccurrences(of: "lettera ai ", with: "")
        clearName = clearName.replacingOccurrences(of: "lettera a ", with: "")
        clearName = clearName.replacingOccurrences(of: "Lettera di ", with: "")
        clearName = clearName.replacingOccurrences(of: "lettera di ", with: "")
        clearName = clearName.replacingOccurrences(of: " a Giovanni (Apocalisse)", with: "")
        return clearName
    }

    static func hexColor(hex: Int) -> Color {
        let red: Double = Double((hex >> 16) & 0xFF) / 255
        let green: Double = Double((hex >> 8) & 0xFF) / 255
        let blue: Double = Double(hex & 0xFF) / 255
        return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }

    static func addBaseFiles() {
        let files = [
            FileManager.getDocumentsDirectory().appendingPathComponent("style.css"),
            FileManager.getDocumentsDirectory().appendingPathComponent("script.js"),
            FileManager.getDocumentsDirectory().appendingPathComponent("userData/user_data.db"),
            FileManager.getDocumentsDirectory().appendingPathComponent("userData/manifestDefault.json")
        ]
        let userDataFolder = FileManager.getDocumentsDirectory().appendingPathComponent("userData")
        try? FileManager().createDirectory(at: userDataFolder, withIntermediateDirectories: true, attributes: nil)
        let documentsFolder = FileManager.getDocumentsDirectory().appendingPathComponent("Documents_I")
        try? FileManager().createDirectory(at: documentsFolder, withIntermediateDirectories: true, attributes: nil)
        try? FileManager().removeItem(at: files[0])
        try? FileManager().removeItem(at: files[1])
        for file in files {
            if !FileManager.extractedJWPubExist(url: file) {
                try? FileManager().copyfileToUserDocumentDirectory(destPath: file)
            }
        }
    }

    static func getMacName() -> String {
        if let deviceName = Host.current().localizedName {
           return deviceName
        } else {
            return "Mac"
        }
    }

    static func getManifest() -> String? {
        var currentManifest: String?
        guard let url = URL(string: "https://app.jw-cdn.org/catalogs/publications/v4/manifest.json") else {
            return currentManifest
        }
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: url, completionHandler: {(data, _, error) in
            guard let data = data, error == nil else { return }
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any]
                let current = json?["current"] as? String ?? ""
                print("Manifest: \(current) ✅")
                currentManifest = current
                semaphore.signal()
            } catch {
                print("Error \(error) ⚠️")
                semaphore.signal()
            }
        }).resume()
        _ = semaphore.wait(timeout: .distantFuture)
        return currentManifest
    }

    static func getJWPubUrl(apiLink: URL) -> String? {
        var pubUrlString: String?
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.dataTask(with: apiLink, completionHandler: {(data, _, error) in
            guard let data = data, error == nil else { return }
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {
                    if let files = json["files"] as? [String: Any] {
                        if let lang = files["I"] as? [String: [Any]] {
                            if let JWPUB = lang["JWPUB"]![0] as? [String: Any] {
                                if let file = JWPUB["file"] as? [String: Any] {
                                    if let pubbUrlS = file["url"] as? String {
                                        print("Manifest: \(pubbUrlS) ✅")
                                        pubUrlString = pubbUrlS
                                    }
                                }
                            }
                        }
                    }
                }
                semaphore.signal()
            } catch {
                print("Error \(error) ⚠️")
                semaphore.signal()
            }
        }).resume()
        _ = semaphore.wait(timeout: .distantFuture)
        return pubUrlString
    }
}
