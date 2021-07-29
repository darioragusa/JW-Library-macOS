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
    @State var pubb: String
    @State var prevText: String
    @State var geometryReader: GeometryProxy
    @State var book: Int
    @State var editMode: Bool = false
    @State var highlight: Int = 0
    @Binding var chapter: Int

    var body: some View {
        var browser = WebBrowserView(highlight: $highlight, pubb: pubb, book: book, chapter: chapter)
        ZStack {
            browser.onAppear(perform: {
                browser.load()
            }).frame(width: geometryReader.size.width, height: geometryReader.size.height - 2).padding(0)
            HStack { Spacer(); VStack { Spacer()
                if editMode {
                    ForEach(highlightColors, id: \.self, content: { color in
                        Button(action: {
                            editMode = !editMode
                            highlight = highlightColors.firstIndex(of: color)! + 1
                        }, label: {
                            Image(systemName: "paintbrush.fill").padding(3)
                        }).buttonStyle(EditButtonStyle(color: color)).onDisappear(perform: {
                            highlight = 0
                        })
                    })
                    Button(action: {
                        editMode = !editMode
                        highlight = -1
                    }, label: {
                        Image(systemName: "trash").padding(3)
                    }).buttonStyle(EditButtonStyle(color: Color.black)).onDisappear(perform: {
                        highlight = 0
                    })
                }
                Button(action: {
                    editMode = !editMode
                }, label: {
                    (editMode ? Image(systemName: "pencil.slash") : Image(systemName: "pencil")).padding(3)
                }).buttonStyle(EditButtonStyle(color: Stuff.hexColor(hex: 0x888888)))
            }}.padding(.horizontal, 20).padding(.vertical, 5)
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    chapter = 0
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("\(prevText)")
                    }
                })
            }
            ToolbarItem(placement: .navigation) {
                Text("\(chapter)").font(.title2)
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
