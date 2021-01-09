//
//  Downloader.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 01/01/21.
//

import Foundation

class FileDownloader {
    static func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void) {
        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        } else if let dataFromURL = NSData(contentsOf: url) {
            if dataFromURL.write(to: destinationUrl, atomically: true) {
                print("file saved [\(destinationUrl.path)]")
                JWPubManager.extractPubb(url: url)
                completion(destinationUrl.path, nil)
            } else {
                print("error saving file")
                let error = NSError(domain: "Error saving file", code: 1001, userInfo: nil)
                completion(destinationUrl.path, error)
            }
        } else {
            let error = NSError(domain: "Error downloading file", code: 1002, userInfo: nil)
            completion(destinationUrl.path, error)
        }
    }

    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void) {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        } else {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let task = session.dataTask(with: request, completionHandler: { data, response, error in
                if error == nil {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            if let data = data {
                                if (try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)) != nil {
                                    JWPubManager.extractPubb(url: url)
                                    completion(destinationUrl.path, error)
                                } else {
                                    completion(destinationUrl.path, error)
                                }
                            } else {
                                completion(destinationUrl.path, error)
                            }
                        }
                    }
                } else {
                    completion(destinationUrl.path, error)
                }
            })
            task.resume()
        }
    }

    static func downloadArticle(url: URL, path: String) {
        do {
            if articleExist(path: path) {
                print("Skipping \(path)")
                return
            } else {
                print("Downloading \(path)")
            }
            let HTMLString = try String(contentsOf: url, encoding: .utf8)
            var article = HTMLString.components(separatedBy: "<div class=\"scalableui\">").last
            article = article?.components(separatedBy: "<!-- Root element of lightbox -->").first
            do {
                let destinationUrl = getDocumentsDirectory().appendingPathComponent(path)
                try article!.write(toFile: destinationUrl.path, atomically: true, encoding: .utf8)
            } catch {
                print("Error", error)
                return
            }
        } catch let error {
            print("Error: \(error)")
        }
    }

    static func articleExist(path: String) -> Bool {
        let destinationUrl = getDocumentsDirectory().appendingPathComponent(path)
        return FileManager().fileExists(atPath: destinationUrl.path)
    }

    static func fileExist(url: URL) -> Bool {
        let destinationUrl = getDocumentsDirectory().appendingPathComponent(url.lastPathComponent)
        return FileManager().fileExists(atPath: destinationUrl.path.replacingOccurrences(of: ".jwpub", with: ""))
    }

    static func downloadBible(bibleBooks: [BibleBook], completion: (_ success: Bool) -> Void) {
        for book in bibleBooks {
            for chapter in 1...book.chapters {
                let destinationUrl = getDocumentsDirectory().appendingPathComponent("nwt_I/\(book.ID)")
                try? FileManager().createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
                downloadArticle(url: URL(string: "https://wol.jw.org/it/wol/b/r6/lp-i/nwtsty/\(book.ID)/\(chapter)#study=discover")!, path: "nwt_I/\(book.ID)/\(chapter).html")
            }
        }
        completion(true)
    }

    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

/*
 let url = URL(string: "http://www.filedownloader.com/mydemofile.pdf")
 FileDownloader.loadFileAsync(url: url!) { (path, error) in
     print("PDF File downloaded to : \(path!)")
 }
 */
