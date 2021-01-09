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
}
