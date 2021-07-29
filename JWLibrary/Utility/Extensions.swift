//
//  Extensions.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 03/01/21.
//

import Foundation
import AppKit
import SwiftUI
import CommonCrypto

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }

    func sha256() -> String {
        if let stringData = self.data(using: String.Encoding.utf8) {
            return hexStringFromData(input: digest(input: stringData as NSData))
        }
        return ""
    }
    private func digest(input: NSData) -> NSData {
        let digestLength = Int(CC_SHA256_DIGEST_LENGTH)
        var hash = [UInt8](repeating: 0, count: digestLength)
        CC_SHA256(input.bytes, UInt32(input.length), &hash)
        return NSData(bytes: hash, length: digestLength)
    }

    private func hexStringFromData(input: NSData) -> String {
        var bytes = [UInt8](repeating: 0, count: input.length)
        input.getBytes(&bytes, length: input.length)

        var hexString = ""
        for byte in bytes {
            hexString += String(format: "%02x", UInt8(byte))
        }
        return hexString
    }

    func monthN() -> Int {
        switch self.lowercased() {
        case "gennaio":
            return 1
        case "febbraio":
            return 2
        case "marzo":
            return 3
        case "aprile":
            return 4
        case "maggio":
            return 5
        case "giugno":
            return 6
        case "luglio":
            return 7
        case "agosto":
            return 8
        case "settembre":
            return 9
        case "ottobre":
            return 10
        case "novembre":
            return 11
        case "dicembre":
            return 12
        default:
            return 0
        }
    }
}

extension Int {
    func leadingZero() -> String {
        return String(format: "%02d", self)
    }
    func monthN() -> String {
        switch self {
        case 1:
            return "Gennaio"
        case 2:
            return "Febbraio"
        case 3:
            return "Marzo"
        case 4:
            return "Aprile"
        case 5:
            return "Maggio"
        case 6:
            return "Giugno"
        case 7:
            return "Luglio"
        case 8:
            return "Agosto"
        case 9:
            return "Settembre"
        case 10:
            return "Ottobre"
        case 11:
            return "Novembre"
        case 12:
            return "Dicembre"
        default:
            return ""
        }
    }

}

extension Color {
    func lighter(by percentage: CGFloat) -> Color? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage: CGFloat) -> Color? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage: CGFloat) -> Color? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        let oldColor = NSColor(self)
        oldColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let color: NSColor = NSColor(red: min(red + percentage/100, 1.0),
                                    green: min(green + percentage/100, 1.0),
                                    blue: min(blue + percentage/100, 1.0),
                                    alpha: alpha)
        return Color.init(color)
    }
}

extension FileManager {
    func copyfileToUserDocumentDirectory(destPath: URL) throws {
        let fileFullName = destPath.lastPathComponent
        let fileName = String(fileFullName.split(separator: ".").first!)
        let fileExt = String(fileFullName.split(separator: ".").last!)
        if let bundlePath = Bundle.main.path(forResource: fileName, ofType: fileExt) {
            let fullDestPathString = destPath.path
            if !self.fileExists(atPath: fullDestPathString) {
                try self.copyItem(atPath: bundlePath, toPath: fullDestPathString)
            }
        }
    }
    
    static func articleExist(path: String) -> Bool { // nwt_I/66/22.html
        let destinationUrl = getDocumentsDirectory().appendingPathComponent(path)
        return FileManager().fileExists(atPath: destinationUrl.path)
    }

    static func fileExist(url: URL) -> Bool { // https://download-a.akamaihd.net/files/media_publication/c1/nwt_I.jwpub
        let destinationUrl = getDocumentsDirectory().appendingPathComponent(url.lastPathComponent)
        return FileManager().fileExists(atPath: destinationUrl.path.replacingOccurrences(of: ".jwpub", with: ""))
    }

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
        // file:///Users/darioragusa/Library/Containers/com.darioragusa.JWLibrary/Data/Documents/
    }
}

extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->Void)? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
            if let completion = completion {
                DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
                    completion()
                })
            }
        }
    }
}
