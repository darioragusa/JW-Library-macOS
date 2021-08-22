//
//  FileDownloader.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 01/01/21.
//

import Foundation

class FileDownloader {
    static func loadFileSync(url: URL, completion: @escaping (String?, Error?) -> Void) {
        let destinationUrl = FileManager.getDocumentsDirectory().appendingPathComponent(url.lastPathComponent)
        if FileManager().fileExists(atPath: destinationUrl.path) {
            print("File already exists [\(destinationUrl.path)]")
            completion(destinationUrl.path, nil)
        } else if let dataFromURL = NSData(contentsOf: url) {
            if dataFromURL.write(to: destinationUrl, atomically: true) {
                print("File saved [\(destinationUrl.path)] ✅")
                JWPubManager.extractPub(url: url)
                completion(destinationUrl.path, nil)
            } else {
                print("Error saving file ⚠️")
                let error = NSError(domain: "Error saving file", code: 1001, userInfo: nil)
                completion(destinationUrl.path, error)
            }
        } else {
            let error = NSError(domain: "Error downloading file", code: 1002, userInfo: nil)
            completion(destinationUrl.path, error)
        }
    }

    static func loadFileAsync(url: URL, completion: @escaping (String?, Error?) -> Void) {
        let destinationUrl = FileManager.getDocumentsDirectory().appendingPathComponent(url.lastPathComponent)
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
                                if "\(url)".hasSuffix("jwpub") {
                                    if (try? data.write(to: destinationUrl, options: Data.WritingOptions.atomic)) != nil {
                                        JWPubManager.extractPub(url: url)
                                        completion(destinationUrl.path, error)
                                    } else {
                                        completion(destinationUrl.path, error)
                                    }
                                } else if "\(url)".hasSuffix("gz") {
                                    do {
                                        let newDest = "\(destinationUrl)".replacingOccurrences(of: ".gz", with: "")
                                        let decompressedData = try data.gunzipped()
                                        try decompressedData.write(to: URL(string: newDest)!, options: Data.WritingOptions.atomic)
                                        completion(destinationUrl.path, error)
                                    } catch {
                                        completion(destinationUrl.path, error)
                                    }
                                } else {
                                    do {
                                        try data.write(to: destinationUrl, options: Data.WritingOptions.atomic)
                                        completion(destinationUrl.path, error)
                                    } catch {
                                        completion(destinationUrl.path, error)
                                    }
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
            if FileManager.articleExist(path: path) {
                print("Skipping \(path) ✅")
                return
            } else {
                print("Downloading \(path) ✅")
            }
            let HTMLString = try String(contentsOf: url, encoding: .utf8)
            var article = HTMLString.components(separatedBy: "<div class=\"scalableui\">").last
            article = article?.components(separatedBy: "<!-- Root element of lightbox -->").first
            do {
                let destinationUrl = FileManager.getDocumentsDirectory().appendingPathComponent(path)
                try article!.write(toFile: destinationUrl.path, atomically: true, encoding: .utf8)
            } catch {
                print("Error: \(error) ⚠️")
                return
            }
        } catch let error {
            print("Error: \(error) ⚠️")
        }
    }
}

/*
 let url = URL(string: "http://www.filedownloader.com/mydemofile.pdf")
 FileDownloader.loadFileAsync(url: url!) { (path, error) in
     print("PDF File downloaded to : \(path!)")
 }
 */
