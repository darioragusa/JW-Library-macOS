//
//  ContentView.swift
//  JWLibrary
//
//  Created by Dario Ragusa on 01/01/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            Button(action: {
                BackupManager.restoreBackup()
            }, label: {
                Text("Importa backup")
            })
            Text("Hello, world!")
            .padding()
            Button(action: {
                BackupManager.createBackup()
            }, label: {
                Text("Esporta backup")
            })
            /*Button(action: {
                JWPubExtractor.testExtraction()
            }, label: {
                Text("Test JWPub")
            })*/
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
