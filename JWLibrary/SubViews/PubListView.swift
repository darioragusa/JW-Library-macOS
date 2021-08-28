//
//  PubListView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 20/08/21.
//

import SwiftUI

struct PubListView: View {
    @Binding var publications: [Publication]
    @Binding var publication: Publication?
    @Binding var isDoingStuff: Bool
    var body: some View {
        ScrollView {
            DisclosureGroup("Libri (\(publications.filter({$0.publicationTypeId == 2}).count))") {
                ScrollView {
                    LazyVStack {
                        ForEach(publications.sorted(by: {$0.title < $1.title}).filter({$0.publicationTypeId == 2}), id: \.ID, content: { pub in
                            HStack {
                                Text(pub.title).onTapGesture { if existPub(pub) { publication = pub }}
                                Spacer()
                                if existPub(pub) { Button(action: { deletePub(pub) }, label: { Image(systemName: "trash") }) }
                                Button(action: { downloadPub(pub) }, label: { Image(systemName: "icloud.and.arrow.down") })
                            }
                        })
                    }.padding(.horizontal, 5)
                }.frame(maxHeight: 300)
            }.padding(5)
            DisclosureGroup("Opuscoli (\(publications.filter({$0.publicationTypeId == 4}).count))") {
                ScrollView {
                    LazyVStack {
                        ForEach(publications.sorted(by: {$0.title < $1.title}).filter({$0.publicationTypeId == 4}), id: \.ID, content: { pub in
                            HStack {
                                Text(pub.title).onTapGesture { if existPub(pub) { publication = pub }}
                                Spacer()
                                if existPub(pub) { Button(action: { deletePub(pub) }, label: { Image(systemName: "trash") }) }
                                Button(action: { downloadPub(pub) }, label: { Image(systemName: "icloud.and.arrow.down") })
                            }
                        })
                    }.padding(.horizontal, 5)
                }.frame(maxHeight: 300)
            }.padding(5)
            DisclosureGroup("Torre di Guardia (\(publications.filter({$0.publicationTypeId == 14}).count))") {
                ScrollView {
                    LazyVStack {
                        ForEach(publications.reversed().sorted(by: {$0.year > $1.year}).filter({$0.publicationTypeId == 14}), id: \.ID, content: { pub in
                            HStack {
                                Text(pub.issueTitle!).onTapGesture { if existPub(pub) { publication = pub }}
                                Spacer()
                                if existPub(pub) { Button(action: { deletePub(pub) }, label: { Image(systemName: "trash") }) }
                                Button(action: { downloadPub(pub) }, label: { Image(systemName: "icloud.and.arrow.down") })
                            }
                        })
                    }.padding(.horizontal, 5)
                }.frame(maxHeight: 300)
            }.padding(5)
            DisclosureGroup("Svegliatevi! (\(publications.filter({$0.publicationTypeId == 13}).count))") {
                ScrollView {
                    LazyVStack {
                        ForEach(publications.reversed().sorted(by: {$0.year > $1.year}).filter({$0.publicationTypeId == 13}), id: \.ID, content: { pub in
                            HStack {
                                Text(pub.issueTitle!).onTapGesture { if existPub(pub) { publication = pub }}
                                Spacer()
                                if existPub(pub) { Button(action: { deletePub(pub) }, label: { Image(systemName: "trash") }) }
                                Button(action: { downloadPub(pub) }, label: { Image(systemName: "icloud.and.arrow.down") })
                            }
                        })
                    }.padding(.horizontal, 5)
                }.frame(maxHeight: 300)
            }.padding(5)
            DisclosureGroup("Guida per l'adunanza (\(publications.filter({$0.publicationTypeId == 30}).count))") {
                ScrollView {
                    LazyVStack {
                        ForEach(publications.reversed().sorted(by: {$0.year > $1.year}).filter({$0.publicationTypeId == 30}), id: \.ID, content: { pub in
                            HStack {
                                Text(pub.issueTitle!).onTapGesture { if existPub(pub) { publication = pub }}
                                Spacer()
                                if existPub(pub) { Button(action: { deletePub(pub) }, label: { Image(systemName: "trash") }) }
                                Button(action: { downloadPub(pub) }, label: { Image(systemName: "icloud.and.arrow.down") })
                            }
                        })
                    }.padding(.horizontal, 5)
                }.frame(maxHeight: 300)
            }.padding(5)
        }
    }
    func downloadPub(_ pub: Publication) {
        isDoingStuff = true
        let apiUrl = URL(string: "https://b.jw-cdn.org/apis/pub-media/GETPUBMEDIALINKS?issue=\(pub.issueTagNumber)&output=json&pub=\(pub.keySymbol)&fileformat=jwpub&alllangs=0&langwritten=I")!
        guard let pubUrl = URL(string: Stuff.getJWPubUrl(apiLink: apiUrl) ?? "") else { return }
        FileDownloader.loadFileAsync(url: pubUrl) { _, _ in
            JWPubManager.downloadDocuments(pub: pub)
            isDoingStuff = false
        }
    }
    func existPub(_ pub: Publication) -> Bool {
        let pubName = "\(pub.keySymbol)_I\(pub.issueTagNumber != 0 ? "_\("\(pub.issueTagNumber)".hasSuffix("00") ? pub.issueTagNumber / 100 : pub.issueTagNumber)" : "")"
        return FileManager.extractedJWPubExist(url: FileManager.getDocumentsDirectory().appendingPathComponent(pubName))
    }
    func deletePub(_ pub: Publication) {
        isDoingStuff = true
        let documents = JWPubManager.getDocuments(pub: pub)
        for document in documents {
            let delPath = FileManager.getDocumentsDirectory().appendingPathComponent("Documents_I/\(document.documentId).html")
            print("Deleting... \(delPath)")
            try? FileManager().removeItem(at: delPath)
        }
        let pubName = "\(pub.keySymbol)_I\(pub.issueTagNumber != 0 ? "_\("\(pub.issueTagNumber)".hasSuffix("00") ? pub.issueTagNumber / 100 : pub.issueTagNumber)" : "")"
        try? FileManager().removeItem(at: FileManager.getDocumentsDirectory().appendingPathComponent(pubName))
        isDoingStuff = false
    }
}

/*
struct PubListView_Previews: PreviewProvider {
    static var previews: some View {
        PubListView()
    }
}
*/
