//
//  JWPubManager.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 01/01/21.
//

import Foundation

class JWPubManager {
    static func extractPubb(url: URL) {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let sourceURL = documentsUrl.appendingPathComponent(url.lastPathComponent)
        let destinationURL = URL(string: sourceURL.absoluteString.replacingOccurrences(of: ".jwpub", with: ""))!
        print(sourceURL)
        print(destinationURL)
        do {
            try FileManager().createDirectory(at: destinationURL, withIntermediateDirectories: true, attributes: nil)
            try FileManager().unzipItem(at: sourceURL, to: destinationURL)
            let contentsFileURL = URL(string: destinationURL.absoluteString + "/contentsFile")!
            let contentsFolderURL = URL(string: destinationURL.absoluteString + "/contents")!
            print(contentsFileURL)
            print(contentsFolderURL)
            deleteFile(filePath: sourceURL)
            do {
                try FileManager().moveItem(at: contentsFolderURL, to: contentsFileURL)
                try FileManager().createDirectory(at: contentsFolderURL, withIntermediateDirectories: true, attributes: nil)
                try FileManager().unzipItem(at: contentsFileURL, to: contentsFolderURL)
                deleteFile(filePath: contentsFileURL)
            }
        } catch {
            print("Extraction of ZIP archive failed with error:\(error)")
        }
    }

    static func deleteFile(filePath: URL) {
        do {
            try FileManager.default.removeItem(at: filePath)
            print("File deleted")
        } catch {
            print("Error")
        }
    }

    /*
     Adesso viene la parte bella: JW Library su Windows ha un catalogo
     con tutte le pubblicazioni ed io non ho la minima idea di come
     recuperarlo (potrei fare copia ed incolla ma non saprei come
     tenerlo aggiornato). Quindi adesso presumo venga la parte bella
     dove mi invento il modo più contorto per farmene uno...
     */
    static func lookForPubb() -> [(Int, [Int])] {
        let last = getLastPubb()
        let year = last.0
        let month = last.1
        let pubb = "w"
        var result: [(Int, [Int])] = []
        for pubbYear in 2010...(year) {
            var array: [Int] = []
            for pubbMonth in 1...12 where (pubbYear * 100) + pubbMonth <= (year * 100 + month) {
                array.append(pubbMonth)
                print("\(pubb)_I_\(pubbYear)\(pubbMonth.leadingZero())")
            }
            result.append((pubbYear, array))
        }
        return result.reversed()
    }

    static func getLastPubb() -> (Int, Int) {
        var year: Int
        var month: Int
        let url = URL(string: "https://www.jw.org/it/biblioteca-digitale/riviste/?contentLanguageFilter=it&pubFilter=w&yearFilter=")!
        do {
            let HTMLString = try String(contentsOf: url, encoding: .utf8)
            let var1 = HTMLString.components(separatedBy: "<div class=\"publicationDesc\">")[1]
            let var2 = var1.components(separatedBy: "</a>")[0]
            let var3 = var2.components(separatedBy: ">").last
            let var4 = var3?.trimmingCharacters(in: .whitespacesAndNewlines)
            let splitted = var4!.components(separatedBy: " ")
            year = Int(splitted[1])!
            month = splitted[0].monthN()
        } catch {
            year = Calendar.current.component(.year, from: Date())
            month = Calendar.current.component(.month, from: Date())
        }
        return (year, month)
    }
}
