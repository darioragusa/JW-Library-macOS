//
//  PubDocumentView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 20/08/21.
//

import SwiftUI

struct PubDocumentView: View {
    @State var documents: [Document] = []
    @Binding var pub: Publication?
    @Binding var document: Document?
    @Binding var showArticle: Bool
    var body: some View {
        ScrollView {
            ForEach(documents, id: \.documentId) { doc in
                HStack {
                    Button(action: {
                        document = doc
                        showArticle = true
                    }, label: {
                        Text("\(doc.title)")
                    })
                    Spacer()
                }
                .padding(5)
            }
        }.padding(10)
        .onAppear(perform: {
            documents = JWPubManager.getDocuments(pub: pub!)
        })
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    pub = nil
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Pubblicazioni")
                    }
                })
            }
            ToolbarItem(placement: .navigation) {
                Text(([13, 14, 30].contains(pub?.publicationTypeId ?? 0) ? pub?.issueTitle : pub?.title) ?? "").font(.title)
            }
        }
    }
}

/*
struct PubDocumentView_Previews: PreviewProvider {
    static var previews: some View {
        PubDocumentView()
    }
}
*/
