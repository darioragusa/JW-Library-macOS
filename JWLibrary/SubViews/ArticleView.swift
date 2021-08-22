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

    var body: some View {
        var browser = WebBrowserView(highlight: $highlight, filePath: filePath, pub: pub!, document: document)
        browser.onAppear(perform: {
            browser.load()
        }).frame(width: geometryReader.size.width, height: geometryReader.size.height - 2).padding(0)
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    showArticle = false
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("\(prevText)")
                    }
                })
            }
            ToolbarItem(placement: .navigation) {
                if pub!.isBible {
                    Text("\(pub?.chapter ?? 0)").font(.title2)
                } else {
                    Text(document?.title ?? "").font(.title2)
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
                Button(action: {
                    highlight?(-1)
                }, label: {
                    Image(systemName: "trash")
                })
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
