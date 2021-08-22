//
//  BibleChaptersView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 02/01/21.
//

import SwiftUI

struct BibleChaptersView: View {
    @State var bibleBook: BibleBook
    @Binding var bibleBookIndex: Int
    @Binding var chapter: Int
    @Binding var showArticle: Bool

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 20) {
            ForEach(1...bibleBook.chapters, id: \.self) { x in
                Button(action: {
                    chapter = x
                    showArticle = true
                }, label: {
                    Text("\(x)").frame(width: 25)
                })
            }
        }.padding()
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button(action: {
                    bibleBookIndex = -1
                }, label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Bibbia")
                    }
                })
            }
            ToolbarItem(placement: .principal) {
                Text(bibleBook.fullName).font(.title)
            }
        }
    }
}

/*
 struct BibleChaptersView_Previews: PreviewProvider {
    static var previews: some View {
        BibleChaptersView(bibleBook: BibleBook(ID: 1, shortName: "Genesi", fullName: "Genesi", chapters: 50), chapter: $1)
    }
 }
*/
