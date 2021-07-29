//
//  File.swift
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
        clearName = clearName.replacingOccurrences(of: "Seconda", with: "1")
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
        try? FileManager().removeItem(at: files[0])
        try? FileManager().removeItem(at: files[1])
        for file in files {
            if !FileManager.fileExist(url: file) {
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
}

struct BibleButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .background(configuration.isPressed ? color.lighter(by: 30): color)
            .cornerRadius(6.0)
    }
}

struct EditButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .background(color)
            .cornerRadius(6.0)
    }
}

struct TransparentButtonStyle: ButtonStyle {
    let color: Color
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .background(color)
            .cornerRadius(6.0)
    }
}
