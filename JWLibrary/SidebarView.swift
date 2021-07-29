//
//  SidebarView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 31/12/20.
//

import SwiftUI

struct SidebarView: View {
    var body: some View {
        NavigationView {
            List {
                Group {
                    NavigationLink(destination: ContentView().navigationTitle("JW Library")) {
                        Label("Home", systemImage: "house.fill")
                    }
                    NavigationLink(destination: BibleView().navigationTitle("Bibbia")) {
                        Label("Bibbia", systemImage: "book.fill")
                    }
                    NavigationLink(destination: PubbView().navigationTitle("Pubblicazioni")) {
                        Label("Pubblicazioni", systemImage: "doc.text.fill")
                    }
                    NavigationLink(destination: ContentView().navigationTitle("Multimedia")) {
                        Label("Multimedia", systemImage: "film")
                    }
                    NavigationLink(destination: ContentView().navigationTitle("Adunanze")) {
                        Label("Adunanze", systemImage: "calendar")
                    }
                    NavigationLink(destination: ContentView().navigationTitle("Ricerche")) {
                        Label("Ricerche", systemImage: "bookmark.fill")
                    }
                }
            }
            .listStyle(SidebarListStyle())
            .frame(minWidth: 150, idealWidth: 250, maxWidth: 300)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: toggleSidebar, label: {
                        Image(systemName: "sidebar.left")
                    })
                }
            }
            ContentView()
            .onAppear(perform: {
                Stuff.addBaseFiles()
            })
        }
    }
}

func toggleSidebar() {
    NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
