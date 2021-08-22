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
    @State var bibleDownloaded = false
    @State var bibleBooks: [BibleBook] = []
    @State var bibleBookIndex: Int = -1
    @State var chapter = 0
    @State var showArticle = false
    var body: some View {
        GeometryReader { geometryReader in
            ScrollView {
                if showArticle {
                    ArticleView(showArticle: $showArticle,
                                pub: Publication(ID: 0, keySymbol: "nwtsty", year: 2021, mepsLanguageId: 4, publicationTypeId: 1, issueTagNumber: 0, title: "Traduzione del Nuovo Mondo delle Sacre Scritture (edizione per lo studio)", isBible: true, book: bibleBookIndex + 1, chapter: chapter),
                                prevText: bibleBooks[bibleBookIndex].shortName,
                                geometryReader: geometryReader,
                                filePath: "nwt_I/\(bibleBookIndex + 1)/\(chapter).html")
                } else if bibleBookIndex > -1 {
                    BibleChaptersView(bibleBook: bibleBooks[bibleBookIndex], bibleBookIndex: $bibleBookIndex, chapter: $chapter, showArticle: $showArticle)
                } else if bibleDownloaded && bibleBooks.count > 0 && bibleBookIndex == -1 {
                        BibleBooksView(bibleBooks: bibleBooks, bibleBookIndex: $bibleBookIndex)
                } else {
                    Text(downloadProgress)
                        .padding()
                }
            }
        }
        .onAppear(perform: {
            if !FileManager.fileExist(url: bibleURL) {
                FileDownloader.loadFileAsync(url: bibleURL, completion: { _, _ in
                    bibleBooks = DBManager.getBibleBooks()
                    downloadText("Scarico")
                })
            } else {
                bibleBooks = DBManager.getBibleBooks()
                downloadText("Controllo")
            }
        })
    }

    func downloadText(_ op: String) {
        downloadProgress = op + " testo..."
        DispatchQueue.background(background: {
            for book in bibleBooks {
                for chapter in 1...book.chapters {
                    let destinationUrl = FileManager.getDocumentsDirectory().appendingPathComponent("nwt_I/\(book.ID)")
                    try? FileManager().createDirectory(at: destinationUrl, withIntermediateDirectories: true, attributes: nil)
                    FileDownloader.downloadArticle(url: URL(string: "https://wol.jw.org/it/wol/b/r6/lp-i/nwtsty/\(book.ID)/\(chapter)#study=discover")!, path: "nwt_I/\(book.ID)/\(chapter).html")
                    downloadProgress = op + " nwt_I/\(book.ID)/\(chapter)\n" + downloadProgress
                }
            }
        }, completion: {
            bibleDownloaded = true
        })
    }
}

struct BibleView_Previews: PreviewProvider {
    static var previews: some View {
        BibleView()
    }
}
