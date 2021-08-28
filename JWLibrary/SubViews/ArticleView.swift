//
//  ArticleView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 02/01/21.
//

import SwiftUI

var highlightColors: [Color] = [
    Stuff.hexColor(hex: 0xffeb3b),
    Stuff.hexColor(hex: 0x9ef953),
    Stuff.hexColor(hex: 0x29b6f6),
    Stuff.hexColor(hex: 0xffa1c8),
    Stuff.hexColor(hex: 0xffb976),
    Stuff.hexColor(hex: 0xaf85ff)
]

struct ArticleView: View {
    @Binding var showArticle: Bool
    @State var pub: Publication?
    @State var prevText: String
    @State var geometryReader: GeometryProxy
    @State var document: Document?
    @State var editMode: Bool = false
    @State var highlight: ((Int) -> Void)?
    @State var filePath: String
    @State var imgToShow: NSImage?
    @State var citation: ((BibleVerses) -> Void)?
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                var article = WebBrowserArticleView(highlight: $highlight, imgToShow: $imgToShow, citation: $citation, filePath: filePath, pub: pub!, document: document)
                article.onAppear(perform: {
                    article.load()
                }).frame(width: geometryReader.size.width - (pub!.isBible ? 0 : 250), height: geometryReader.size.height - 2).padding(0)
                if !pub!.isBible {
                    Divider()
                    WebBrowserAdditionalView(citation: $citation)
                        .frame(width: 250, height: geometryReader.size.height - 2).padding(0)
                }
            }
            if let img = imgToShow {
                ZStack {
                    Rectangle()
                        .fill(Color.black)
                        .opacity(0.5)
                    Image(nsImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .onTapGesture { imgToShow = nil }
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                HStack {
                    Button(action: {
                        showArticle = false
                    }, label: {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("\(prevText)")
                                .frame(maxWidth: 100)
                                .lineLimit(1)
                        }
                    })
                    if pub!.isBible {
                        Text("\(pub?.chapter ?? 0)").font(.title2)
                    } else {
                        Text(document?.title ?? "").font(.title3)
                            .frame(maxWidth: 300)
                            .lineLimit(1)
                    }
                }
            }
            ToolbarItemGroup(placement: .primaryAction) {
                ForEach(highlightColors, id: \.self, content: { color in
                    Button(action: {
                        highlight?(highlightColors.firstIndex(of: color)! + 1)
                    }, label: {
                        Image(systemName: "paintbrush.fill").foregroundColor(color)
                    })
                })
                .padding(0)
                Button(action: {
                    highlight?(-1)
                }, label: {
                    Image(systemName: "trash")
                })
                .padding(0)
            }
        }
    }
}

/*
struct ArticleView_Previews: PreviewProvider {
    static var previews: some View {
        ArticleView(path: "")
    }
}
 */
