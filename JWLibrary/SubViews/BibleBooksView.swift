//
//  BibleBooksView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 02/01/21.
//

import SwiftUI

struct BibleBooksView: View {
    var bibleBookColors = [1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 1]
    @State var bibleBooks: [BibleBook]
    @Binding var bibleBookIndex: Int
    var body: some View {
        ScrollView {
            if bibleBooks.count > 0 {
                VStack {
                    Text("SCRITTURE EBRAICO-ARAMAICHE")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], spacing: 10) {
                        ForEach(0...38, id: \.self) { x in
                            Button(action: {
                                bibleBookIndex = x
                            }, label: {
                                Text(bibleBooks[x].shortName).frame(width: 120).padding(2.5).padding(.vertical, 2)
                            }).buttonStyle(BibleButtonStyle(color: getBibleColor(colorN: bibleBookColors[x])))
                        }
                    }
                    Divider()
                    Text("SCRITTURE GRECHE CRISTIANE")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 130))], spacing: 10) {
                        ForEach(39...65, id: \.self) { x in
                            Button(action: {
                                bibleBookIndex = x
                            }, label: {
                                Text(bibleBooks[x].shortName).frame(width: 120).padding(2.5).padding(.vertical, 2)
                            }).buttonStyle(BibleButtonStyle(color: getBibleColor(colorN: bibleBookColors[x])))
                        }
                    }
                }
                .padding()
            }
        }
    }

    func getBibleColor(colorN: Int) -> Color {
        switch colorN {
        case 1:
            return Stuff.hexColor(hex: 0x3b3547)
        case 2:
            return Stuff.hexColor(hex: 0x746b84)
        case 3:
            return Stuff.hexColor(hex: 0x544c63)
        default:
            return Stuff.hexColor(hex: 0x0000FF)
        }
    }
}

/*
struct BibleBooksView_Previews: PreviewProvider {
    static var previews: some View {
        BibleBooksView(bibleBooks: [])
    }
}
 */
