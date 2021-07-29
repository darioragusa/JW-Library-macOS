//
//  PubbView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 13/01/21.
//

import SwiftUI

struct PubbView: View {
    var body: some View {
        ScrollView {
            DisclosureGroup("Torre di Guardia") {
                let w: [(Int, [Int])] = JWPubManager.lookForPubb()
                VStack {
                    ForEach(0...w.count - 1, id: \.self, content: { i in
                        DisclosureGroup(String(w[i].0)) {
                            VStack(alignment: .leading) {
                                ForEach(w[i].1, id: \.self, content: { month in
                                    HStack {
                                        Button(action: {
                                        }, label: {
                                            Text("Torre di guardia, \(month.monthN()) \(String(w[i].0))")
                                        }).buttonStyle(PlainButtonStyle())
                                        if FileManager.fileExist(url: URL(string: "w_I_\(String(w[i].0))\(month)")!) {
                                            Button(action: {
                                            }, label: {
                                                Image(systemName: "trash.fill")
                                            }).buttonStyle(PlainButtonStyle())
                                        } else {
                                            Button(action: {
                                            }, label: {
                                                Image(systemName: "icloud.and.arrow.down")
                                            }).buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                })
                            }
                            .padding(.horizontal, 20)
                        }
                    })
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(20)
        .onAppear(perform: {
        })
    }
}

struct PubbView_Previews: PreviewProvider {
    static var previews: some View {
        PubbView()
    }
}
