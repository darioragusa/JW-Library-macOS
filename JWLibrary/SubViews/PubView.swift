//
//  PubView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 13/01/21.
//

import SwiftUI

struct PubView: View {
    @State var publications: [Publication] = []
    @State var isDoingStuff: Bool = false
    @State var pub: Publication?
    @State var document: Document?
    @State var showArticle = false
    var body: some View {
        GeometryReader { geometryReader in
            if showArticle {
                ArticleView(showArticle: $showArticle,
                            pub: pub,
                            prevText: (([13, 14, 30].contains(pub?.publicationTypeId ?? 0) ? pub?.issueTitle : pub?.title) ?? ""),
                            geometryReader: geometryReader,
                            document: document,
                            filePath: "Documents_I/\(document!.documentId).html")
            } else if pub != nil {
                PubDocumentView(pub: $pub, document: $document, showArticle: $showArticle)
            } else {
                PubListView(publications: $publications, publication: $pub, isDoingStuff: $isDoingStuff)
            }
        }
        .onAppear(perform: {
            if !FileManager.fileExist(url: FileManager.getDocumentsDirectory().appendingPathComponent("catalog.db")) {
                downloadCatalog()
            } else {
                publications = DBManager.getPublications()
            }
        })
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if !showArticle && pub == nil {
                    Button(action: {
                        downloadCatalog()
                    }, label: {
                        if isDoingStuff {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        } else {
                            Image(systemName: "icloud.and.arrow.down")
                        }
                    }).buttonStyle(PlainButtonStyle())
                }
            }
        }
    }

    // Thanks to @MrCyjaneK https://github.com/MrCyjaneK, https://github.com/Miaosi001/JW-Library-macOS/issues/1
    func downloadCatalog() {
        if let manifest = Stuff.getManifest() {
            isDoingStuff = true
            let catalogUrl = URL(string: "https://app.jw-cdn.org/catalogs/publications/v4/" + manifest + "/catalog.db.gz")!
            FileDownloader.loadFileAsync(url: catalogUrl, completion: { _, _ in
                publications = DBManager.getPublications()
                isDoingStuff = false
            })
        }
    }
}

/*
struct PubView_Previews: PreviewProvider {
    static var previews: some View {
        PubView()
    }
}
*/
