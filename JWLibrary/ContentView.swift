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
                UserDataManager.restoreBackup()
            }, label: {
                Text("Importa backup")
            })
            Text("Hello, world!")
            .padding()
            Button(action: {
                UserDataManager.createBackup()
            }, label: {
                Text("Esporta backup")
            })
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
