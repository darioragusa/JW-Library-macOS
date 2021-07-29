//
//  Ext_String.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 29/07/21.
//

import Foundation
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
