//
//  BibleView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 01/01/21.
//

import SwiftUI
let bibleURL = URL(string: "https://download-a.akamaihd.net/files/media_publication/c1/nwt_I.jwpub")!

struct BibleView: View {
    @State var downloadProgress = "Scarico struttura..."
    @State var bibleDownloaded = FileDownloader.fileExist(url: bibleURL) && FileDownloader.articleExist(path: "nwt_I/66/22.html")
    @State var bibleBooks: [BibleBook] = []
    @State var bibleBookIndex: Int = -1
    @State var chapter = 0
    var body: some View {
        GeometryReader { geometryReader in
            ScrollView {
                if bibleDownloaded && bibleBooks.count > 0 && bibleBookIndex == -1 {
                    BibleBooksView(bibleBooks: bibleBooks, bibleBookIndex: $bibleBookIndex)
                } else if bibleBookIndex > -1 && chapter == 0 {
                    BibleChaptersView(bibleBook: bibleBooks[bibleBookIndex], bibleBookIndex: $bibleBookIndex, chapter: $chapter)
                } else if chapter > 0 {
                    ArticleView(pubb: "nwt_I", prevText: bibleBooks[bibleBookIndex].shortName, geometryReader: geometryReader, book: bibleBookIndex + 1, chapter: $chapter)
                } else {
                    Text(downloadProgress)
                }
            }
        }
        .onAppear(perform: {
            if !bibleDownloaded {
                if !FileDownloader.fileExist(url: bibleURL) {
                    FileDownloader.loadFileAsync(url: bibleURL, completion: { _, _ in
                        downloadText()
                    })
                }
                bibleBooks = DBManager.getBibleBooks()
                if FileDownloader.fileExist(url: bibleURL) && !FileDownloader.articleExist(path: "nwt_I/66/22.html") {
                    downloadText()
                }
            } else {
                bibleBooks = DBManager.getBibleBooks()
            }
        })
    }

    func downloadText() {
        downloadProgress = "Scarico testo..."
        let group = DispatchGroup()
        group.enter()
        FileDownloader.downloadBible(bibleBooks: bibleBooks) { _ in
            group.leave()
        }
        group.notify(queue: .main) {
            bibleDownloaded = true
        }
    }
}

struct BibleView_Previews: PreviewProvider {
    static var previews: some View {
        BibleView()
    }
}
